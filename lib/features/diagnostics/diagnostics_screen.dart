import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/obd_providers.dart';
import '../../shared/models/dtc_model.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
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
          if (scanState.isFinished)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.secondary),
              tooltip: s.startFullScan,
              onPressed: () => ref.read(diagnosticScanProvider.notifier).startScan(),
            ),
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
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: scanState.progress > 0 ? scanState.progress : null,
                strokeWidth: 6,
                backgroundColor: AppTheme.border,
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

        // Live Module Scan Progress List
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: ListView(
              children: [
                _buildModuleRow('ENGINE (PCM / ECM)', scanState.completedModules.contains('ENGINE (PCM / ECM)')),
                _buildModuleRow('TRANSMISSION (TCM)', scanState.completedModules.contains('TRANSMISSION (TCM)')),
                _buildModuleRow('ANTI-LOCK BRAKING (ABS / ESP)', scanState.completedModules.contains('ANTI-LOCK BRAKING (ABS / ESP)')),
                _buildModuleRow('AIRBAG / RESTRAINT (SRS)', scanState.completedModules.contains('AIRBAG / RESTRAINT (SRS)')),
                _buildModuleRow('BODY CONTROL (BCM)', scanState.completedModules.contains('BODY CONTROL MODULE (BCM)')),
                _buildModuleRow('EXHAUST & EMISSIONS', scanState.completedModules.contains('EXHAUST & CATALYST SENSORS')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleRow(String moduleName, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: isDone ? AppTheme.success : AppTheme.muted,
              ),
              const SizedBox(width: 12),
              Text(
                moduleName,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppTheme.text : AppTheme.muted,
                ),
              ),
            ],
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Overview Card
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
                            : 'Todos los subsistemas responden dentro de los parámetros.',
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

          const SizedBox(height: 24),

          Text(
            'CÓDIGOS DE DIAGNÓSTICO (DTC)',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
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

          // Action: Clear Codes Button with safety prompt
          if (issuesCount > 0) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
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
                        fontSize: 14,
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
          const SizedBox(height: 24),
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
          onTap: () => context.push('/dtc_details'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                      const SizedBox(height: 4),
                      Text(
                        '${dtc.system} • Severidad: ${dtc.severity}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20),
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
            const SizedBox(width: 8),
            Text(
              s.clearDtcConfirmTitle,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          s.clearDtcConfirmDesc,
          style: GoogleFonts.outfit(color: AppTheme.muted, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.cancel, style: GoogleFonts.outfit(color: AppTheme.muted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(diagnosticScanProvider.notifier).clearDTCs();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(s.clearSuccessSnack),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(s.clearDtcCodes, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

