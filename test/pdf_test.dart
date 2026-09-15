import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:carbyte/core/services/pdf/diagnostic_pdf_service.dart';
import 'package:carbyte/shared/models/dtc_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Generate test PDF', () async {
    final pdfBytes = await DiagnosticPdfService.buildPdfReport(
      vehicleName: 'Mercedes-AMG GLA 45',
      vin: 'WDC1569521J123456',
      dtcs: [
        const DTCModel(
          code: 'P0301',
          description: 'Fallo de combustión en cilindro 1 detectado (Cylinder 1 Misfire)',
          severity: 'High',
          system: 'PCM / Motor',
          probableCauses: [
            'Bujía desgastada, con carbón o electrodo dañado',
            'Bobina de encendido (Coil Pack) defectuosa o en corto',
            'Inyector de combustible tapado o con baja presión',
            'Fuga de vacío en el múltiple de admisión',
          ],
          symptoms: [
            'Temblores perceptibles en ralentí',
            'Pérdida de potencia al acelerar',
          ],
          recommendedAction: 'Inspeccionar bujía del cilindro 1 e intercambiar bobina.',
        ),
      ],
      readinessMonitors: {
        'Misfire Monitor': true,
        'Fuel System Monitor': true,
        'Comprehensive Component': true,
        'Catalyst Monitor': false,
        'Evaporative System': false,
        'Oxygen Sensor Monitor': true,
        'Oxygen Sensor Heater': true,
        'EGR / VVT System': true,
      },
    );

    final file = File('test_output.pdf');
    await file.writeAsBytes(pdfBytes);
    expect(file.existsSync(), true);
  });
}
