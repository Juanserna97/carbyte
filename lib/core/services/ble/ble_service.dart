import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  // Singleton pattern for easy access
  static final BLEService _instance = BLEService._internal();
  factory BLEService() => _instance;
  BLEService._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? readCharacteristic;

  final StreamController<List<int>> _dataController = StreamController<List<int>>.broadcast();
  StreamSubscription<List<int>>? _notifySubscription;

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  // Stream for incoming raw byte chunks from the OBD adapter
  Stream<List<int>> get dataStream => _dataController.stream;

  Future<void> startScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('Error starting scan: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await stopScan();
      
      // Cancel previous notify subscription if any
      await _notifySubscription?.cancel();
      _notifySubscription = null;
      writeCharacteristic = null;
      readCharacteristic = null;

      await device.connect(autoConnect: false, license: License.nonprofit);
      connectedDevice = device;

      // Try requesting MTU if supported
      try {
        await device.requestMtu(512);
      } catch (_) {}

      // Discover services to find the OBD serial UART characteristics
      List<BluetoothService> services = await device.discoverServices();
      final found = await _findCharacteristics(services);

      if (!found) {
        debugPrint('Warning: No suitable OBD-II UART characteristics found on device ${device.platformName}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Failed to connect to ${device.platformName}: $e');
      return false;
    }
  }

  Future<bool> _findCharacteristics(List<BluetoothService> services) async {
    // Known OBD BLE UART Service UUID prefixes (lowercase)
    // - fff0: Vgate iCar Pro, Veepeak BLE+, OBDLink CX, generic ELM327
    // - ffe0: HM-10, CC2541, generic BLE
    // - 6e400001: Nordic Semiconductor UART (nRF51822 / nRF52832)
    // - 49535343: ISSC Microchip IS1678 UART
    // - 18f0: Standard OBD BLE profile
    // - e7810a71: Carista
    final knownServiceUuids = [
      'fff0',
      'ffe0',
      '6e400001',
      '49535343',
      '0000fff0',
      '0000ffe0',
      '18f0',
      'e7810a71',
    ];

    BluetoothService? targetService;

    // 1. Try to find a matching known UART service first
    for (var service in services) {
      final sUuid = service.uuid.str128.toLowerCase();
      if (knownServiceUuids.any((k) => sUuid.contains(k))) {
        targetService = service;
        break;
      }
    }

    // 2. If no known UUID matched, pick a service that is NOT standard Bluetooth GAP/GATT
    // (ignore 1800 Generic Access, 1801 Generic Attribute, 180a Device Information)
    if (targetService == null) {
      for (var service in services) {
        final sUuid = service.uuid.str128.toLowerCase();
        final isStandard = sUuid.contains('1800') ||
            sUuid.contains('1801') ||
            sUuid.contains('180a') ||
            sUuid.contains('180f'); // Battery
        if (!isStandard) {
          // Check if it has both write and notify capabilities
          bool hasWrite = false;
          bool hasNotify = false;
          for (var c in service.characteristics) {
            if (c.properties.write || c.properties.writeWithoutResponse) hasWrite = true;
            if (c.properties.notify || c.properties.indicate) hasNotify = true;
          }
          if (hasWrite && hasNotify) {
            targetService = service;
            break;
          }
        }
      }
    }

    if (targetService != null) {
      debugPrint('Selected OBD UART service: ${targetService.uuid.str128}');

      // In the selected service, assign write and read/notify characteristics
      for (var c in targetService.characteristics) {
        if (c.properties.notify || c.properties.indicate) {
          readCharacteristic = c;
        }
        if (c.properties.write || c.properties.writeWithoutResponse) {
          writeCharacteristic = c;
        }
      }

      // If one characteristic does both (e.g. FFE1)
      if (readCharacteristic == null && writeCharacteristic != null) {
        if (writeCharacteristic!.properties.notify || writeCharacteristic!.properties.read) {
          readCharacteristic = writeCharacteristic;
        }
      } else if (writeCharacteristic == null && readCharacteristic != null) {
        if (readCharacteristic!.properties.write || readCharacteristic!.properties.writeWithoutResponse) {
          writeCharacteristic = readCharacteristic;
        }
      }
    }

    // Fallback: search across all characteristics if still null
    if (readCharacteristic == null || writeCharacteristic == null) {
      for (var s in services) {
        final sUuid = s.uuid.str128.toLowerCase();
        if (sUuid.contains('1800') || sUuid.contains('1801') || sUuid.contains('180a')) continue;
        for (var c in s.characteristics) {
          if ((c.properties.notify || c.properties.indicate) && readCharacteristic == null) {
            readCharacteristic = c;
          }
          if ((c.properties.write || c.properties.writeWithoutResponse) && writeCharacteristic == null) {
            writeCharacteristic = c;
          }
        }
      }
    }

    if (readCharacteristic != null && writeCharacteristic != null) {
      debugPrint('Found Read Char: ${readCharacteristic!.uuid.str128} (notify=${readCharacteristic!.properties.notify})');
      debugPrint('Found Write Char: ${writeCharacteristic!.uuid.str128}');

      try {
        if (readCharacteristic!.properties.notify || readCharacteristic!.properties.indicate) {
          await readCharacteristic!.setNotifyValue(true);
        }
        _notifySubscription = readCharacteristic!.onValueReceived.listen((bytes) {
          if (bytes.isNotEmpty) {
            _dataController.add(bytes);
          }
        });
        return true;
      } catch (e) {
        debugPrint('Error enabling notify on characteristic: $e');
        return false;
      }
    }

    return false;
  }

  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('Error disconnecting device: $e');
      }
      connectedDevice = null;
      writeCharacteristic = null;
      readCharacteristic = null;
    }
  }

  Future<void> writeData(List<int> data) async {
    if (writeCharacteristic != null) {
      try {
        await writeCharacteristic!.write(
          data,
          withoutResponse: writeCharacteristic!.properties.writeWithoutResponse,
        );
      } catch (e) {
        debugPrint('Error writing to OBD characteristic: $e');
      }
    }
  }
}
