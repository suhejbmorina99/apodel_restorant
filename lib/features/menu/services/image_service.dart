import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  final _supabase = Supabase.instance.client;

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<String?> uploadImage({
    required String restaurantId,
    File? imageFile,
    String? existingImageUrl,
    required BuildContext context,
  }) async {
    if (imageFile == null) return existingImageUrl;

    try {
      final fileName =
          '${restaurantId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$restaurantId/$fileName';

      await _supabase.storage
          .from('menu-images')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage
          .from('menu-images')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim në ngarkimin e fotos: $e',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}
