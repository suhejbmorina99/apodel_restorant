import 'dart:convert';

class WelcomeEmail {
  final String recipientEmail;
  final String recipientName;

  WelcomeEmail({required this.recipientEmail, required this.recipientName});

  Map<String, dynamic> toBrevoPayload() {
    return {
      "sender": {"name": "Str8ch", "email": "str8ch@hotmail.com"},
      "to": [
        {"email": recipientEmail},
      ],
      "subject": "Welcome to Str8ch App!",
      "htmlContent": _htmlContent(),
    };
  }

  String toJson() => jsonEncode(toBrevoPayload());

  String _htmlContent() {
    return '''
      <p>Hi <strong>$recipientName</strong>, welcome to our app!</p>
      <br>
      <p>My name is Suhejb, and I'm the developer of Str8ch 👋.</p>
      <br>
      <p>Just wanted to let you know that we have a feedback board in the app!
      If you signed up using your email, you can create and vote on new features
      by navigating to <strong>Preferences → Give an Idea</strong>.</p>
      <br>
      <p>If you have any questions or feedback, feel free to reply directly
      to this email. I'd love to hear from you!</p>
      <br>
      <p>Best regards,<br>Suhejb</p>
    ''';
  }
}
