import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmissionsMonitor {
  final String name;
  final String description;
  final bool isReady;
  final bool isApplicable;

  const EmissionsMonitor({
    required this.name,
    required this.description,
    required this.isReady,
    this.isApplicable = true,
  });
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

final emissionsMonitorsProvider = Provider<SmogReadinessState>((ref) {
  final monitors = [
    const EmissionsMonitor(
      name: 'Fallo de Encendido (Misfire)',
      description: 'Supervisa detonaciones erráticas en los cilindros',
      isReady: true,
    ),
    const EmissionsMonitor(
      name: 'Sistema de Combustible',
      description: 'Control de mezcla aire/combustible y bucle cerrado',
      isReady: true,
    ),
    const EmissionsMonitor(
      name: 'Componentes Globales (CCM)',
      description: 'Supervisa sensores analógicos y actuadores clave',
      isReady: true,
    ),
    const EmissionsMonitor(
      name: 'Convertidor Catalítico',
      description: 'Eficiencia en reducción de gases NOx y CO',
      isReady: true,
    ),
    const EmissionsMonitor(
      name: 'Sistema Evaporativo (EVAP)',
      description: 'Captura y purga de vapores del tanque de gasolina',
      isReady: false,
    ),
    const EmissionsMonitor(
      name: 'Sensores de Oxígeno (O2)',
      description: 'Respuesta y conmutación de sensores delantero y trasero',
      isReady: true,
    ),
    const EmissionsMonitor(
      name: 'Calefactor Sensor O2',
      description: 'Resistencia calefactora para temperatura de operación',
      isReady: true,
    ),
    const EmissionsMonitor(
      name: 'Sistema EGR / VVT',
      description: 'Recirculación de escape y variación de válvulas',
      isReady: true,
    ),
  ];

  final readyCount = monitors.where((m) => m.isReady).length;
  // Standard emission rule: usually allowed at most 1 monitor incomplete on newer vehicles
  final isPassed = (monitors.length - readyCount) <= 1;

  return SmogReadinessState(
    isPassed: isPassed,
    readyCount: readyCount,
    totalCount: monitors.length,
    monitors: monitors,
  );
});
