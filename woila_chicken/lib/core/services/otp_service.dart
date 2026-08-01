import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class OtpService {
  // Crée un compte sur emailjs.com et remplace ces valeurs
  static const _serviceId = 'service_od2fc69';
  static const _templateId = 'VOTRE_TEMPLATE_ID';
  static const _publicKey = 'VOTRE_PUBLIC_KEY';

  // Génère un code à 6 chiffres
  static String _generateCode() {
    final rand = Random.secure();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  // Envoie le code OTP par email et le stocke dans Firestore
  static Future<String> sendOtp(String email) async {
    final code = _generateCode();
    final expiry = DateTime.now().add(const Duration(minutes: 10));

    // Stocker dans Firestore (collection temporaire)
    await FirebaseFirestore.instance.collection('otp_codes').doc(email).set({
      'code': code,
      'expiry': Timestamp.fromDate(expiry),
      'verified': false,
    });

    // Envoyer via EmailJS
    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_email': email,
          'otp_code': code,
          'expiry_minutes': '10',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur envoi email: ${response.body}');
    }

    return code;
  }

  // Vérifie le code saisi par l'utilisateur
  static Future<bool> verifyOtp(String email, String code) async {
    final doc = await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(email)
        .get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    final storedCode = data['code'] as String;
    final expiry = (data['expiry'] as Timestamp).toDate();
    final verified = data['verified'] as bool? ?? false;

    if (verified) return false; // déjà utilisé
    if (DateTime.now().isAfter(expiry)) return false; // expiré
    if (storedCode != code) return false;

    // Marquer comme utilisé
    await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(email)
        .update({'verified': true});

    return true;
  }

  // Nettoyer après inscription réussie
  static Future<void> cleanup(String email) async {
    await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(email)
        .delete();
  }
}
