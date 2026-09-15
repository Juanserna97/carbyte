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

  bool _isConnected = false;
  Timer? _pollingTimer;

  RealOBDService() {
    // Optionally listen to BLE disconnects to update state
  }

  @override
  Stream<bool> get connectionState => _connectionController.stream;
  @override
  Stream<double> get rpmStream => _rpmController.stream;
  @override
  Stream<double> get speedStream => _speedController.stream;
  @override
  Stream<double> get coolantTempStream => _coolantController.stream;
  @override
  Stream<double> get engineLoadStream => _loadController.stream;
  @override
  Stream<double> get throttleStream => _throttleController.stream;
  @override
  Stream<double> get batteryVoltageStream => _batteryController.stream;
  @override
  Stream<double> get intakeTempStream => _intakeTempController.stream;
  @override
  Stream<double> get mafStream => _mafController.stream;
  @override
  Stream<double> get turboBoostStream => _turboBoostController.stream;

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

  void _startPolling() {
    _pollingTimer?.cancel();
    int step = 0;
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      switch (step) {
        case 0: await _sendCommand('010C\r'); break; // RPM
        case 1: await _sendCommand('010D\r'); break; // Speed
        case 2: await _sendCommand('0105\r'); break; // Coolant
        case 3: await _sendCommand('0104\r'); break; // Engine Load
        case 4: await _sendCommand('010B\r'); break; // MAP (Turbo Boost)
      }
      step = (step + 1) % 5;
    });
  }

  Completer<List<DTCModel>>? _dtcCompleter;
  Completer<String?>? _vinCompleter;
  String _vinBuffer = '';

  void _parseResponse(String response) {
    response = response.replaceAll(' ', '').replaceAll('\r', '').replaceAll('\n', '').toUpperCase();
    if (response.isEmpty || response.contains('NODATA')) return;

    if (response.startsWith('4902')) {
      _parseVINResponse(response);
    } else if (response.startsWith('43')) {
      final dtcs = _parseDTCResponse(response);
      if (_dtcCompleter != null && !_dtcCompleter!.isCompleted) {
        _dtcCompleter!.complete(dtcs);
      }
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
      // MAP is in kPa. Subtract approx atm pressure (100 kPa) for Boost. Convert to Bar (*0.01)
      double boostBar = (a - 100) * 0.01; 
      if (boostBar < 0) boostBar = 0; // Negative means vacuum
      _turboBoostController.add(boostBar);
    }
  }

  List<DTCModel> _parseDTCResponse(String hexStr) {
    // hexStr e.g. "43013300000000"
    if (hexStr.length < 6) return [];
    
    final List<DTCModel> found = [];
    final dtcHex = hexStr.substring(2); // remove "43"
    
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
      
      // Basic dictionary mapping for common codes
      String desc = 'Defecto detectado en el módulo';
      if (fullCode == 'P0171') desc = 'Sistema demasiado pobre (Bank 1)';
      if (fullCode == 'P0301') desc = 'Fallo de encendido detectado (Cilindro 1)';
      if (fullCode == 'P0420') desc = 'Eficiencia del sistema catalizador por debajo del umbral (Bank 1)';
      
      found.add(DTCModel(
        code: fullCode,
        description: desc,
        severity: (prefix == 'P' || prefix == 'C') ? 'High' : 'Medium',
        system: 'OBD-II $prefix-System',
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
    
    // Reset defaults on disconnect
    _rpmController.add(0);
    _speedController.add(0);
    _coolantController.add(0);
    _loadController.add(0);
    
    await _bleService.disconnect();
  }

  @override
  Future<List<DTCModel>> scanDTCs() async {
    _dtcCompleter = Completer<List<DTCModel>>();
    await _sendCommand('03\r');
    
    // Timeout fallback if ECU doesn't respond
    Future.delayed(const Duration(seconds: 4), () {
      if (_dtcCompleter != null && !_dtcCompleter!.isCompleted) {
        _dtcCompleter!.complete([]); 
      }
    });
    
    return _dtcCompleter!.future;
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
