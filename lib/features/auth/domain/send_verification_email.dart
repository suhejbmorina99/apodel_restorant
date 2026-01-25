import 'dart:convert';

class WelcomeEmail {
  final String recipientEmail;
  final String recipientName;

  WelcomeEmail({required this.recipientEmail, required this.recipientName});

  Map<String, dynamic> toBrevoPayload() {
    return {
      "sender": {"name": "Apodel", "email": "apodel@gmail.com"},
      "to": [
        {"email": recipientEmail},
      ],
      "subject": "Mirë se vini në Apodel!",
      "htmlContent": _htmlContent(),
    };
  }

  String toJson() => jsonEncode(toBrevoPayload());

  String _htmlContent() {
    return '''
    <p>Përshëndetje <strong>$recipientName</strong>, mirë se vini në aplikacionin tonë!</p>
    <br>
    <p>Ne jemi shumë të lumtur që ju kemi në <strong>Apodel</strong>.</p>
    <br>
    <p>Kemi krijuar këtë aplikacion për ta bërë përvojën tuaj sa më të këndshme.</p>
    <br>
    <p>Nëse keni ndonjë pyetje, sugjerim apo kërkesë të veçantë,
    mos hezitoni të na kontaktoni drejtpërdrejt.
    Do të jemi të kënaqur t'ju shërbejmë!</p>
    <br>
    <p>Me respekt,<br>Ekipi i Apodel</p>
  ''';
  }
}
