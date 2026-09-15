import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/obd/mock_obd_service.dart';
import '../services/obd/real_obd_service.dart';
import '../services/obd/obd_service.dart';
import '../../shared/models/dtc_model.dart';

// Toggles between mock data (simulator) and real BLE data
final mockModeProvider = StateProvider<bool>((ref) => false);

final obdServiceProvider = Provider<OBDService>((ref) {
  final isMock = ref.watch(mockModeProvider);
  final OBDService service = isMock ? MockOBDService() : RealOBDService();
  ref.onDispose(() => service.disconnect());
  return service;
});

final connectionStateProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.connectionState;
});

final rpmStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.rpmStream;
});

final speedStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.speedStream;
});

final coolantTempStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.coolantTempStream;
});

final engineLoadStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.engineLoadStream;
});

final throttleStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.throttleStream;
});

final batteryStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.batteryVoltageStream;
});

final intakeTempStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.intakeTempStream;
});

final mafStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.mafStream;
});

final turboBoostStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.turboBoostStream;
});

final stftStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.stftStream;
});

final ltftStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.ltftStream;
});

final timingAdvanceStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.timingAdvanceStream;
});

final fuelLevelStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.fuelLevelStream;
});

final baroStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(obdServiceProvider);
  return service.baroStream;
});

// Diagnostic scan state
class ScanState {
  static const List<String> defaultModules = [
    'ENGINE (PCM / ECM)',
    'TRANSMISSION (TCM)',
    'ANTI-LOCK BRAKING (ABS / ESP)',
    'AIRBAG / RESTRAINT (SRS)',
    'BODY CONTROL MODULE (BCM)',
    'EXHAUST & CATALYST SENSORS',
  ];

  final bool isScanning;
  final double progress;
  final String currentModule;
  final List<String> modulesList;
  final List<String> completedModules;
  final List<DTCModel> foundDTCs;
  final bool isFinished;

  const ScanState({
    this.isScanning = false,
    this.progress = 0.0,
    this.currentModule = '',
    this.modulesList = defaultModules,
    this.completedModules = const [],
    this.foundDTCs = const [],
    this.isFinished = false,
  });

  ScanState copyWith({
    bool? isScanning,
    double? progress,
    String? currentModule,
    List<String>? modulesList,
    List<String>? completedModules,
    List<DTCModel>? foundDTCs,
    bool? isFinished,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      progress: progress ?? this.progress,
      currentModule: currentModule ?? this.currentModule,
      modulesList: modulesList ?? this.modulesList,
      completedModules: completedModules ?? this.completedModules,
      foundDTCs: foundDTCs ?? this.foundDTCs,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class DiagnosticNotifier extends StateNotifier<ScanState> {
  final OBDService _service;

  DiagnosticNotifier(this._service) : super(const ScanState());

  Future<void> startScan() async {
    state = const ScanState(isScanning: true, progress: 0.0, currentModule: 'Initializing OBD-II Bus...');
    
    final modules = ScanState.defaultModules;

    final completed = <String>[];

    for (int i = 0; i < modules.length; i++) {
      if (!mounted) return; // Prevent updating state if disposed
      await Future.delayed(const Duration(milliseconds: 650));
      completed.add(modules[i]);
      final nextModule = (i + 1 < modules.length) ? modules[i + 1] : 'Finalizing Diagnostics...';
      if (!mounted) return;
      state = state.copyWith(
        progress: (i + 1) / modules.length,
        currentModule: nextModule,
        completedModules: List.from(completed),
      );
    }

    final dtcs = await _service.scanDTCs();
    if (!mounted) return;
    state = state.copyWith(
      isScanning: false,
      isFinished: true,
      progress: 1.0,
      currentModule: 'Completed',
      foundDTCs: dtcs,
    );
  }

  void reset() {
    state = const ScanState();
  }

  Future<void> clearDTCs() async {
    await _service.clearDTCs();
    state = state.copyWith(foundDTCs: []);
  }
}

final diagnosticScanProvider = StateNotifierProvider<DiagnosticNotifier, ScanState>((ref) {
  final service = ref.watch(obdServiceProvider);
  return DiagnosticNotifier(service);
});
