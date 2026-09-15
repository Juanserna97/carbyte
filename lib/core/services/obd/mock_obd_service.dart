import 'dart:async';
import 'dart:math';
import 'obd_service.dart';
import '../../../shared/models/dtc_model.dart';

class MockOBDService implements OBDService {
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

  Timer? _dataTimer;
  bool _isConnected = false; // Start DISCONNECTED by default
  final Random _random = Random();

  double _currentRpm = 0;
  double _currentSpeed = 0;

  MockOBDService() {
    // Wait for explicit connect() call from user
  }

  @override
  Stream<bool> get connectionState async* {
    yield _isConnected;
    yield* _connectionController.stream;
  }

  @override
  Stream<double> get rpmStream async* {
    yield _isConnected ? _currentRpm : 0.0;
    yield* _rpmController.stream;
  }

  @override
  Stream<double> get speedStream async* {
    yield _isConnected ? _currentSpeed : 0.0;
    yield* _speedController.stream;
  }

  @override
  Stream<double> get coolantTempStream async* {
    yield _isConnected ? 89.0 : 0.0;
    yield* _coolantController.stream;
  }

  @override
  Stream<double> get engineLoadStream async* {
    yield _isConnected ? 28.0 : 0.0;
    yield* _loadController.stream;
  }

  @override
  Stream<double> get throttleStream async* {
    yield _isConnected ? 14.0 : 0.0;
    yield* _throttleController.stream;
  }

  @override
  Stream<double> get batteryVoltageStream async* {
    yield _isConnected ? 14.1 : 0.0;
    yield* _batteryController.stream;
  }

  @override
  Stream<double> get intakeTempStream async* {
    yield _isConnected ? 26.0 : 0.0;
    yield* _intakeTempController.stream;
  }

  @override
  Stream<double> get mafStream async* {
    yield _isConnected ? 3.8 : 0.0;
    yield* _mafController.stream;
  }

  @override
  Stream<double> get turboBoostStream async* {
    yield _isConnected ? 0.0 : 0.0;
    yield* _turboBoostController.stream;
  }

  bool get isConnected => _isConnected;

  @override
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 900));
    _isConnected = true;
    _currentRpm = 1840;
    _currentSpeed = 48;
    _connectionController.add(true);
    _startSimulatingData();
  }

  @override
  Future<void> disconnect() async {
    _dataTimer?.cancel();
    _isConnected = false;
    _connectionController.add(false);
    _currentRpm = 0;
    _currentSpeed = 0;
    _rpmController.add(0);
    _speedController.add(0);
    _coolantController.add(0);
    _loadController.add(0);
    _throttleController.add(0);
    _batteryController.add(0);
    _intakeTempController.add(0);
    _mafController.add(0);
    _turboBoostController.add(0);
  }

  void _startSimulatingData() {
    _dataTimer?.cancel();
    _dataTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!_isConnected) return;
      
      // Simulate realistic engine fluctuations
      _currentRpm = (_currentRpm + (_random.nextDouble() * 120 - 55)).clamp(750, 4500);
      _currentSpeed = (_currentSpeed + (_random.nextDouble() * 4 - 1.8)).clamp(0, 160);

      _rpmController.add(_currentRpm);
      _speedController.add(_currentSpeed);
      _coolantController.add(89 + _random.nextDouble() * 3);
      _loadController.add(28 + _random.nextDouble() * 15);
      _throttleController.add(14 + (_currentSpeed * 0.25) + (_random.nextDouble() * 4));
      _batteryController.add(14.1 + _random.nextDouble() * 0.25);
      _intakeTempController.add(26 + _random.nextDouble() * 2);
      _mafController.add(3.8 + (_currentRpm / 600) + _random.nextDouble() * 0.5);
      // Simulate turbo boost: 0 to 1.2 Bar depending on RPM and Load
      final boost = ((_currentRpm - 1500) / 3000 * 1.2).clamp(0.0, 1.2) + (_random.nextDouble() * 0.1);
      _turboBoostController.add(boost);
    });
  }

  @override
  Future<List<DTCModel>> scanDTCs() async {
    await Future.delayed(const Duration(seconds: 3));
    return [
      DTCModel(
        code: 'P0301',
        description: 'Cylinder 1 Misfire Detected',
        severity: 'High',
        system: 'Powertrain / Engine',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      DTCModel(
        code: 'P0171',
        description: 'System Too Lean (Bank 1)',
        severity: 'Medium',
        system: 'Fuel & Air Metering',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      DTCModel(
        code: 'P0420',
        description: 'Catalyst System Efficiency Below Threshold (Bank 1)',
        severity: 'Medium',
        system: 'Emissions Control',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<void> clearDTCs() async {
    // simulate delay
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<String?> readVIN() async {
    await Future.delayed(const Duration(seconds: 1));
    return '1G1RC6E45BUXXXXXX'; // Mock Chevrolet Volt VIN
  }
}
