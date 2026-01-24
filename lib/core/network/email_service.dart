import 'package:http/http.dart' as http;
import 'package:apodel_restorant/features/auth/domain/send_verification_email.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static const _endpoint = 'https://api.brevo.com/v3/smtp/email';

  Future<void> sendWelcomeEmail({
    required String recipientEmail,
    required String recipientName,
  }) async {
    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env['BREVO_API_KEY'];
    if (apiKey == null) {
      throw Exception('BREVO_API_KEY not found in .env');
    }

    final email = WelcomeEmail(
      recipientEmail: recipientEmail,
      recipientName: recipientName,
    );

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json', 'api-key': apiKey},
      body: email.toJson(),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to send email (${response.statusCode}): ${response.body}',
      );
    }
  }
}
