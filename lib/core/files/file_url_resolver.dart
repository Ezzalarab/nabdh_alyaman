import '../config/app_config.dart';

/// Builds public file URLs from API `fileId` values (`imageUrl` on profiles).
class FileUrlResolver {
  const FileUrlResolver();

  String? resolve(String? fileId) {
    if (fileId == null || fileId.trim().isEmpty) return null;
    return '${AppConfig.apiBaseUrl}/files/${fileId.trim()}';
  }
}
