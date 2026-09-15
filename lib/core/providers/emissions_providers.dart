import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/locale_provider.dart';
import 'obd_providers.dart';

class EmissionsMonitor {
  final String key;
  final String name;
  final String description;
  final bool isReady;
  final bool isApplicable;

  const EmissionsMonitor({
    this.key = '',
    required this.name,
    required this.description,
    required this.isReady,
    this.isApplicable = true,
  });

  EmissionsMonitor copyWith({
    String? key,
    String? name,
    String? description,
    bool? isReady,
    bool? isApplicable,
  }) {
    return EmissionsMonitor(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      isReady: isReady ?? this.isReady,
      isApplicable: isApplicable ?? this.isApplicable,
    );
  }
}

class SmogReadinessState {
  final bool isPassed;
  final int readyCount;
  final int totalCount;
  final List<EmissionsMonitor> monitors;

  const SmogReadinessState({
    required this.isPassed,
    required this.readyCount,
    required this.totalCount,
    required this.monitors,
  });
}

class EmissionsNotifier extends StateNotifier<SmogReadinessState> {
  final Ref _ref;
  Map<String, bool> _lastReadiness = const {};

  EmissionsNotifier(this._ref) : super(_buildState(_ref.read(stringsProvider), const {})) {
    // Re-evaluate when connected to OBD
    _ref.listen<AsyncValue<bool>>(connectionStateProvider, (previous, next) {
      if (next.value == true) {
        refreshReadiness();
      }
    });

    // Re-localize when language changes
    _ref.listen<AppStrings>(stringsProvider, (previous, next) {
      state = _buildState(next, _lastReadiness);
    });
  }

  static SmogReadinessState _buildState(AppStrings s, Map<String, bool> readiness) {
    final monitors = [
      EmissionsMonitor(
        key: 'misfire',
        name: s.monitorMisfire,
        description: s.monitorMisfireDesc,
        isReady: readiness['misfire'] ?? true,
      ),
      EmissionsMonitor(
        key: 'fuel',
        name: s.monitorFuelSystem,
        description: s.monitorFuelSystemDesc,
        isReady: readiness['fuel'] ?? true,
      ),
      EmissionsMonitor(
        key: 'ccm',
        name: s.monitorCcm,
        description: s.monitorCcmDesc,
        isReady: readiness['ccm'] ?? true,
      ),
      EmissionsMonitor(
        key: 'catalyst',
        name: s.monitorCatalyst,
        description: s.monitorCatalystDesc,
        isReady: readiness['catalyst'] ?? true,
      ),
      EmissionsMonitor(
        key: 'evap',
        name: s.monitorEvap,
        description: s.monitorEvapDesc,
        isReady: readiness['evap'] ?? true, // Dynamic and defaults to true
      ),
      EmissionsMonitor(
        key: 'o2',
        name: s.monitorO2Sensor,
        description: s.monitorO2SensorDesc,
        isReady: readiness['o2'] ?? true,
      ),
      EmissionsMonitor(
        key: 'o2_heater',
        name: s.monitorO2Heater,
        description: s.monitorO2HeaterDesc,
        isReady: readiness['o2_heater'] ?? true,
      ),
      EmissionsMonitor(
        key: 'egr',
        name: s.monitorEgr,
        description: s.monitorEgrDesc,
        isReady: readiness['egr'] ?? true,
      ),
    ];

    final readyCount = monitors.where((m) => m.isReady).length;
    final isPassed = (monitors.length - readyCount) <= 1;

    return SmogReadinessState(
      isPassed: isPassed,
      readyCount: readyCount,
      totalCount: monitors.length,
      monitors: monitors,
    );
  }

  Future<void> refreshReadiness() async {
    final obdService = _ref.read(obdServiceProvider);
    try {
      _lastReadiness = await obdService.readEmissionsReadiness();
    } catch (_) {
      _lastReadiness = const {};
    }
    final s = _ref.read(stringsProvider);
    state = _buildState(s, _lastReadiness);
  }
}

final emissionsMonitorsProvider = StateNotifierProvider<EmissionsNotifier, SmogReadinessState>((ref) {
  return EmissionsNotifier(ref);
});
