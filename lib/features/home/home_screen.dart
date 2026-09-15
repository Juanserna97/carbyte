import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/obd_providers.dart';
import '../../core/providers/vehicle_providers.dart';
import '../../core/localization/locale_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final rpmAsync = ref.watch(rpmStreamProvider);
    final speedAsync = ref.watch(speedStreamProvider);
    final coolantAsync = ref.watch(coolantTempStreamProvider);
    final batteryAsync = ref.watch(batteryStreamProvider);
    final connectionAsync = ref.watch(connectionStateProvider);
    final vehicleState = ref.watch(vehicleProvider);

    final isConnected = connectionAsync.value ?? false;
    final isMockMode = ref.watch(mockModeProvider);
    final obdService = ref.watch(obdServiceProvider);

    final currentRpm = isConnected ? (rpmAsync.value ?? 0) : 0;
    final currentSpeed = isConnected ? (speedAsync.value ?? 0) : 0;
    final coolantTemp = isConnected ? (coolantAsync.value ?? 0) : 0;
    final batteryVolt = isConnected ? (batteryAsync.value ?? 0.0) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Brand and Connection Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'Assets/carbyte_logo.png',
                        height: 28,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.speed_rounded,
                          color: AppTheme.secondary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/connection'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppTheme.success.withValues(alpha: 0.12)
                            : AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isConnected
                              ? AppTheme.success.withValues(alpha: 0.4)
                              : AppTheme.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConnected ? AppTheme.success : AppTheme.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isConnected ? AppTheme.success : AppTheme.error)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? s.connected : s.disconnected,
                            style: GoogleFonts.outfit(
                              color: isConnected ? AppTheme.success : AppTheme.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppTheme.muted, size: 22),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Vehicle Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF131922), Color(0xFF0D1219)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isConnected ? vehicleState.vehicleName : s.vehicleDisconnectedTitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isConnected ? AppTheme.text : AppTheme.muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isConnected
                                    ? '4MATIC+ • 2.0L Turbo • 382 HP • 2024'
                                    : s.vehicleDisconnectedSubtitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isConnected ? AppTheme.secondary : AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Health Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isConnected ? AppTheme.primary : AppTheme.surface)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isConnected ? AppTheme.primary : AppTheme.border)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isConnected ? '88%' : '--',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isConnected ? AppTheme.secondary : AppTheme.muted,
                                ),
                              ),
                              Text(
                                'HEALTH',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.muted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppTheme.border),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fingerprint_rounded, size: 16, color: AppTheme.muted),
                            const SizedBox(width: 6),
                            Text(
                              isConnected
                                  ? (vehicleState.vin.isNotEmpty
                                      ? 'VIN: ${vehicleState.vin}'
                                      : 'VIN: WDD1569461J839210')
                                  : s.vehicleVinNotDetected,
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 11,
                                color: AppTheme.muted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isConnected ? 'ISO 15765-4 (CAN)' : s.vehicleStandbyProtocol,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Quick Connect Banner (when disconnected)
              if (!isConnected) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondary.withValues(alpha: 0.15),
                        AppTheme.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.power_settings_new_rounded,
                              color: AppTheme.secondary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.connectionRequiredTitle,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isMockMode
                                      ? s.connectionRequiredSubtitleMock
                                      : s.connectionRequiredSubtitleReal,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => context.push('/connection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bluetooth_searching_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                s.btnConnectObd,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () async {
                            ref.read(mockModeProvider.notifier).state = true;
                            await ref.read(obdServiceProvider).connect();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppTheme.secondary.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                            foregroundColor: AppTheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_circle_outline_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                s.btnSimulateTelemetry,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ] else ...[
                // Active Issues Alert Banner (High impact)
                InkWell(
                  onTap: () => context.push('/diagnostics'),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppTheme.alertGlowGradient,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.error.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.error,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${ref.watch(diagnosticScanProvider).foundDTCs.length} ${s.activeIssuesTitle}',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.error,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: ref.watch(diagnosticScanProvider).foundDTCs.isEmpty
                                    ? [_buildDtcBadge(s.noActiveIssues)]
                                    : ref
                                        .watch(diagnosticScanProvider)
                                        .foundDTCs
                                        .take(3)
                                        .map((d) => _buildDtcBadge(d.code))
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              const SizedBox(height: 20),

              // Live Telemetry Mini Dashboard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.liveTelemetryTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTheme.muted,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push('/live_data'),
                    child: Text(
                      '${s.fullScreen} →',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Telemetry Bento Grid
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      title: s.rpmMotor,
                      value: currentRpm.toInt().toString(),
                      unit: 'RPM',
                      icon: Icons.speed_rounded,
                      accentColor: AppTheme.secondary,
                      progress: (currentRpm / 6500).clamp(0.0, 1.0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTelemetryCard(
                      title: s.speedKmH,
                      value: currentSpeed.toInt().toString(),
                      unit: 'KM/H',
                      icon: Icons.navigation_rounded,
                      accentColor: AppTheme.primary,
                      progress: (currentSpeed / 240).clamp(0.0, 1.0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSimpleMetricCard(
                      title: s.coolant,
                      value: '${coolantTemp.toInt()}°C',
                      status: s.statusNormal,
                      icon: Icons.thermostat_rounded,
                      isWarning: coolantTemp > 105,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSimpleMetricCard(
                      title: s.battery,
                      value: '${batteryVolt.toStringAsFixed(1)} V',
                      status: s.statusOptimal,
                      icon: Icons.battery_charging_full_rounded,
                      isWarning: batteryVolt < 12.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons (Only when connected)
              if (isConnected) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.push('/diagnostics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.document_scanner_rounded, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          s.btnScanVehicle,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => context.push('/live_data'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.show_chart_rounded, size: 22, color: AppTheme.secondary),
                        const SizedBox(width: 10),
                        Text(
                          s.btnTelemetryDashboard,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => obdService.disconnect(),
                    icon: const Icon(Icons.power_settings_new_rounded, size: 16, color: AppTheme.error),
                    label: Text(
                      s.btnDisconnectVehicle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              // Navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickNav(
                    context: context,
                    icon: Icons.history_rounded,
                    label: s.navHistory,
                    route: '/history',
                  ),
                  _buildQuickNav(
                    context: context,
                    icon: Icons.bluetooth_searching_rounded,
                    label: s.navAdapter,
                    route: '/connection',
                  ),
                  _buildQuickNav(
                    context: context,
                    icon: Icons.settings_rounded,
                    label: s.navSettings,
                    route: '/settings',
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDtcBadge(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        code,
        style: GoogleFonts.sourceCodePro(
          color: AppTheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.muted,
                ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMetricCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
    required bool isWarning,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isWarning ? AppTheme.warning : AppTheme.secondary,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNav({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.muted),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
