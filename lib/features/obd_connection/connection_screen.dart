import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/obd_providers.dart';
import '../../core/services/ble/ble_service.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  String _selectedDeviceId = '';
  bool _isConnecting = false;

  final List<Map<String, dynamic>> _devices = [
    {
      'id': 'VGATE-BLE-409',
      'name': 'vGate iCar Pro BLE 4.0',
      'protocol': 'Auto Detect (ELM327 v2.2)',
      'signal': -58,
      'recommended': true,
      'device': null,
    },
    {
      'id': 'CARBYTE-SIM-01',
      'name': 'CARBYTE Simulator Link',
      'protocol': 'ISO 15765-4 (CAN 11/500)',
      'signal': -42,
      'recommended': false,
      'device': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
    
    // Listen to real BLE devices
    BLEService().scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        for (var r in results) {
          final id = r.device.remoteId.str;
          final name = r.device.platformName;
          final nameLower = name.toLowerCase();
          
          bool isObd = nameLower.contains('obd') || 
                       nameLower.contains('vgate') || 
                       nameLower.contains('vlink') || 
                       nameLower.contains('elm') || 
                       nameLower.contains('konnwei') || 
                       nameLower.contains('car') ||
                       nameLower.contains('ble');
                       
          // Avoid duplicates and non-OBD devices
          if (isObd && !_devices.any((d) => d['id'] == id)) {
            _devices.add({
              'id': id,
              'name': name.isNotEmpty ? name : 'Unknown Device',
              'protocol': 'BLE OBD',
              'signal': r.rssi,
              'recommended': false,
              'device': r.device,
            });
          }
        }
      });
    });
  }

  Future<void> _requestPermissionsAndScan() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses.values.every((status) => status.isGranted) || true) {
      await BLEService().startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionStateProvider);
    final isConnected = connectionAsync.value ?? false;
    final obdService = ref.watch(obdServiceProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          s.connectionScreenTitle,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppTheme.muted),
            onPressed: () => context.push('/onboarding'),
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppTheme.secondary),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.searchingObdSnack)),
              );
              await BLEService().startScan();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radar & Active Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isConnected ? AppTheme.cardGlowGradient : null,
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected ? AppTheme.secondary.withValues(alpha: 0.4) : AppTheme.border,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isConnected ? AppTheme.success : AppTheme.primary)
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        Icon(
                          isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_searching_rounded,
                          size: 40,
                          color: isConnected ? AppTheme.success : AppTheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isConnected ? s.adapterLinked : s.searchingDevices,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isConnected ? AppTheme.success : AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isConnected
                          ? s.linkActiveStable
                          : s.ensureAdapterPlugged,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Connect Button
              if (!isConnected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: InkWell(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        SnackBar(content: Text(s.searchingObdSnack)),
                      );
                      setState(() => _isConnecting = true);
                      await _requestPermissionsAndScan();
                      
                      // Auto connect logic
                      Future.delayed(const Duration(seconds: 3), () async {
                        if (!mounted) return;
                        final realDevices = _devices.where((d) => d['device'] != null).toList();
                        
                        if (realDevices.isNotEmpty) {
                          final target = realDevices.first;
                          final ok = await BLEService().connectToDevice(target['device']);
                          if (ok) {
                            ref.read(mockModeProvider.notifier).state = false;
                            await Future.delayed(const Duration(milliseconds: 50));
                            final currentObdService = ref.read(obdServiceProvider);
                            await currentObdService.connect();
                            if (mounted) {
                              setState(() {
                                _selectedDeviceId = target['id'];
                                _isConnecting = false;
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('${s.connectedToDeviceSnack} ${target['name']}'),
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            }
                            return;
                          }
                        }

                        // No real device found or connection failed
                        if (!mounted) return;
                        setState(() => _isConnecting = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(s.noDeviceFoundSnack),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isConnecting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.background),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt_rounded, color: AppTheme.background),
                                  const SizedBox(width: 8),
                                  Text(
                                    s.quickConnectAuto,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.background,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

              Text(
                s.availableDevices,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.muted,
                ),
              ),

              const SizedBox(height: 12),

              ..._devices
                  .where((d) => ref.watch(mockModeProvider) ? true : d['device'] != null)
                  .map((device) => _buildDeviceCard(device, isConnected, obdService, s)),

              const SizedBox(height: 20),

              // Capabilities Inspection
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          s.detectedProtocols,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.detectedProtocolsSubtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.muted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCapabilityBadge(s.mode03Read, true),
                        _buildCapabilityBadge(s.mode04Clear, true),
                        _buildCapabilityBadge(s.mode01Telemetry, true),
                        _buildCapabilityBadge(s.mode09Vin, true),
                        _buildCapabilityBadge(s.mode02FreezeFrame, true),
                        _buildCapabilityBadge(s.ecuCoding, false),
                        _buildCapabilityBadge(s.workshopAdaptations, false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device, bool isConnected, dynamic obdService, dynamic s) {
    final isSelected = _selectedDeviceId == device['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected && isConnected ? AppTheme.secondary : AppTheme.border,
          width: isSelected && isConnected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            setState(() {
              _selectedDeviceId = device['id'];
              _isConnecting = true;
            });
            
            bool connectionSuccess = true;
            bool isMock = true;
            if (device['device'] != null) {
              connectionSuccess = await BLEService().connectToDevice(device['device']);
              isMock = false;
            }

            if (connectionSuccess) {
              ref.read(mockModeProvider.notifier).state = isMock;
              await Future.delayed(const Duration(milliseconds: 50));
              final currentObdService = ref.read(obdServiceProvider);
              await currentObdService.connect();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${s.connectedToDeviceSnack} ${device['name']}'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${s.connectionErrorSnack} ${device['name']}'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            }
            
            setState(() {
              _isConnecting = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.developer_board_rounded,
                  color: isSelected && isConnected ? AppTheme.secondary : AppTheme.muted,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device['name'],
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (device['recommended'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s.recommendedBadge,
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${device['protocol']} • RSSI: ${device['signal']} dBm',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                if (_isConnecting && isSelected)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondary),
                  )
                else
                  Icon(
                    isSelected && isConnected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                    color: isSelected && isConnected ? AppTheme.success : AppTheme.muted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityBadge(String label, bool supported) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: supported ? AppTheme.primary.withValues(alpha: 0.12) : AppTheme.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: supported ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            supported ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            size: 13,
            color: supported ? AppTheme.secondary : AppTheme.muted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: supported ? AppTheme.text : AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
