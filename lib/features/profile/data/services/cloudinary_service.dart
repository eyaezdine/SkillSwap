import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:skillswap/core/constants/cloudinary_config.dart';

class CloudinaryService {
  CloudinaryService({
    http.Client? client,
    String? cloudName,
    String? uploadPreset,
    String? folder,
  })  : _client = client ?? http.Client(),
        _cloudName = cloudName ?? CloudinaryConfig.cloudName,
        _uploadPreset = uploadPreset ?? CloudinaryConfig.uploadPreset,
        _folder = folder ?? CloudinaryConfig.folder;

  final http.Client _client;
  final String _cloudName;
  final String _uploadPreset;
  final String _folder;

  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  Future<String> uploadProfileImage({
    required String uid,
    required Uint8List bytes,
    String filename = 'avatar.jpg',
  }) async {
    if (!CloudinaryConfig.isConfigured &&
        _cloudName == 'YOUR_CLOUD_NAME') {
      throw Exception(
        'Cloudinary is not configured. Please set your cloudName and uploadPreset in lib/core/constants/cloudinary_config.dart.',
      );
    }

    if (bytes.lengthInBytes > maxFileSizeBytes) {
      throw Exception('Image size exceeds 5MB limit. Please select a smaller photo.');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;
    if (_folder.isNotEmpty) {
      request.fields['folder'] = _folder;
    }
    request.fields['public_id'] = 'user_$uid';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final secureUrl = data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Cloudinary upload succeeded but no secure_url was returned.');
      }
      return secureUrl;
    } else {
      String errorMessage = 'Upload failed (${response.statusCode})';
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (errorData['error'] is Map && errorData['error']['message'] != null) {
          errorMessage = errorData['error']['message'];
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }
      throw Exception('Cloudinary error: $errorMessage');
    }
  }
}

