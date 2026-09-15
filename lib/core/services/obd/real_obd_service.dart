import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  bool _isPollingActive = false;
  StreamSubscription<List<int>>? _bleDataSub;

  // Command-response synchronization
  Future<void> _lastCommandFuture = Future.value();
  Completer<String>? _currentCompleter;
  final StringBuffer _rxBuffer = StringBuffer();

  RealOBDService() {
    // Listen to BLE data stream
    _bleDataSub = _bleService.dataStream.listen(_onDataReceived);
  }

  void _onDataReceived(List<int> bytes) {
    if (bytes.isEmpty) return;
    final text = ascii.decode(bytes, allowInvalid: true);
    _rxBuffer.write(text);

    // ELM327 signals completion of response with the '>' prompt character
    if (_rxBuffer.toString().contains('>')) {
      final completedResponse = _rxBuffer.toString();
      _rxBuffer.clear();
      if (_currentCompleter != null && !_currentCompleter!.isCompleted) {
        _currentCompleter!.complete(completedResponse);
      }
    }
  }

  /// Sends a command to the ELM327 adapter and waits for the full response terminated by '>'
  Future<String> sendCommand(String command, {Duration timeout = const Duration(milliseconds: 1400)}) {
    return _enqueueCommand(() async {
      if (!_isConnected) return '';

      _rxBuffer.clear();
      final completer = Completer<String>();
      _currentCompleter = completer;

      final cmdToSend = command.endsWith('\r') ? command : '$command\r';
      await _bleService.writeData(ascii.encode(cmdToSend));

      try {
        final rawResponse = await completer.future.timeout(timeout);
        _currentCompleter = null;
        return rawResponse;
      } on TimeoutException {
        _currentCompleter = null;
        final partial = _rxBuffer.toString();
        _rxBuffer.clear();
        // Interrupt hanging ELM327 operation by sending an empty \r
        try {
          await _bleService.writeData(ascii.encode('\r'));
          await Future.delayed(const Duration(milliseconds: 80));
          _rxBuffer.clear();
        } catch (_) {}
        return partial;
      } catch (e) {
        _currentCompleter = null;
        return '';
      }
    });
  }

  /// Sequential execution queue ensuring half-duplex ELM327 commands never overlap
  Future<T> _enqueueCommand<T>(Future<T> Function() action) {
    final next = _lastCommandFuture.then((_) => action(), onError: (_) => action());
    _lastCommandFuture = next.then((_) {}, onError: (_) {});
    return next;
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

  String detectedProtocol = '';

  @override
  Future<void> connect() async {
    if (_bleService.connectedDevice != null) {
      _isConnected = true;
      _connectionController.add(true);
      await _initELM327();
    }
  }

  Future<void> _initELM327() async {
    debugPrint('Configuring ELM327 adapter & locking ECU protocol...');
    _bleDataSub?.cancel();
    _bleDataSub = _bleService.dataStream.listen(_onDataReceived);

    // Initial sequence
    await Future.delayed(const Duration(milliseconds: 200));
    await sendCommand('ATZ', timeout: const Duration(milliseconds: 1500)); // Reset
    await Future.delayed(const Duration(milliseconds: 500));
    await sendCommand('ATE0', timeout: const Duration(milliseconds: 800)); // Echo off
    await sendCommand('ATL0', timeout: const Duration(milliseconds: 800)); // Linefeeds off
    await sendCommand('ATS0', timeout: const Duration(milliseconds: 800)); // Spaces off
    await sendCommand('ATH0', timeout: const Duration(milliseconds: 800)); // Headers off
    await sendCommand('ATAT1', timeout: const Duration(milliseconds: 800)); // Adaptive timing
    await sendCommand('ATAL', timeout: const Duration(milliseconds: 800)); // Allow long messages

    // Multi-protocol ECU handshake
    bool busConnected = false;

    // 1. Try Automatic protocol search (give up to 9 seconds)
    await sendCommand('ATSP0', timeout: const Duration(milliseconds: 1000));
    debugPrint('[OBD] Searching protocol with 0100 (auto)...');
    String res = await sendCommand('0100', timeout: const Duration(seconds: 9));
    debugPrint('[OBD] ATSP0 result: $res');

    final cleanRes = res.replaceAll(' ', '').toUpperCase();
    if (cleanRes.contains('4100')) {
      busConnected = true;
    }

    // 2. If Auto failed or timed out, try Protocol 6 (ISO 15765-4 CAN 11/500 - 90% of cars)
    if (!busConnected) {
      debugPrint('[OBD] Auto failed. Trying Protocol 6 (CAN 11/500)...');
      await sendCommand('ATSP6', timeout: const Duration(milliseconds: 1000));
      res = await sendCommand('0100', timeout: const Duration(seconds: 4));
      debugPrint('[OBD] ATSP6 result: $res');
      if (res.replaceAll(' ', '').toUpperCase().contains('4100')) {
        busConnected = true;
      }
    }

    // 3. If still not connected, try Protocol 7 (ISO 15765-4 CAN 29/500)
    if (!busConnected) {
      debugPrint('[OBD] Trying Protocol 7 (CAN 29/500)...');
      await sendCommand('ATSP7', timeout: const Duration(milliseconds: 1000));
      res = await sendCommand('0100', timeout: const Duration(seconds: 4));
      debugPrint('[OBD] ATSP7 result: $res');
      if (res.replaceAll(' ', '').toUpperCase().contains('4100')) {
        busConnected = true;
      }
    }

    // 4. If still not connected, try Protocol 8 (CAN 11/250)
    if (!busConnected) {
      debugPrint('[OBD] Trying Protocol 8 (CAN 11/250)...');
      await sendCommand('ATSP8', timeout: const Duration(milliseconds: 1000));
      res = await sendCommand('0100', timeout: const Duration(seconds: 4));
      debugPrint('[OBD] ATSP8 result: $res');
      if (res.replaceAll(' ', '').toUpperCase().contains('4100')) {
        busConnected = true;
      }
    }

    // 5. If still not connected, fallback to ATSP0
    if (!busConnected) {
      debugPrint('[OBD] Fallback to ATSP0...');
      await sendCommand('ATSP0', timeout: const Duration(milliseconds: 1000));
      await sendCommand('0100', timeout: const Duration(seconds: 5));
    }

    // Read active protocol description
    final proto = await sendCommand('ATDP', timeout: const Duration(milliseconds: 1000));
    detectedProtocol = proto.replaceAll('>', '').replaceAll('\r', '').replaceAll('\n', '').trim();
    debugPrint('[OBD] Active ECU Protocol: $detectedProtocol');

    _startPolling();
  }

  final List<String> _secondaryPIDs = [
    '0105', // Coolant
    '0104', // Load
    '010B', // MAP (Turbo Boost)
    '0111', // Throttle (TPS)
    '010F', // Intake Air Temp (IAT)
    '0110', // MAF Flow Rate
    '0106', // STFT Bank 1
    '0107', // LTFT Bank 1
    '010E', // Timing Advance
    '012F', // Fuel Level
    '0133', // Barometric Pressure
    'ATRV', // Battery Voltage
  ];

  int _secondaryIndex = 0;

  void _startPolling() {
    _isPollingActive = true;
    _runPollingLoop();
  }

  Future<void> _runPollingLoop() async {
    int cycle = 0;
    while (_isConnected && _isPollingActive) {
      try {
        String cmd;
        if (cycle % 2 == 0) {
          cmd = '010C'; // RPM (high priority)
        } else if (cycle % 4 == 1) {
          cmd = '010D'; // Speed (medium priority)
        } else {
          // Query next secondary sensor
          cmd = _secondaryPIDs[_secondaryIndex];
          _secondaryIndex = (_secondaryIndex + 1) % _secondaryPIDs.length;
        }
        cycle = (cycle + 1) % 12;

        final raw = await sendCommand(cmd, timeout: const Duration(milliseconds: 900));
        if (!_isConnected || !_isPollingActive) break;

        if (raw.isNotEmpty) {
          // If we got UNABLE TO CONNECT or BUS ERROR, attempt a single 0100 re-wake
          if (raw.contains('UNABLE TO CONNECT') || raw.contains('BUS INIT')) {
            debugPrint('[OBD] Bus lost, re-pinging 0100...');
            await sendCommand('0100', timeout: const Duration(seconds: 3));
          } else {
            _parseResponse(raw);
          }
        }

        // Brief delay between commands to keep the CAN bus responsive
        await Future.delayed(const Duration(milliseconds: 35));
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void _parseResponse(String raw) {
    // Clean spaces, line breaks, and prompt chars
    final clean = raw
        .replaceAll(' ', '')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .replaceAll('>', '')
        .toUpperCase();

    if (clean.isEmpty || clean.contains('NODATA') || clean.contains('ERROR') || clean.contains('?')) {
      return;
    }

    // Battery voltage direct response from ATRV (e.g. "12.6V" or "14.2V")
    if (clean.endsWith('V')) {
      final vStr = clean.replaceAll('V', '');
      final volt = double.tryParse(vStr);
      if (volt != null && volt > 5.0 && volt < 25.0) {
        _batteryController.add(volt);
        return;
      }
    }

    // Standard OBD Mode 01 Responses (Prefix 41)
    if (clean.contains('410C')) {
      final idx = clean.indexOf('410C');
      if (clean.length >= idx + 8) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        final b = int.tryParse(clean.substring(idx + 6, idx + 8), radix: 16);
        if (a != null && b != null) {
          final rpm = ((a * 256.0) + b) / 4.0;
          _rpmController.add(rpm);
        }
      }
    } else if (clean.contains('410D')) {
      final idx = clean.indexOf('410D');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _speedController.add(a.toDouble());
        }
      }
    } else if (clean.contains('4105')) {
      final idx = clean.indexOf('4105');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _coolantController.add((a - 40).toDouble());
        }
      }
    } else if (clean.contains('4104')) {
      final idx = clean.indexOf('4104');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _loadController.add((a * 100.0) / 255.0);
        }
      }
    } else if (clean.contains('410B')) {
      final idx = clean.indexOf('410B');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          // MAP in kPa -> Turbo Boost (relative to 101 kPa atmos) in Bar
          double boostBar = (a - 100) * 0.01;
          if (boostBar < 0) boostBar = 0;
          _turboBoostController.add(boostBar);
        }
      }
    } else if (clean.contains('4111')) {
      final idx = clean.indexOf('4111');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _throttleController.add((a * 100.0) / 255.0);
        }
      }
    } else if (clean.contains('410F')) {
      final idx = clean.indexOf('410F');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _intakeTempController.add((a - 40).toDouble());
        }
      }
    } else if (clean.contains('4110')) {
      final idx = clean.indexOf('4110');
      if (clean.length >= idx + 8) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        final b = int.tryParse(clean.substring(idx + 6, idx + 8), radix: 16);
        if (a != null && b != null) {
          _mafController.add(((a * 256.0) + b) / 100.0);
        }
      }
    } else if (clean.contains('4106')) {
      final idx = clean.indexOf('4106');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _stftController.add(((a - 128.0) * 100.0) / 128.0);
        }
      }
    } else if (clean.contains('4107')) {
      final idx = clean.indexOf('4107');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _ltftController.add(((a - 128.0) * 100.0) / 128.0);
        }
      }
    } else if (clean.contains('410E')) {
      final idx = clean.indexOf('410E');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _timingController.add((a / 2.0) - 64.0);
        }
      }
    } else if (clean.contains('412F')) {
      final idx = clean.indexOf('412F');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _fuelLevelController.add((a * 100.0) / 255.0);
        }
      }
    } else if (clean.contains('4133')) {
      final idx = clean.indexOf('4133');
      if (clean.length >= idx + 6) {
        final a = int.tryParse(clean.substring(idx + 4, idx + 6), radix: 16);
        if (a != null) {
          _baroController.add(a.toDouble());
        }
      }
    }
  }

  @override
  Future<void> disconnect() async {
    _isPollingActive = false;
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

    await _bleDataSub?.cancel();
    _bleDataSub = null;
    await _bleService.disconnect();
  }

  @override
  Future<List<DTCModel>> scanDTCs() async {
    final List<DTCModel> allDTCs = [];

    // Pause live polling during DTC scan so the bus is dedicated
    final wasPolling = _isPollingActive;
    _isPollingActive = false;
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      // 1. Mode 03 (Stored Confirmed DTCs)
      final res03 = await sendCommand('03', timeout: const Duration(milliseconds: 2500));
      allDTCs.addAll(_parseDTCResponse(res03, 'confirmed'));

      // 2. Mode 07 (Pending DTCs)
      final res07 = await sendCommand('07', timeout: const Duration(milliseconds: 2500));
      allDTCs.addAll(_parseDTCResponse(res07, 'pending'));

      // 3. Mode 0A (Permanent DTCs)
      final res0A = await sendCommand('0A', timeout: const Duration(milliseconds: 2500));
      allDTCs.addAll(_parseDTCResponse(res0A, 'permanent'));
    } finally {
      if (wasPolling && _isConnected) {
        _startPolling();
      }
    }

    // Deduplicate by DTC code while prioritizing confirmed > pending > permanent
    final Map<String, DTCModel> unique = {};
    for (final dtc in allDTCs) {
      if (!unique.containsKey(dtc.code)) {
        unique[dtc.code] = dtc;
      }
    }

    return unique.values.toList();
  }

  List<DTCModel> _parseDTCResponse(String raw, String status) {
    // Format is typically 43 01 33 00 00 00 ... or 47 ... or 4A ...
    final clean = raw.replaceAll(' ', '').replaceAll('\r', '').replaceAll('\n', '').replaceAll('>', '').toUpperCase();
    if (clean.isEmpty || clean.contains('NODATA') || clean.contains('ERROR')) return [];

    final List<DTCModel> found = [];

    // Look for responses starting with 43, 47, or 4A
    final prefixes = ['43', '47', '4A'];
    for (var p in prefixes) {
      int idx = clean.indexOf(p);
      while (idx != -1 && idx + 2 <= clean.length) {
        final slice = clean.substring(idx + 2);
        // DTCs are 4 hex characters each
        for (int i = 0; i < slice.length; i += 4) {
          if (i + 4 > slice.length) break;
          final codeHex = slice.substring(i, i + 4);
          if (codeHex == "0000") continue; // Empty slot

          final a = int.tryParse(codeHex.substring(0, 2), radix: 16);
          if (a == null) continue;

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
          final rest = codeHex.substring(1);
          final fullCode = "$prefix$digit1$rest";

          String desc = 'Defecto detectado en el módulo de control';
          List<String> causes = ['Verificación con escáner recomendada'];
          List<String> symptoms = ['Luz de advertencia en tablero'];
          String action = 'Inspeccionar el circuito y sensores asociados';

          if (fullCode == 'P0171') {
            desc = 'Mezcla demasiado pobre (Banco 1)';
            causes = [
              'Fuga de vacío en mangueras de admisión o múltiple',
              'Sensor de Flujo de Masa de Aire (MAF) sucio o descalibrado',
              'Baja presión de combustible o inyectores tapados'
            ];
            symptoms = ['Ralentí inestable o vacilante', 'Pérdida de potencia en aceleración'];
            action = 'Limpiar sensor MAF e inspeccionar mangueras con prueba de vacío.';
          } else if (fullCode == 'P0301') {
            desc = 'Fallo de encendido detectado (Cilindro 1)';
            causes = [
              'Bujía desgastada o con electrodo con carbón',
              'Bobina de encendido defectuosa (Cilindro 1)',
              'Inyector obstruido o baja compresión'
            ];
            symptoms = ['Temblores y vibración en ralentí', 'Humo negro o pérdida de potencia'];
            action = 'Intercambiar bobina del cilindro 1 al 2 para descartar bobina.';
          } else if (fullCode == 'P0420') {
            desc = 'Eficiencia del Catalizador por Debajo del Umbral (Banco 1)';
            causes = [
              'Convertidor catalítico degradado o taponado',
              'Sensor de Oxígeno trasero (Downstream) defectuoso',
              'Fuga en escape antes del sensor secundario'
            ];
            symptoms = ['Olor a azufre en el escape', 'Aumento en consumo de gasolina'];
            action = 'Verificar señal de sensor O2 downstream con osciloscopio.';
          }

          found.add(DTCModel(
            code: fullCode,
            description: desc,
            severity: (prefix == 'P' || prefix == 'C') ? 'High' : 'Medium',
            system: 'OBD-II $prefix-System',
            status: status,
            timestamp: DateTime.now(),
            probableCauses: causes,
            symptoms: symptoms,
            recommendedAction: action,
          ));
        }

        idx = clean.indexOf(p, idx + 2);
      }
    }

    return found;
  }

  @override
  Future<void> clearDTCs() async {
    final wasPolling = _isPollingActive;
    _isPollingActive = false;
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      await sendCommand('04', timeout: const Duration(seconds: 3));
    } finally {
      if (wasPolling && _isConnected) {
        _startPolling();
      }
    }
  }

  @override
  Future<String?> readVIN() async {
    final wasPolling = _isPollingActive;
    _isPollingActive = false;
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      // Query Mode 09 PID 02 for Vehicle Identification Number
      final raw = await sendCommand('0902', timeout: const Duration(seconds: 3));
      final vin = _extractVINFromResponse(raw);
      if (vin != null && vin.length == 17) {
        debugPrint('Successfully extracted VIN: $vin');
        return vin;
      }
      return null;
    } catch (e) {
      debugPrint('Error reading VIN: $e');
      return null;
    } finally {
      if (wasPolling && _isConnected) {
        _startPolling();
      }
    }
  }

  String? _extractVINFromResponse(String raw) {
    // ELM327 multi-frame CAN responses look like:
    // 014
    // 0: 49 02 01 57 42 41
    // 1: 33 41 35 43 35 38
    // 2: 46 46 31 32 33 34
    // Or without line numbers: 49 02 01 31 47 31 ...
    final cleanLines = raw.split(RegExp(r'[\r\n]+'));
    final StringBuffer asciiBuffer = StringBuffer();

    for (var line in cleanLines) {
      var l = line.trim().replaceAll('>', '');
      // Remove line prefixes like "0:", "1:", "2:"
      if (RegExp(r'^[0-9]:').hasMatch(l)) {
        l = l.substring(2).trim();
      }

      // Remove hex spaces
      final tokens = l.split(RegExp(r'\s+'));
      for (var token in tokens) {
        if (token.length == 2) {
          final byte = int.tryParse(token, radix: 16);
          // Printable ASCII characters for VIN (A-Z, 0-9)
          if (byte != null && byte >= 0x30 && byte <= 0x5A) {
            asciiBuffer.write(String.fromCharCode(byte));
          }
        }
      }
    }

    final accumulated = asciiBuffer.toString();
    // A standard VIN is exactly 17 characters (alphanumeric, no I, O, Q)
    final vinMatch = RegExp(r'[A-HJ-NPR-Z0-9]{17}').firstMatch(accumulated);
    if (vinMatch != null) {
      return vinMatch.group(0);
    }

    if (accumulated.length >= 17) {
      return accumulated.substring(accumulated.length - 17);
    }

    return null;
  }

  @override
  Future<Map<String, bool>> readEmissionsReadiness() async {
    final wasPolling = _isPollingActive;
    _isPollingActive = false;
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Query Mode 01 PID 01 (Monitor status since DTCs cleared)
      final raw = await sendCommand('0101', timeout: const Duration(seconds: 2));
      final clean = raw.replaceAll(' ', '').replaceAll('\r', '').replaceAll('\n', '').replaceAll('>', '').toUpperCase();

      if (clean.contains('4101')) {
        final idx = clean.indexOf('4101');
        if (clean.length >= idx + 12) {
          final byteB = int.tryParse(clean.substring(idx + 6, idx + 8), radix: 16) ?? 0;
          final byteC = int.tryParse(clean.substring(idx + 8, idx + 10), radix: 16) ?? 0;
          final byteD = int.tryParse(clean.substring(idx + 10, idx + 12), radix: 16) ?? 0;

          // Continuous monitors (Byte B):
          // Bit 4: Misfire (0=Ready, 1=Not ready)
          final misfireReady = (byteB & (1 << 4)) == 0;
          // Bit 5: Fuel System (0=Ready, 1=Not ready)
          final fuelReady = (byteB & (1 << 5)) == 0;
          // Bit 6: Comprehensive Component (0=Ready, 1=Not ready)
          final ccmReady = (byteB & (1 << 6)) == 0;

          // Non-continuous monitors (Byte D completion: 0=Ready, 1=Not ready):
          // Bit 0: Catalyst
          final catalystReady = (byteD & (1 << 0)) == 0;
          // Bit 2: Evaporative System (EVAP) - if not supported by vehicle ECU, it is considered ready/passed
          final evapSupported = (byteC & (1 << 2)) != 0;
          final evapReady = !evapSupported || ((byteD & (1 << 2)) == 0);
          // Bit 5: O2 Sensor
          final o2Ready = (byteD & (1 << 5)) == 0;
          // Bit 6: O2 Heater
          final o2HeaterReady = (byteD & (1 << 6)) == 0;
          // Bit 7: EGR / VVT
          final egrReady = (byteD & (1 << 7)) == 0;

          return {
            'misfire': misfireReady,
            'fuel': fuelReady,
            'ccm': ccmReady,
            'catalyst': catalystReady,
            'evap': evapReady,
            'o2': o2Ready,
            'o2_heater': o2HeaterReady,
            'egr': egrReady,
          };
        }
      }

      // Default all to ready if standard response isn't formatted
      return {
        'misfire': true,
        'fuel': true,
        'ccm': true,
        'catalyst': true,
        'evap': true, // EVAP is ready by default
        'o2': true,
        'o2_heater': true,
        'egr': true,
      };
    } catch (e) {
      debugPrint('Error querying emissions readiness: $e');
      return {
        'misfire': true,
        'fuel': true,
        'ccm': true,
        'catalyst': true,
        'evap': true,
        'o2': true,
        'o2_heater': true,
        'egr': true,
      };
    } finally {
      if (wasPolling && _isConnected) {
        _startPolling();
      }
    }
  }
}

