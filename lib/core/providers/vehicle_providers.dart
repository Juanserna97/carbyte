import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/vin_decoder_service.dart';
import 'obd_providers.dart';

class VehicleState {
  final String vin;
  final String vehicleName;
  final bool isLoading;

  const VehicleState({
    this.vin = '',
    this.vehicleName = 'Desconectado',
    this.isLoading = false,
  });

  VehicleState copyWith({String? vin, String? vehicleName, bool? isLoading}) {
    return VehicleState(
      vin: vin ?? this.vin,
      vehicleName: vehicleName ?? this.vehicleName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VehicleNotifier extends StateNotifier<VehicleState> {
  final Ref _ref;
  final VINDecoderService _decoderService = VINDecoderService();

  VehicleNotifier(this._ref) : super(const VehicleState(vehicleName: 'Desconectado')) {
    // Automatically try to resolve VIN when connection state changes to true
    _ref.listen<AsyncValue<bool>>(connectionStateProvider, (previous, next) {
      if (next.value == true) {
        _fetchVehicleInfo();
      } else {
        state = const VehicleState(vehicleName: 'Desconectado');
      }
    });
  }

  Future<void> _fetchVehicleInfo() async {
    state = state.copyWith(isLoading: true, vehicleName: 'Leyendo VIN del puerto OBD...');
    
    final obdService = _ref.read(obdServiceProvider);
    final vin = await obdService.readVIN();

    if (vin != null && vin.isNotEmpty) {
      state = state.copyWith(vin: vin, vehicleName: 'Decodificando VIN...');
      final name = await _decoderService.decodeVIN(vin);
      state = state.copyWith(isLoading: false, vehicleName: name);
    } else {
      state = state.copyWith(isLoading: false, vehicleName: 'Vehículo Desconocido');
    }
  }
}

final vehicleProvider = StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier(ref);
});
