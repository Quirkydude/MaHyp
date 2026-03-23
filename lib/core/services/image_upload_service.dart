import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling image uploads to Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload user avatar image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadUserAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      // Create a unique path for the image
      final String fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(
        'users/$userId/avatar/$fileName',
      );

      // Read file as bytes to avoid path permission issues on Android
      final Uint8List bytes = await imageFile.readAsBytes();
      
      // Upload the file data
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(bytes, metadata);

      // Wait a tiny bit to ensure the bucket state is updated before getting URL
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the download URL
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete old avatar image
  Future<void> deleteOldAvatar({
    required String userId,
    required String imageUrl,
  }) async {
    try {
      // Extract the path from the download URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Log error but don't throw - old avatar deletion is not critical
      debugPrint('Failed to delete old avatar');
    }
  }
}
