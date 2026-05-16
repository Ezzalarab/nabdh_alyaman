import '../../core/files/file_url_resolver.dart';
import '../../presentation/resources/assets_manager.dart';

/// Resolves carousel slide entries from app-config to display paths/URLs.
class SlideImageResolver {
  const SlideImageResolver({FileUrlResolver? fileUrlResolver})
      : _fileUrlResolver = fileUrlResolver ?? const FileUrlResolver();

  final FileUrlResolver _fileUrlResolver;

  static const Map<String, String> knownAssets = {
    'blood_heart.png': ImageAssets.bloodHeart,
    'blood-donation-bag-heart.png': ImageAssets.bloodDonationBagHeart,
    'hands-donate.jpg': ImageAssets.handsDonate,
    'emergency-call.png': '${ImageAssets.imagePath}/emergency-call.png',
  };

  String resolve(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return ImageAssets.bloodHeart;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('assets/')) return value;
    final fileUrl = _fileUrlResolver.resolve(value);
    if (fileUrl != null) return fileUrl;
    return knownAssets[value] ?? '${ImageAssets.imagePath}/$value';
  }

  List<String> resolveAll(List<String> slides) =>
      slides.map(resolve).toList(growable: false);

  bool isNetworkUrl(String resolved) =>
      resolved.startsWith('http://') || resolved.startsWith('https://');

  bool isAssetPath(String resolved) => resolved.startsWith('assets/');
}
