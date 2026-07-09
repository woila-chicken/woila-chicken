import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StorageService extends GetxService {
  // ← Remplace par ta vraie clé API ImgBB
  static const _apiKey = '2db4e377491ec741e7cd46e5ae6c2937';

  final _picker = ImagePicker();

  // ── Sélectionner une image ──────────────────────────────────
  Future<Uint8List?> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (e) {
      debugPrint('Erreur pickImage: $e');
      return null;
    }
  }

  // ── Uploader vers ImgBB ─────────────────────────────────────
  Future<String> uploadImage({
    required Uint8List bytes,
    required String path, // ignoré avec ImgBB, gardé pour compatibilité
  }) async {
    try {
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey'),
        body: {
          'image': base64Image,
          'name': path.replaceAll('/', '_'),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['data']['url'] as String;
        debugPrint('Image uploadée ImgBB : $url');
        return url;
      } else {
        debugPrint('Erreur ImgBB: ${response.statusCode} ${response.body}');
        throw Exception('Upload échoué: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur uploadImage: $e');
      rethrow;
    }
  }

  // ── ImgBB ne supporte pas la suppression via API gratuite ───
  Future<void> deleteImage(String path) async {
    // Non disponible sur le plan gratuit ImgBB
    debugPrint('Suppression image non disponible (ImgBB gratuit)');
  }

  // ── Helpers chemins (gardés pour compatibilité) ─────────────
  String profilePath(String uid) => 'profiles_$uid';
  String farmPath(String farmId) => 'farms_$farmId';
  String productPath(String productId) => 'products_$productId';
}