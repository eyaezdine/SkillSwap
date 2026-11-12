abstract final class CloudinaryConfig {
  static const String cloudName = 'pjyahyl3';
  static const String uploadPreset = 'skillswap_unsigned';
  static const String folder = 'skillswap/profile_images';

  static bool get isConfigured =>
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset != 'YOUR_UPLOAD_PRESET' &&
      cloudName.trim().isNotEmpty &&
      uploadPreset.trim().isNotEmpty;
}

