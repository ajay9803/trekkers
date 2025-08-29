import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String serviceId = "service_d9lqx4w";
  static const String templateId = "template_toj16db";
  static const String publicKey = "1kMGRh73BSNuWJaeR";

  static Future<void> sendBookingEmail({
    required String userEmail,
    required String userName,
    required String trekName,
  }) async {
    const url = "https://api.emailjs.com/api/v1.0/email/send";

    print('sending email');
    print(userEmail);
    print(userName);
    print(trekName);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "origin": "http://localhost", // required by EmailJS
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "user_email": userEmail,
          "user_name": userName,
          "trek_name": trekName,
        },
      }),
    );

    print('tada');
    print(response.statusCode);
    print('tada');
    if (response.statusCode != 200) {
      throw Exception("Failed to send email: ${response.body}");
    }
  }
}
