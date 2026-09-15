import '../../../shared/models/dtc_model.dart';

abstract class OBDService {
  Stream<bool> get connectionState;
  Stream<double> get rpmStream;
  Stream<double> get speedStream;
  Stream<double> get coolantTempStream;
  Stream<double> get engineLoadStream;
  
  // Additional streams
  Stream<double> get throttleStream;
  Stream<double> get batteryVoltageStream;
  Stream<double> get intakeTempStream;
  Stream<double> get mafStream;
  Stream<double> get turboBoostStream; // In Bar or PSI

  Future<void> connect();
  Future<void> disconnect();
  
  Future<List<DTCModel>> scanDTCs();
  Future<void> clearDTCs();
  
  Future<String?> readVIN();
}
