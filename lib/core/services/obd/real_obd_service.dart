import 'dart:async';
import 'dart:convert';
import '../../../shared/models/dtc_model.dart';
import '../ble/ble_service.dart';
import 'obd_service.dart';

class RealOBDService implements OBDService {
  final BLEService _bleService = BLEService();

  final _connectionController = StreamController<bool>.broadcast();
  final _rpmController = StreamController<double>.broadcast();
  final _speedController = StreamController<double>.broadcast();
  final _coolantController = StreamController<double>.broadcast();
  final _loadController = StreamController<double>.broadcast();
  final _throttleController = StreamController<double>.broadcast();
  final _batteryController = StreamController<double>.broadcast();
  final _intakeTempController = StreamController<double>.broadcast();
  final _mafController = StreamController<double>.broadcast();
  final _turboBoostController = StreamController<double>.broadcast();
  final _stftController = StreamController<double>.broadcast();
  final _ltftController = StreamController<double>.broadcast();
  final _timingController = StreamController<double>.broadcast();
  final _fuelLevelController = StreamController<double>.broadcast();
  final _baroController = StreamController<double>.broadcast();

  bool _isConnected = false;
  Timer? _pollingTimer;

  RealOBDService() {
    // Optionally listen to BLE disconnects to update state
  }

  @override
  Stream<bool> get connectionState async* {
    yield _isConnected;
    yield* _connectionController.stream;
  }

  @override
  Stream<double> get rpmStream async* {
    yield 0.0;
    yield* _rpmController.stream;
  }

  @override
  Stream<double> get speedStream async* {
    yield 0.0;
    yield* _speedController.stream;
  }

  @override
  Stream<double> get coolantTempStream async* {
    yield 0.0;
    yield* _coolantController.stream;
  }

  @override
  Stream<double> get engineLoadStream async* {
    yield 0.0;
    yield* _loadController.stream;
  }

  @override
  Stream<double> get throttleStream async* {
    yield 0.0;
    yield* _throttleController.stream;
  }

  @override
  Stream<double> get batteryVoltageStream async* {
    yield 0.0;
    yield* _batteryController.stream;
  }

  @override
  Stream<double> get intakeTempStream async* {
    yield 0.0;
    yield* _intakeTempController.stream;
  }

  @override
  Stream<double> get mafStream async* {
    yield 0.0;
    yield* _mafController.stream;
  }

  @override
  Stream<double> get turboBoostStream async* {
    yield 0.0;
    yield* _turboBoostController.stream;
  }

  @override
  Stream<double> get stftStream async* {
    yield 0.0;
    yield* _stftController.stream;
  }

  @override
  Stream<double> get ltftStream async* {
    yield 0.0;
    yield* _ltftController.stream;
  }

  @override
  Stream<double> get timingAdvanceStream async* {
    yield 0.0;
    yield* _timingController.stream;
  }

  @override
  Stream<double> get fuelLevelStream async* {
    yield 0.0;
    yield* _fuelLevelController.stream;
  }

  @override
  Stream<double> get baroStream async* {
    yield 0.0;
    yield* _baroController.stream;
  }

  @override
  Future<void> connect() async {
    if (_bleService.connectedDevice != null) {
      _isConnected = true;
      _connectionController.add(true);
      _setupDataListener();
      _initELM327();
    }
  }

  Future<void> _initELM327() async {
    await _sendCommand('ATZ\r'); // Reset
    await Future.delayed(const Duration(milliseconds: 500));
    await _sendCommand('ATE0\r'); // Echo off
    await Future.delayed(const Duration(milliseconds: 500));
    await _sendCommand('ATL0\r'); // Linefeeds off
    await Future.delayed(const Duration(milliseconds: 200));
    await _sendCommand('ATSP0\r'); // Auto protocol
    
    _startPolling();
  }

  void _setupDataListener() {
    _bleService.dataStream?.listen((data) {
      final response = utf8.decode(data, allowMalformed: true).trim();
      _parseResponse(response);
    });
  }

  Future<void> _sendCommand(String command) async {
    if (!_isConnected) return;
    await _bleService.writeData(utf8.encode(command));
  }

