import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan URL Render.com setelah deploy
  static const String baseUrl = 'https://churn-prediction-api-b4dnfbf9egh4fbd0.malaysiawest-01.azurewebsites.net';

  static Future<Map<String, dynamic>> predictBoth(
      Map<String, dynamic> inputData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inputData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }
}
