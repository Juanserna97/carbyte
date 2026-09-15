import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/obd_providers.dart';

class LiveDataScreen extends ConsumerStatefulWidget {
  const LiveDataScreen({super.key});

  @override
  ConsumerState<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends ConsumerState<LiveDataScreen> {
  final List<FlSpot> _rpmSpots = [];
  int _pointCounter = 0;

  @override
  Widget build(BuildContext context) {
    final rpmAsync = ref.watch(rpmStreamProvider);
    final speedAsync = ref.watch(speedStreamProvider);
    final coolantAsync = ref.watch(coolantTempStreamProvider);
    final loadAsync = ref.watch(engineLoadStreamProvider);
    final throttleAsync = ref.watch(throttleStreamProvider);
    final batteryAsync = ref.watch(batteryStreamProvider);
    final intakeAsync = ref.watch(intakeTempStreamProvider);
    final mafAsync = ref.watch(mafStreamProvider);

    final rpm = rpmAsync.value ?? 1840.0;
    final speed = speedAsync.value ?? 48.0;
    final coolant = coolantAsync.value ?? 91.0;
    final load = loadAsync.value ?? 34.0;
    final throttle = throttleAsync.value ?? 18.0;
    final battery = batteryAsync.value ?? 14.2;
    final intake = intakeAsync.value ?? 28.0;
    final maf = mafAsync.value ?? 4.8;

    // Accumulate points for chart
    if (_rpmSpots.isEmpty || _rpmSpots.last.y != rpm) {
      _pointCounter++;
      _rpmSpots.add(FlSpot(_pointCounter.toDouble(), rpm));
      if (_rpmSpots.length > 25) {
        _rpmSpots.removeAt(0);
      }
    }

    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          s.telemetryTitle,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '10 Hz OBD',
                  style: GoogleFonts.outfit(
                    color: AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dual Primary Cockpit Gauges (RPM & SPEED)
              Row(
                children: [
                  Expanded(
                    child: _buildDigitalCockpitGauge(
                      title: s.tachometer,
                      value: rpm.toInt().toString(),
                      unit: 'RPM',
                      subtext: 'Redline: 6,500',
                      accentColor: AppTheme.secondary,
                      gaugeProgress: (rpm / 6500).clamp(0.0, 1.0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDigitalCockpitGauge(
                      title: s.speedGauge,
                      value: speed.toInt().toString(),
                      unit: 'KM/H',
                      subtext: 'Gear: D4',
                      accentColor: AppTheme.primary,
                      gaugeProgress: (speed / 240).clamp(0.0, 1.0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Live Real-Time Telemetry Chart with fl_chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insights_rounded, size: 18, color: AppTheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              s.realTimeRpmCurve,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: AppTheme.muted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${rpm.toInt()} RPM',
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1000,
                            getDrawingHorizontalLine: (value) => const FlLine(
                              color: AppTheme.border,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minY: 600,
                          maxY: 4500,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _rpmSpots.isNotEmpty
                                  ? _rpmSpots
                                  : [const FlSpot(0, 800), const FlSpot(1, 1800)],
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: AppTheme.secondary,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.secondary.withValues(alpha: 0.25),
                                    AppTheme.secondary.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                s.engineParametersPids,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.muted,
                ),
              ),

              const SizedBox(height: 12),

              // Sensors Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildSensorCard(
                    title: s.coolantTempSensor,
                    value: '${coolant.toInt()} °C',
                    status: coolant > 105 ? s.statusHigh : s.statusNormal,
                    icon: Icons.thermostat_rounded,
                    isAlert: coolant > 105,
                  ),
                  _buildSensorCard(
                    title: s.engineLoadSensor,
                    value: '${load.toInt()} %',
                    status: s.statusNormal,
                    icon: Icons.speed_rounded,
                  ),
                  _buildSensorCard(
                    title: s.throttlePosSensor,
                    value: '${throttle.toInt()} %',
                    status: s.statusNormal,
                    icon: Icons.gamepad_rounded,
                  ),
                  _buildSensorCard(
                    title: s.alternatorVoltSensor,
                    value: '${battery.toStringAsFixed(1)} V',
                    status: battery < 12.5 ? s.statusLow : s.statusOptimal,
                    icon: Icons.battery_charging_full_rounded,
                    isAlert: battery < 12.5,
                  ),
                  _buildSensorCard(
                    title: s.intakeAirSensor,
                    value: '${intake.toInt()} °C',
                    status: s.statusNormal,
                    icon: Icons.air_rounded,
                  ),
                  _buildSensorCard(
                    title: s.massAirFlowSensor,
                    value: '${maf.toStringAsFixed(1)} g/s',
                    status: s.statusNormal,
                    icon: Icons.grain_rounded,
                  ),
                  _buildSensorCard(
                    title: s.turboBoostSensor,
                    value: '${(ref.watch(turboBoostStreamProvider).value ?? 0.0).toStringAsFixed(2)} BAR',
                    status: s.boostActive,
                    icon: Icons.speed_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCockpitGauge({
    required String title,
    required String value,
    required String unit,
    required String subtext,
    required Color accentColor,
    required double gaugeProgress,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.muted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtext,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: gaugeProgress,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppTheme.error.withValues(alpha: 0.5) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppTheme.muted,
                  ),
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: isAlert ? AppTheme.error : AppTheme.secondary,
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isAlert ? AppTheme.error : AppTheme.text,
            ),
          ),
          Text(
            status,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isAlert ? AppTheme.error : AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