  final List<String> _secondaryPIDs = [
    '0105\r', // Coolant
    '0104\r', // Load
    '010B\r', // MAP (Turbo)
    '0111\r', // Throttle (TPS)
    '010F\r', // Intake Air Temp (IAT)
    '0110\r', // MAF Flow Rate
    '0106\r', // STFT Bank 1
    '0107\r', // LTFT Bank 1
    '010E\r', // Timing Advance
    '012F\r', // Fuel Level
    '0133\r', // Barometric Pressure
    'ATRV\r', // Battery Voltage
  ];

  int _secondaryIndex = 0;

  void _startPolling() {
    _pollingTimer?.cancel();
    int cycle = 0;
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) async {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      
      // High-frequency alternating with secondary PIDs
      if (cycle % 3 == 0) {
        await _sendCommand('010C\r'); // RPM
      } else if (cycle % 3 == 1) {
        await _sendCommand('010D\r'); // Speed
      } else {
        // Query next secondary sensor
        final cmd = _secondaryPIDs[_secondaryIndex];
        _secondaryIndex = (_secondaryIndex + 1) % _secondaryPIDs.length;
        await _sendCommand(cmd);
      }
      cycle = (cycle + 1) % 12;
    });
  }

  List<DTCModel> _accumulatedDTCs = [];
  Completer<String?>? _vinCompleter;
  String _vinBuffer = '';

  void _parseResponse(String response) {
    response = response.replaceAll(' ', '').replaceAll('\r', '').replaceAll('\n', '').toUpperCase();
    if (response.isEmpty || response.contains('NODATA')) return;

    // Battery voltage direct response from ATRV (e.g. "12.6V")
    if (response.endsWith('V')) {
      final vStr = response.replaceAll('V', '');
      final volt = double.tryParse(vStr);
      if (volt != null) {
        _batteryController.add(volt);
        return;
      }
    }

    if (response.startsWith('4902')) {
      _parseVINResponse(response);
    } else if (response.startsWith('43') || response.startsWith('47') || response.startsWith('4A')) {
      String status = 'confirmed';
      if (response.startsWith('47')) status = 'pending';
      if (response.startsWith('4A')) status = 'permanent';
      
      final dtcs = _parseDTCResponse(response, status);
      _accumulatedDTCs.addAll(dtcs);
    } else if (response.startsWith('410C') && response.length >= 8) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      final b = int.parse(response.substring(6, 8), radix: 16);
      _rpmController.add(((a * 256.0) + b) / 4.0);
    } else if (response.startsWith('410D') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _speedController.add(a.toDouble());
    } else if (response.startsWith('4105') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _coolantController.add((a - 40).toDouble());
    } else if (response.startsWith('4104') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _loadController.add((a * 100.0) / 255.0);
    } else if (response.startsWith('410B') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      double boostBar = (a - 100) * 0.01; 
      if (boostBar < 0) boostBar = 0;
      _turboBoostController.add(boostBar);
    } else if (response.startsWith('4111') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _throttleController.add((a * 100.0) / 255.0);
    } else if (response.startsWith('410F') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _intakeTempController.add((a - 40).toDouble());
    } else if (response.startsWith('4110') && response.length >= 8) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      final b = int.parse(response.substring(6, 8), radix: 16);
      _mafController.add(((a * 256.0) + b) / 100.0);
    } else if (response.startsWith('4106') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _stftController.add(((a - 128.0) * 100.0) / 128.0);
    } else if (response.startsWith('4107') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _ltftController.add(((a - 128.0) * 100.0) / 128.0);
    } else if (response.startsWith('410E') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _timingController.add((a / 2.0) - 64.0);
    } else if (response.startsWith('412F') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _fuelLevelController.add((a * 100.0) / 255.0);
    } else if (response.startsWith('4133') && response.length >= 6) {
      final a = int.parse(response.substring(4, 6), radix: 16);
      _baroController.add(a.toDouble());
    }
  }

  List<DTCModel> _parseDTCResponse(String hexStr, String status) {
    if (hexStr.length < 4) return [];
    
    final List<DTCModel> found = [];
    final dtcHex = hexStr.substring(2);
    
    for (int i = 0; i < dtcHex.length; i += 4) {
      if (i + 4 > dtcHex.length) break;
      
      final code = dtcHex.substring(i, i + 4);
      if (code == "0000") continue; // Empty slot
      
      final a = int.parse(code.substring(0, 2), radix: 16);
      final typeBit = (a >> 6) & 0x03; 
      
      String prefix;
      switch (typeBit) {
        case 0: prefix = "P"; break;
        case 1: prefix = "C"; break;
        case 2: prefix = "B"; break;
        case 3: prefix = "U"; break;
        default: prefix = "P";
      }
      
      final digit1 = ((a >> 4) & 0x03).toString(); 
      final rest = code.substring(1); 
      final fullCode = "$prefix$digit1$rest";
      
      String desc = 'Defecto detectado en el módulo';
      if (fullCode == 'P0171') desc = 'Mezcla demasiado pobre (Banco 1)';
      if (fullCode == 'P0301') desc = 'Fallo de encendido detectado (Cilindro 1)';
      if (fullCode == 'P0420') desc = 'Eficiencia del sistema catalizador por debajo del umbral (Banco 1)';
      
      found.add(DTCModel(
        code: fullCode,
        description: desc,
        severity: (prefix == 'P' || prefix == 'C') ? 'High' : 'Medium',
        system: 'OBD-II $prefix-System',
        status: status,
        timestamp: DateTime.now(),
      ));
    }
    return found;
  }

  @override
  Future<void> disconnect() async {
    _pollingTimer?.cancel();
    _isConnected = false;
    _connectionController.add(false);
    
    _rpmController.add(0);
    _speedController.add(0);
    _coolantController.add(0);
    _loadController.add(0);
    _throttleController.add(0);
    _batteryController.add(0);
    _intakeTempController.add(0);
    _mafController.add(0);
    _turboBoostController.add(0);
    _stftController.add(0);
    _ltftController.add(0);
    _timingController.add(0);
    _fuelLevelController.add(0);
    _baroController.add(0);
    
    await _bleService.disconnect();
  }

  @override
  Future<List<DTCModel>> scanDTCs() async {
    _accumulatedDTCs = [];

    // 1. Scan Mode 03 (Stored Confirmed DTCs)
    await _sendCommand('03\r');
    await Future.delayed(const Duration(milliseconds: 900));

    // 2. Scan Mode 07 (Pending DTCs)
    await _sendCommand('07\r');
    await Future.delayed(const Duration(milliseconds: 900));

    // 3. Scan Mode 0A (Permanent DTCs)
    await _sendCommand('0A\r');
    await Future.delayed(const Duration(milliseconds: 900));

    // Deduplicate by code while prioritizing confirmed > pending > permanent
    final Map<String, DTCModel> unique = {};
    for (final dtc in _accumulatedDTCs) {
      if (!unique.containsKey(dtc.code)) {
        unique[dtc.code] = dtc;
      }
    }

    return unique.values.toList();
  }

  @override
  Future<void> clearDTCs() async {
    await _sendCommand('04\r'); // Clear codes command
    await Future.delayed(const Duration(seconds: 2));
  }

  void _parseVINResponse(String response) {
    // A simplified multi-frame parser just extracting ASCII 
    // Usually responses are like 490201xxxxxx, 490202xxxxxx
    if (response.length > 6) {
      final hexData = response.substring(6); // Skip 490201
      for (int i = 0; i < hexData.length; i += 2) {
        if (i + 2 > hexData.length) break;
        final charCode = int.tryParse(hexData.substring(i, i + 2), radix: 16);
        if (charCode != null && charCode > 31 && charCode < 127) {
          _vinBuffer += String.fromCharCode(charCode);
        }
      }
    }
    
    // VIN is 17 chars
    if (_vinBuffer.length >= 17 && _vinCompleter != null && !_vinCompleter!.isCompleted) {
      _vinCompleter!.complete(_vinBuffer.substring(0, 17));
    }
  }

  @override
  Future<String?> readVIN() async {
    _vinBuffer = '';
    _vinCompleter = Completer<String?>();
    await _sendCommand('0902\r');
    
    Future.delayed(const Duration(seconds: 4), () {
      if (_vinCompleter != null && !_vinCompleter!.isCompleted) {
        _vinCompleter!.complete(_vinBuffer.isNotEmpty ? _vinBuffer : null); 
      }
    });
    
    return _vinCompleter!.future;
  }
}
