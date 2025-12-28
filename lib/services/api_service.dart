import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<String> testConnection() async {
    final response = await http.get(Uri.parse('$_baseUrl/test'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Connection failed');
    }
  }
}
