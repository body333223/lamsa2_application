import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Service for picking, compressing, and uploading images to Firebase Storage.
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  Future<String?> pickAndUploadImage({
    required String folder,
    String? fileName,
    int maxWidth = 800,
    int quality = 75,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // 1. Pick image
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        imageQuality: quality,
      );
      if (picked == null) return null;

      // 2. Read bytes
      final Uint8List bytes = await picked.readAsBytes();

      // 3. Compress further if needed
      final Uint8List compressed =
          await _compressImage(bytes, maxWidth, quality);

      // 4. Upload to Firebase Storage
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(folder).child(name);

      final uploadTask = ref.putData(
        compressed,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('ImageUploadService error: $e');
      return null;
    }
  }

  /// Upload raw bytes directly (useful for admin dashboard).
  Future<String?> uploadBytes({
    required Uint8List bytes,
    required String folder,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(folder).child(name);

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('ImageUploadService uploadBytes error: $e');
      return null;
    }
  }

  /// Upload a File directly.
  Future<String?> uploadFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(folder).child(name);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('ImageUploadService uploadFile error: $e');
      return null;
    }
  }

  /// Delete an image from Storage by its URL.
  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('ImageUploadService deleteImage error: $e');
    }
  }

  /// Compress image bytes to target width and quality.
  Future<Uint8List> _compressImage(
      Uint8List bytes, int maxWidth, int quality) async {
    return await compute(_compressInIsolate, {
      'bytes': bytes,
      'maxWidth': maxWidth,
      'quality': quality,
    });
  }

  static Uint8List _compressInIsolate(Map<String, dynamic> params) {
    final Uint8List bytes = params['bytes'];
    final int maxWidth = params['maxWidth'];
    final int quality = params['quality'];

    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Resize if wider than maxWidth
    img.Image resized;
    if (image.width > maxWidth) {
      resized = img.copyResize(image, width: maxWidth);
    } else {
      resized = image;
    }

    // Encode as JPEG with quality
    final compressed = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(compressed);
  }
}
