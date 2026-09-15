import 'dart:convert';
import 'package:http/http.dart' as http;

class VINDecoderService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues';

  Future<String> decodeVIN(String vin) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$vin?format=json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Results'] != null && data['Results'].isNotEmpty) {
          final result = data['Results'][0];
          final make = result['Make'] ?? '';
          final model = result['Model'] ?? '';
          final year = result['ModelYear'] ?? '';

          if (make.isEmpty && model.isEmpty) {
            return 'Vehículo Desconocido';
          }
          // Convert from uppercase to title case for a premium look
          return _toTitleCase('$make $model $year'.trim());
        }
      }
      return 'Vehículo Desconocido';
    } catch (e) {
      return 'Error de Conexión';
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
