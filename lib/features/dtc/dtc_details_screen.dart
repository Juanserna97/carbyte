import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class DtcDetailsScreen extends StatelessWidget {
  final String code;
  final String title;
  final int severity;
  final String system;

  const DtcDetailsScreen({
    super.key,
    this.code = 'P0301',
    this.title = 'Cylinder 1 Misfire Detected',
    this.severity = 7,
    this.system = 'Powertrain / Engine (PCM)',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'ANÁLISIS DE FALLA',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.muted),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informe exportado a PDF/Portapapeles')),
              );
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
                            code,
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
                                'SEVERIDAD $severity/10',
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
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.text,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      system,
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
                        value: severity / 10.0,
                        minHeight: 6,
                        backgroundColor: AppTheme.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: WHAT IT MEANS
              _buildSectionCard(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.secondary,
                title: '¿QUÉ SIGNIFICA ESTE CÓDIGO?',
                content: Text(
                  'El sensor del cigüeñal y la computadora del motor (ECU) detectaron fallos repetidos en el ciclo de combustión del cilindro #1.\n\nEsto genera pérdida momentánea de potencia, aumento de emisiones, vibración perceptible al ralentí y puede sobrecalentar el convertidor catalítico si el combustible sin quemar pasa al escape.',
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.text, height: 1.5),
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: POSSIBLE CAUSES
              _buildSectionCard(
                icon: Icons.build_circle_outlined,
                iconColor: AppTheme.warning,
                title: 'POSIBLES CAUSAS',
                content: Column(
                  children: [
                    _buildCauseItem('Bujía desgastada o con carbonilla (Spark plug)'),
                    _buildCauseItem('Bobina de encendido averiada o con fuga (Ignition coil)'),
                    _buildCauseItem('Inyector de combustible obstruido o con baja presión'),
                    _buildCauseItem('Pérdida de compresión por válvulas o anillos del cilindro'),
                    _buildCauseItem('Fuga de vacío en el múltiple de admisión'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: RECOMMENDED ACTION
              _buildSectionCard(
                icon: Icons.assignment_turned_in_outlined,
                iconColor: AppTheme.success,
                title: 'ACCIÓN RECOMENDADA',
                content: Text(
                  '1. Revisar estado visual y calibración de la bujía #1.\n2. Intercambiar bobina #1 con cilindro #2 para descartar fallo de bobina si el código migra a P0302.\n3. Realizar prueba de compresión si el fallo persiste.',
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.text, height: 1.5),
                ),
              ),

              const SizedBox(height: 24),

              // Warning Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.report_problem_outlined, color: AppTheme.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aviso: Borrar el código de la ECU restablece la luz del tablero, pero si la causa física no se repara, el código reaparecerá al completar un ciclo de conducción.',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.text, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comando Mode 04 enviado a la ECU. Código borrado.'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                        context.pop();
                      },
                      child: Text(
                        'BORRAR CÓDIGO',
                        style: GoogleFonts.outfit(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diagnóstico guardado en el Historial del vehículo.'),
                            backgroundColor: AppTheme.primary,
                          ),
                        );
                      },
                      child: Text(
                        'GUARDAR',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildCauseItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.text),
            ),
          ),
        ],
      ),
    );
  }
}
