import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../shared/models/dtc_model.dart';

class DiagnosticPdfService {
  static Future<Uint8List> buildPdfReport({
    required String vehicleName,
    required String vin,
    required List<DTCModel> dtcs,
    required Map<String, bool> readinessMonitors,
    String protocol = 'ISO 15765-4 (CAN 11-bit / 500k)',
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year;
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final formattedDate = '$d/$m/$y $h:$min';
    final reportId = 'CB-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final hasIssues = dtcs.isNotEmpty;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(reportId, formattedDate),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 16),
          _buildVehicleInfoCard(vehicleName, vin, protocol, dtcs.length),
          pw.SizedBox(height: 20),
          _buildSummaryCard(hasIssues, dtcs.length),
          pw.SizedBox(height: 20),
          _buildDtcSection(dtcs),
          pw.SizedBox(height: 20),
          _buildReadinessSection(readinessMonitors),
          pw.SizedBox(height: 24),
          _buildSignOffBox(),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> shareReport({
    required String vehicleName,
    required String vin,
    required List<DTCModel> dtcs,
    required Map<String, bool> readinessMonitors,
    String protocol = 'ISO 15765-4 (CAN)',
  }) async {
    final pdfBytes = await buildPdfReport(
      vehicleName: vehicleName,
      vin: vin,
      dtcs: dtcs,
      readinessMonitors: readinessMonitors,
      protocol: protocol,
    );

    final cleanVin = vin.isNotEmpty ? vin : 'diagnostic';
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'CARBYTE_Report_$cleanVin.pdf',
    );
  }

  static pw.Widget _buildHeader(String reportId, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CARBYTE',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#00E5FF'),
                ),
              ),
              pw.Text(
                'SISTEMA PROFESIONAL DE TELEMETRÍA Y DIAGNÓSTICO',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'REPORTE: $reportId',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.Text(
                'FECHA: $date',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildVehicleInfoCard(
      String vehicle, String vin, String protocol, int issueCount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'VEHÍCULO IDENTIFICADO',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  vehicle.isNotEmpty ? vehicle : 'Vehículo Conectado',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'VIN / CHASIS: ${vin.isNotEmpty ? vin : "No detectado"}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'PROTOCOLO ECU',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  protocol,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  issueCount > 0 ? '$issueCount FALLAS ACTIVAS' : 'SISTEMA SALUDABLE',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: issueCount > 0 ? PdfColors.red800 : PdfColors.green800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard(bool hasIssues, int count) {
    final statusColor = hasIssues ? PdfColors.red800 : PdfColors.green800;
    final bgColor = hasIssues ? PdfColor.fromHex('#FFEBEE') : PdfColor.fromHex('#E8F5E9');

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: statusColor, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 8,
            height: 36,
            decoration: pw.BoxDecoration(
              color: statusColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  hasIssues
                      ? 'ATENCIÓN MECÁNICA REQUERIDA ($count CÓDIGOS DTC ENCONTRADOS)'
                      : 'DIAGNÓSTICO COMPLETO: 0 FALLAS DETECTADAS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  hasIssues
                      ? 'La computadora central (ECU) ha registrado códigos de error que pueden comprometer el rendimiento o las emisiones.'
                      : 'Todos los subsistemas primarios responden con parámetros nominales según el estándar OBD-II SAE J1979.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDtcSection(List<DTCModel> dtcs) {
    if (dtcs.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Center(
          child: pw.Text(
            'No se encontraron códigos de avería almacenados en la memoria de la ECU.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETALLE DE CÓDIGOS DE AVERÍA (DTC)',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
        ),
        pw.SizedBox(height: 8),
        ...dtcs.map((dtc) => _buildDtcItem(dtc)),
      ],
    );
  }

  static pw.Widget _buildDtcItem(DTCModel dtc) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFEBEE'),
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: PdfColors.red400),
                ),
                child: pw.Text(
                  dtc.code,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                ),
              ),
              pw.Text(
                'MÓDULO: ${dtc.system.toUpperCase()}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            dtc.description,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
          if (dtc.probableCauses.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Causas más probables:',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            ...dtc.probableCauses.map(
              (cause) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, top: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Expanded(
                      child: pw.Text(cause, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (dtc.recommendedAction.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Acción sugerida: ', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(dtc.recommendedAction, style: const pw.TextStyle(fontSize: 8.5)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildReadinessSection(Map<String, bool> monitors) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MONITORES DE EMISIONES Y REVISIÓN TÉCNICO-MECÁNICA (SMOG CHECK)',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            children: monitors.entries.map((entry) {
              final isReady = entry.value;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      entry.key,
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: isReady ? PdfColor.fromHex('#E8F5E9') : PdfColor.fromHex('#FFF3E0'),
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(
                          color: isReady ? PdfColors.green800 : PdfColors.orange800,
                          width: 0.5,
                        ),
                      ),
                      child: pw.Text(
                        isReady ? 'COMPLETADO / LISTO' : 'NO LISTO / INCOMPLETO',
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: isReady ? PdfColors.green900 : PdfColors.orange900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSignOffBox() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'OBSERVACIONES DEL MECÁNICO / TALLER:',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 28),
              pw.Container(width: 250, height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text('Firma del Técnico Especialista', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('SELLO DE TALLER CERTIFICADO', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
              pw.SizedBox(height: 28),
              pw.Container(width: 140, height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text('Fecha de Intervención', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'CARBYTE Telematics • Documento confidencial para uso exclusivo del propietario y mecánico.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
