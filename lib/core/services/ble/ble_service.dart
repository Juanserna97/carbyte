import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  // Singleton pattern for easy access
  static final BLEService _instance = BLEService._internal();
  factory BLEService() => _instance;
  BLEService._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? readCharacteristic;

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan() async {
    // Start scanning for 10 seconds
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      print('Error starting scan: $e');
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await stopScan();
      await device.connect(autoConnect: false, license: License.nonprofit);
      connectedDevice = device;
      
      // Discover services to find the serial port characteristics
      List<BluetoothService> services = await device.discoverServices();
      _findCharacteristics(services);
      
      return true;
    } catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  void _findCharacteristics(List<BluetoothService> services) {
    // Typical OBD BLE adapters use specific UART services (e.g. FFF0, 0xFFE0, etc.)
    // We will look for characteristics that support read/notify and write.
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify || characteristic.properties.read) {
          readCharacteristic ??= characteristic; // pick first suitable
        }
        if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
          writeCharacteristic ??= characteristic;
        }
      }
    }

    if (readCharacteristic != null && readCharacteristic!.properties.notify) {
      readCharacteristic!.setNotifyValue(true);
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      writeCharacteristic = null;
      readCharacteristic = null;
    }
  }

  // Stream for incoming data
  Stream<List<int>>? get dataStream {
    return readCharacteristic?.lastValueStream;
  }

  Future<void> writeData(List<int> data) async {
    if (writeCharacteristic != null) {
      await writeCharacteristic!.write(data, withoutResponse: writeCharacteristic!.properties.writeWithoutResponse);
    }
  }
}
