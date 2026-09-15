import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/obd_providers.dart';
import '../../core/providers/vehicle_providers.dart';
import '../../core/providers/emissions_providers.dart';
import '../../core/services/pdf/diagnostic_pdf_service.dart';
import '../../shared/models/dtc_model.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  bool _showMonitorsDetails = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(diagnosticScanProvider);
      if (!state.isScanning && !state.isFinished) {
        ref.read(diagnosticScanProvider.notifier).startScan();
      }
    });
  }

  Future<void> _exportPdfReport(BuildContext context, ScanState scanState, AppStrings s) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(s.generatingPdfSnack)));

    final vehicle = ref.read(vehicleProvider);
    final smogState = ref.read(emissionsMonitorsProvider);

    final Map<String, bool> monitorsMap = {
      for (var m in smogState.monitors) m.name: m.isReady,
    };

    try {
      await DiagnosticPdfService.shareReport(
        vehicleName: vehicle.vehicleName.isNotEmpty ? vehicle.vehicleName : 'Vehículo Conectado',
        vin: vehicle.vin,
        dtcs: scanState.foundDTCs,
        readinessMonitors: monitorsMap,
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(diagnosticScanProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          s.diagnosticsTitle,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          if (scanState.isFinished) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.secondary),
              tooltip: s.exportPdfTooltip,
              onPressed: () => _exportPdfReport(context, scanState, s),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.secondary),
              tooltip: s.startFullScan,
              onPressed: () => ref.read(diagnosticScanProvider.notifier).startScan(),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: scanState.isScanning
              ? _buildScanningView(scanState, s)
              : _buildResultsView(scanState, s),
        ),
      ),
    );
  }

  Widget _buildScanningView(ScanState scanState, AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        // Futuristic Circular Radar / Progress
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: scanState.progress,
                strokeWidth: 4,
                backgroundColor: AppTheme.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(scanState.progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                  ),
                ),
                Text(
                  'BUS CAN',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        Text(
          s.scanningProgress,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          scanState.currentModule,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),

        const SizedBox(height: 32),

        // Stepper Visualizer
        Expanded(
          child: ListView.builder(
            itemCount: scanState.modulesList.length,
            itemBuilder: (context, index) {
              final module = scanState.modulesList[index];
              final isDone = index < (scanState.progress * scanState.modulesList.length).floor();
              final isCurrent = index == (scanState.progress * scanState.modulesList.length).floor();

              return _buildModuleItem(module, isDone, isCurrent);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModuleItem(String name, bool isDone, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.surface : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? AppTheme.secondary : (isDone ? AppTheme.border : Colors.transparent),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : (isCurrent ? Icons.sync_rounded : Icons.radio_button_unchecked),
            size: 16,
            color: isDone
                ? AppTheme.success
                : (isCurrent ? AppTheme.secondary : AppTheme.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isDone || isCurrent ? AppTheme.text : AppTheme.muted,
              ),
            ),
          ),
          Text(
            isDone ? 'VERIFICADO' : 'PENDIENTE',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDone ? AppTheme.success : AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(ScanState scanState, AppStrings s) {
    final issuesCount = scanState.foundDTCs.length;
    final smogState = ref.watch(emissionsMonitorsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Overview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: issuesCount > 0 ? AppTheme.alertGlowGradient : null,
              color: issuesCount == 0 ? AppTheme.surface : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: issuesCount > 0 ? AppTheme.error.withValues(alpha: 0.5) : AppTheme.success.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (issuesCount > 0 ? AppTheme.error : AppTheme.success).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    issuesCount > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    color: issuesCount > 0 ? AppTheme.error : AppTheme.success,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issuesCount > 0 ? '$issuesCount ${s.issuesFound}' : s.noActiveIssues,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: issuesCount > 0 ? AppTheme.error : AppTheme.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issuesCount > 0
                            ? s.scanVehicleDescription
                            : 'Todos los subsistemas responden dentro de los parámetros nominales.',
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
          ),

          const SizedBox(height: 20),

          // 2. Smog Check Readiness Card
          _buildSmogCard(smogState, s),

          const SizedBox(height: 24),

          // 3. DTC List Section Header
          Text(
            'CÓDIGOS DE DIAGNÓSTICO (DTC)',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.muted,
            ),
          ),

          const SizedBox(height: 12),

          if (issuesCount == 0)
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Center(
                child: Text(
                  s.noActiveIssues,
                  style: GoogleFonts.outfit(color: AppTheme.muted, fontSize: 14),
                ),
              ),
            )
          else
            ...scanState.foundDTCs.map((dtc) => _buildDtcItemCard(dtc)),

          const SizedBox(height: 24),

          // 4. Action: Export PDF Report Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: Text(
                s.exportPdfReportBtn,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () => _exportPdfReport(context, scanState, s),
            ),
          ),

          const SizedBox(height: 12),

          // 5. Action: Clear Codes Button with safety prompt
          if (issuesCount > 0) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _confirmClearDtcDialog(context, s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_sweep_rounded, color: AppTheme.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      s.clearDtcCodes,
                      style: GoogleFonts.outfit(
                        color: AppTheme.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Nota: Borrar el código apaga el Check Engine pero no repara la pieza averiada.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.muted),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSmogCard(SmogReadinessState smogState, AppStrings s) {
    final readyRatio = smogState.readyCount / smogState.totalCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: smogState.isPassed ? AppTheme.success.withValues(alpha: 0.4) : AppTheme.warning.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.shieldCheck,
                size: 18,
                color: smogState.isPassed ? AppTheme.success : AppTheme.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.smogCheckTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (smogState.isPassed ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (smogState.isPassed ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      smogState.isPassed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      size: 12,
                      color: smogState.isPassed ? AppTheme.success : AppTheme.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      smogState.isPassed ? s.smogCheckPassed : s.smogCheckFailed,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: smogState.isPassed ? AppTheme.success : AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.smogCheckSubtitle,
            style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: readyRatio,
              minHeight: 5,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                smogState.isPassed ? AppTheme.success : AppTheme.warning,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${smogState.readyCount} de ${smogState.totalCount} Monitores Listos',
                style: GoogleFonts.sourceCodePro(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showMonitorsDetails = !_showMonitorsDetails;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _showMonitorsDetails ? 'Ocultar' : 'Ver detalle',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.w700),
                    ),
                    Icon(
                      _showMonitorsDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppTheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_showMonitorsDetails) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 12),
            ...smogState.monitors.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text),
                            ),
                            Text(
                              m.description,
                              style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (m.isReady ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              m.isReady ? Icons.check : Icons.access_time_rounded,
                              size: 11,
                              color: m.isReady ? AppTheme.success : AppTheme.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              m.isReady ? 'LISTO' : 'PENDIENTE',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: m.isReady ? AppTheme.success : AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDtcItemCard(DTCModel dtc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/dtc_details', extra: dtc),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        dtc.code,
                        style: GoogleFonts.sourceCodePro(
                          color: AppTheme.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dtc.description,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dtc.system} • Severidad: ${dtc.severity}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20),
                  ],
                ),
                if (dtc.probableCauses.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppTheme.border),
                  const SizedBox(height: 8),
                  Text(
                    'Causas habituales: ${dtc.probableCauses.take(2).join(" • ")}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.secondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClearDtcDialog(BuildContext context, AppStrings s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 28),
            const SizedBox(width: 10),
            Text(
              s.clearDtcConfirmTitle,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text),
            ),
          ],
        ),
        content: Text(
          s.clearDtcConfirmDesc,
          style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(diagnosticScanProvider.notifier).clearDTCs();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.clearSuccessSnack),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: Text(s.clearDtcCodes, style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
