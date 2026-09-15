import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/providers/vehicle_providers.dart';
import '../../core/providers/emissions_providers.dart';
import '../../core/services/pdf/diagnostic_pdf_service.dart';
import '../../shared/models/dtc_model.dart';

class DtcDetailsScreen extends ConsumerWidget {
  final DTCModel? dtc;

  const DtcDetailsScreen({
    super.key,
    this.dtc,
  });

  Future<void> _shareDtcPdf(BuildContext context, WidgetRef ref) async {
    final s = ref.read(stringsProvider);
    final vehicle = ref.read(vehicleProvider);
    final smogState = ref.read(emissionsMonitorsProvider);

    final currentDtc = dtc ??
        const DTCModel(
          code: 'P0301',
          description: 'Fallo de encendido en Cilindro 1 (Misfire)',
          severity: 'High',
          system: 'Powertrain / Engine (PCM)',
          probableCauses: [
            'Bujía desgastada, con carbón o electrodo dañado',
            'Bobina de encendido (Coil Pack) defectuosa o en corto',
            'Inyector de combustible tapado o sucio',
            'Baja compresión en el cilindro 1',
          ],
          symptoms: [
            'Temblores perceptibles en ralentí',
            'Pérdida súbita de potencia al acelerar',
            'Luz Check Engine parpadeando bajo carga',
          ],
          recommendedAction: 'Inspeccionar bujía del cilindro 1 e intercambiar la bobina con el cilindro 2.',
        );

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(s.generatingPdfSnack)));

    try {
      await DiagnosticPdfService.shareReport(
        vehicleName: vehicle.vehicleName.isNotEmpty ? vehicle.vehicleName : 'Vehículo Conectado',
        vin: vehicle.vin,
        dtcs: [currentDtc],
        readinessMonitors: {for (var m in smogState.monitors) m.name: m.isReady},
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    final activeCode = dtc?.code ?? 'P0301';
    final activeDesc = dtc?.description ?? 'Fallo de encendido en Cilindro 1 (Misfire)';
    final activeSystem = dtc?.system ?? 'Powertrain / Engine (PCM)';
    final activeSeverity = dtc?.severity == 'High' ? 8 : (dtc?.severity == 'Medium' ? 5 : 3);

    final causes = dtc?.probableCauses.isNotEmpty == true
        ? dtc!.probableCauses
        : [
            'Bujía desgastada o con carbonilla (Spark plug)',
            'Bobina de encendido averiada o con fuga (Ignition coil)',
            'Inyector de combustible obstruido o con baja presión',
            'Fuga de vacío en el múltiple de admisión',
          ];

    final symptoms = dtc?.symptoms.isNotEmpty == true
        ? dtc!.symptoms
        : [
            'Vibraciones y temblor perceptible en ralentí',
            'Titubeo o jaloneo súbito al pisar el acelerador',
            'Luz Check Engine parpadeante o fija en el tablero',
            'Mayor consumo de gasolina por combustión incompleta',
          ];

    final recommendedAction = dtc?.recommendedAction.isNotEmpty == true
        ? dtc!.recommendedAction
        : 'Inspeccionar visualmente la bujía del cilindro 1. Si está quemada, reemplazar el juego completo. Probar resistencia eléctrica en la bobina de encendido.';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'ANÁLISIS DE FALLA $activeCode',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.secondary),
            tooltip: s.exportPdfTooltip,
            onPressed: () => _shareDtcPdf(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DTC Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.alertGlowGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            activeCode,
                            style: GoogleFonts.sourceCodePro(
                              color: AppTheme.error,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.speed_rounded, size: 14, color: AppTheme.error),
                              const SizedBox(width: 6),
                              Text(
                                'SEVERIDAD $activeSeverity/10',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activeDesc,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.text,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activeSystem,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Severity Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: activeSeverity / 10.0,
                        minHeight: 6,
                        backgroundColor: AppTheme.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: PROBABLE CAUSES
              _buildSectionCard(
                icon: LucideIcons.alertCircle,
                iconColor: AppTheme.warning,
                title: s.dtcProbableCausesTitle,
                content: Column(
                  children: causes.map((cause) => _buildBulletItem(cause, AppTheme.warning)).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: SYMPTOMS
              _buildSectionCard(
                icon: LucideIcons.activity,
                iconColor: AppTheme.secondary,
                title: s.dtcSymptomsTitle,
                content: Column(
                  children: symptoms.map((symptom) => _buildBulletItem(symptom, AppTheme.secondary)).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: RECOMMENDED ACTION
              _buildSectionCard(
                icon: LucideIcons.wrench,
                iconColor: AppTheme.primary,
                title: s.dtcRecommendedActionTitle,
                content: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    recommendedAction,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.text, height: 1.45),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Share PDF Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                  label: Text(
                    s.exportPdfReportBtn,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => _shareDtcPdf(context, ref),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.text, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
