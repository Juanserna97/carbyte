import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/vin_decoder_service.dart';
import '../services/obd/real_obd_service.dart';
import 'obd_providers.dart';
import '../localization/locale_provider.dart';

class VehicleState {
  final String vin;
  final String vehicleName;
  final String subtitle;
  final bool isLoading;

  const VehicleState({
    this.vin = '',
    this.vehicleName = '',
    this.subtitle = '',
    this.isLoading = false,
  });

  VehicleState copyWith({
    String? vin,
    String? vehicleName,
    String? subtitle,
    bool? isLoading,
  }) {
    return VehicleState(
      vin: vin ?? this.vin,
      vehicleName: vehicleName ?? this.vehicleName,
      subtitle: subtitle ?? this.subtitle,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VehicleNotifier extends StateNotifier<VehicleState> {
  final Ref _ref;
  final VINDecoderService _decoderService = VINDecoderService();

  VehicleNotifier(this._ref) : super(const VehicleState()) {
    // Automatically try to resolve VIN when connection state changes to true
    _ref.listen<AsyncValue<bool>>(connectionStateProvider, (previous, next) {
      if (next.value == true) {
        _fetchVehicleInfo();
      } else {
        final s = _ref.read(stringsProvider);
        state = VehicleState(
          vehicleName: s.vehicleDisconnectedTitle,
          subtitle: s.vehicleDisconnectedSubtitle,
        );
      }
    });
  }

  Future<void> _fetchVehicleInfo() async {
    final s = _ref.read(stringsProvider);
    state = state.copyWith(
      isLoading: true,
      vehicleName: s.connectedVehicle,
      subtitle: s.readingVin,
    );

    final obdService = _ref.read(obdServiceProvider);
    final vin = await obdService.readVIN();

    if (vin != null && vin.isNotEmpty) {
      state = state.copyWith(
        vin: vin,
        subtitle: s.decodingVin,
      );

      final name = await _decoderService.decodeVIN(vin);

      if (name == 'Vehículo Desconocido' || name == 'Error de Conexión') {
        state = state.copyWith(
          isLoading: false,
          vehicleName: s.connectedVehicle,
          subtitle: 'VIN: $vin • ${s.activeObdLink}',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          vehicleName: name,
          subtitle: 'VIN: $vin • ISO 15765-4 (CAN)',
        );
      }
    } else {
      // Vehicle connected over OBD, but VIN Mode 09 PID 02 not exposed by ECU
      String protoDesc = '';
      if (obdService is RealOBDService && obdService.detectedProtocol.isNotEmpty) {
        protoDesc = '${obdService.detectedProtocol} • ';
      }
      state = state.copyWith(
        isLoading: false,
        vehicleName: s.connectedVehicle,
        subtitle: '$protoDesc${s.activeObdLink}',
      );
    }
  }
}

final vehicleProvider = StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier(ref);
});
