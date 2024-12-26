import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleCredentials {
  static String get privateKey => dotenv.env['GOOGLE_PRIVATE_KEY'] ?? '';
  static String get clientEmail => dotenv.env['GOOGLE_CLIENT_EMAIL'] ?? '';
  static String get spreadsheetId => dotenv.env['GOOGLE_SPREADSHEET_ID'] ?? '';
  static String get projectId => dotenv.env['GOOGLE_PROJECT_ID'] ?? '';
  static String get privateKeyId => dotenv.env['GOOGLE_PRIVATE_KEY_ID'] ?? '';
  static String get clientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get clientCertUrl => dotenv.env['GOOGLE_CLIENT_CERT_URL'] ?? '';
  static String get authUri => dotenv.env['GOOGLE_AUTH_URI'] ?? '';
  static String get tokenUri => dotenv.env['GOOGLE_TOKEN_URI'] ?? '';
  static String get certUrl => dotenv.env['GOOGLE_CERT_URL'] ?? '';
}
