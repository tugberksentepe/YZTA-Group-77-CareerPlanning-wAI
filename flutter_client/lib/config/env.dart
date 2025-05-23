import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static String get defaultEmail => dotenv.env['EMAIL'] ?? 'default@example.com';
} 