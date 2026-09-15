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
  int _selectedCategory = 0; // 0: All, 1: Engine, 2: Intake, 3: Fuel & Battery

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

    final stftAsync = ref.watch(stftStreamProvider);
    final ltftAsync = ref.watch(ltftStreamProvider);
    final timingAsync = ref.watch(timingAdvanceStreamProvider);
    final fuelLevelAsync = ref.watch(fuelLevelStreamProvider);
    final baroAsync = ref.watch(baroStreamProvider);
    final turboAsync = ref.watch(turboBoostStreamProvider);

    final rpm = rpmAsync.value ?? 1840.0;
    final speed = speedAsync.value ?? 48.0;
    final coolant = coolantAsync.value ?? 91.0;
    final load = loadAsync.value ?? 34.0;
    final throttle = throttleAsync.value ?? 18.0;
    final battery = batteryAsync.value ?? 14.2;
    final intake = intakeAsync.value ?? 28.0;
    final maf = mafAsync.value ?? 4.8;
    final turbo = turboAsync.value ?? 0.0;
    final stft = stftAsync.value ?? 1.5;
    final ltft = ltftAsync.value ?? 2.3;
    final timing = timingAsync.value ?? 14.0;
    final fuelLevel = fuelLevelAsync.value ?? 68.0;
    final baro = baroAsync.value ?? 101.3;

    // Accumulate points for chart
    if (_rpmSpots.isEmpty || _rpmSpots.last.y != rpm) {
      _pointCounter++;
      _rpmSpots.add(FlSpot(_pointCounter.toDouble(), rpm));
      if (_rpmSpots.length > 25) {
        _rpmSpots.removeAt(0);
      }
    }

    final s = ref.watch(stringsProvider);

    // Build list of sensors with category tags
    final allCards = [
      // Category 1: Engine & Performance
      _SensorData(
        category: 1,
        title: s.engineLoadSensor,
        value: '${load.toInt()} %',
        status: s.statusNormal,
        icon: Icons.speed_rounded,
      ),
      _SensorData(
        category: 1,
        title: s.throttlePosSensor,
        value: '${throttle.toInt()} %',
        status: s.statusNormal,
        icon: Icons.gamepad_rounded,
      ),
      _SensorData(
        category: 1,
        title: s.turboBoostSensor,
        value: '${turbo.toStringAsFixed(2)} BAR',
        status: s.boostActive,
        icon: Icons.compress_rounded,
      ),
      _SensorData(
        category: 1,
        title: s.timingAdvanceSensor,
        value: '${timing.toStringAsFixed(1)}°',
        status: s.statusNormal,
        icon: Icons.av_timer_rounded,
      ),
      // Category 2: Intake & Temp
      _SensorData(
        category: 2,
        title: s.coolantTempSensor,
        value: '${coolant.toInt()} °C',
        status: coolant > 105 ? s.statusHigh : s.statusNormal,
        icon: Icons.thermostat_rounded,
        isAlert: coolant > 105,
      ),
      _SensorData(
        category: 2,
        title: s.intakeAirSensor,
        value: '${intake.toInt()} °C',
        status: s.statusNormal,
        icon: Icons.air_rounded,
      ),
      _SensorData(
        category: 2,
        title: s.massAirFlowSensor,
        value: '${maf.toStringAsFixed(1)} g/s',
        status: s.statusNormal,
        icon: Icons.grain_rounded,
      ),
      _SensorData(
        category: 2,
        title: s.baroPressureSensor,
        value: '${baro.toStringAsFixed(1)} kPa',
        status: s.statusNormal,
        icon: Icons.speed_outlined,
      ),
      // Category 3: Fuel & Battery
      _SensorData(
        category: 3,
        title: s.stftSensor,
        value: '${stft >= 0 ? '+' : ''}${stft.toStringAsFixed(1)} %',
        status: stft.abs() > 10 ? s.statusHigh : s.statusNormal,
        icon: Icons.local_gas_station_rounded,
        isAlert: stft.abs() > 10,
      ),
      _SensorData(
        category: 3,
        title: s.ltftSensor,
        value: '${ltft >= 0 ? '+' : ''}${ltft.toStringAsFixed(1)} %',
        status: ltft.abs() > 10 ? s.statusHigh : s.statusNormal,
        icon: Icons.tune_rounded,
        isAlert: ltft.abs() > 10,
      ),
      _SensorData(
        category: 3,
        title: s.alternatorVoltSensor,
        value: '${battery.toStringAsFixed(1)} V',
        status: battery < 12.5 ? s.statusLow : s.statusOptimal,
        icon: Icons.battery_charging_full_rounded,
        isAlert: battery < 12.5,
      ),
      _SensorData(
        category: 3,
        title: s.fuelLevelSensor,
        value: '${fuelLevel.toInt()} %',
        status: fuelLevel < 15 ? s.statusLow : s.statusNormal,
        icon: Icons.ev_station_rounded,
        isAlert: fuelLevel < 15,
      ),
    ];

    final filteredCards = _selectedCategory == 0
        ? allCards
        : allCards.where((c) => c.category == _selectedCategory).toList();

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
                  s.liveStreamBadge,
                  style: GoogleFonts.outfit(
                    color: AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.engineParametersPids,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTheme.muted,
                    ),
                  ),
                  Text(
                    '${filteredCards.length} ACTIVOS',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(0, s.allSensorsTab),
                    const SizedBox(width: 8),
                    _buildCategoryChip(1, s.engineTab),
                    const SizedBox(width: 8),
                    _buildCategoryChip(2, s.intakeTab),
                    const SizedBox(width: 8),
                    _buildCategoryChip(3, s.fuelElectricTab),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Sensors Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemCount: filteredCards.length,
                itemBuilder: (context, index) {
                  final c = filteredCards[index];
                  return _buildSensorCard(
                    title: c.title,
                    value: c.value,
                    status: c.status,
                    icon: c.icon,
                    isAlert: c.isAlert,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(int index, String label) {
    final isSelected = _selectedCategory == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selectedCategory = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary.withValues(alpha: 0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.secondary : AppTheme.border,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppTheme.secondary : AppTheme.muted,
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

class _SensorData {
  final int category;
  final String title;
  final String value;
  final String status;
  final IconData icon;
  final bool isAlert;

  const _SensorData({
    required this.category,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    this.isAlert = false,
  });
}
