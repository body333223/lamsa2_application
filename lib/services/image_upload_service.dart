import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

/// Service for picking, compressing, and uploading images to the REST backend.
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from [source], compress it, upload to backend.
  /// Returns the server URL of the uploaded image, or null on failure.
  Future<String?> pickAndUploadImage({
    required String folder,
    String? fileName,
    int maxWidth = 800,
    int quality = 80,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        imageQuality: quality,
      );
      if (picked == null) return null;

      File fileToUpload = File(picked.path);

      // Attempt isolate compression if needed
      try {
        final Uint8List bytes = await picked.readAsBytes();
        final Uint8List compressed = await compute(_compressInIsolate, {
          'bytes': bytes,
          'maxWidth': maxWidth,
          'quality': quality,
        });

        final tempDir = Directory.systemTemp;
        final tempFile = File(
          '${tempDir.path}/upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(compressed);
        fileToUpload = tempFile;
      } catch (e) {
        debugPrint('Compression skipped, using original file: $e');
      }

      final data = await ApiService.uploadFile(
        '/profile/avatar',
        file: fileToUpload,
        fieldName: 'avatar',
        auth: true,
      );

      // Clean up temp file if created
      if (fileToUpload.path.contains('upload_')) {
        try {
          await fileToUpload.delete();
        } catch (_) {}
      }

      return data['avatar_url'] as String?;
    } catch (e) {
      debugPrint('ImageUploadService error: $e');
      return null;
    }
  }

  /// Upload a File directly to a given endpoint.
  Future<String?> uploadFile({
    required File file,
    required String endpoint,
    required String fieldName,
  }) async {
    try {
      final data = await ApiService.uploadFile(
        endpoint,
        file: file,
        fieldName: fieldName,
        auth: true,
      );
      return data['avatar_url'] as String? ?? data['url'] as String?;
    } catch (e) {
      debugPrint('ImageUploadService uploadFile error: $e');
      return null;
    }
  }

  // ── Compression (runs in isolate) ────────────────────────
  static Uint8List _compressInIsolate(Map<String, dynamic> params) {
    final Uint8List bytes = params['bytes'];
    final int maxWidth = params['maxWidth'];
    final int quality = params['quality'];

    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    img.Image resized;
    if (image.width > maxWidth) {
      resized = img.copyResize(image, width: maxWidth);
    } else {
      resized = image;
    }

    final compressed = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(compressed);
  }
}
