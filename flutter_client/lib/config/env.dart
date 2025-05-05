import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API ve çevre değişkenleri ile ilgili yapılandırmalar
class EnvConfig {
  /// API'nin temel URL'si
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  
  /// Varsayılan email - gerçek uygulamada kullanıcıdan alınacak
  static String get defaultEmail => dotenv.env['EMAIL'] ?? 'default@example.com';
} 