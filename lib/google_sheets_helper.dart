import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'google_credentials.dart';

class GoogleSheetsHelper {
  final String spreadsheetId;
  final ServiceAccountCredentials accountCredentials;
  final List<String> scopes;

  GoogleSheetsHelper({
    required this.spreadsheetId,
    this.scopes = const [sheets.SheetsApi.spreadsheetsScope],
  }) : accountCredentials = ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": GoogleCredentials.projectId,
          "private_key_id": GoogleCredentials.privateKeyId,
          "private_key": GoogleCredentials.privateKey,
          "client_email": GoogleCredentials.clientEmail,
          "client_id": GoogleCredentials.clientId,
          "auth_uri": GoogleCredentials.authUri,
          "token_uri": GoogleCredentials.tokenUri,
          "auth_provider_x509_cert_url": GoogleCredentials.certUrl,
          "client_x509_cert_url": GoogleCredentials.clientCertUrl,
        });

  Future<void> appendRow(List<Object> row) async {
    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final sheetsApi = sheets.SheetsApi(client);

    const range = "Sheet1!A:B"; // Specify the range for appending rows

    final valueRange = sheets.ValueRange.fromJson({
      "range": range,
      "values": [row],
    });

    await sheetsApi.spreadsheets.values.append(
      valueRange,
      spreadsheetId,
      range,
      valueInputOption: "RAW",
    );

    client.close();
  }
}
