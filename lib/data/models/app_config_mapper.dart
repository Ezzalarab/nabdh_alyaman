import 'dart:convert';

import '../../core/content/slide_image_resolver.dart';
import '../../core/files/file_url_resolver.dart';
import '../../core/urls.dart';
import '../../presentation/resources/assets_manager.dart';
import '../../domain/entities/app_update_policy.dart';
import '../../domain/entities/event_card_data.dart';
import '../../domain/entities/global_app_data.dart';

/// Maps `GET /app-config` (legacy Firestore keys + new API keys) to [GlobalAppData].
class AppConfigMapper {
  AppConfigMapper({
    SlideImageResolver? slideResolver,
    FileUrlResolver? fileUrlResolver,
  })  : _slideResolver = slideResolver ?? const SlideImageResolver(),
        _fileUrlResolver = fileUrlResolver ?? const FileUrlResolver();

  final SlideImageResolver _slideResolver;
  final FileUrlResolver _fileUrlResolver;

  GlobalAppData toGlobalAppData(Map<String, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final slides = _parseStringList(
      map['home_slider'] ?? map[GlobalAppDataFields.homeSlides],
    );
    final resolvedSlides = _slideResolver.resolveAll(slides);

    final eventsRaw = map['home_events'] ??
        map[GlobalAppDataFields.eventsCardsData] ??
        '[]';
    final events = _parseEvents(eventsRaw);

    return GlobalAppData(
      appName: _string(map, GlobalAppDataFields.appName),
      aboutApp: _string(map, GlobalAppDataFields.aboutApp),
      homeHeader: _string(map, GlobalAppDataFields.homeHeader),
      infoTitle: _string(map, GlobalAppDataFields.infoTitile),
      eventsTitle: _string(map, GlobalAppDataFields.eventsTitile),
      reportLink: _string(map, GlobalAppDataFields.reportLink),
      infoList: _parseStringList(map[GlobalAppDataFields.infoList]),
      homeSlides: resolvedSlides,
      eventsCardsData: events,
    );
  }

  AppUpdatePolicy parseUpdatePolicy(
    Map<String, dynamic> raw, {
    required String currentVersion,
  }) {
    final map = Map<String, dynamic>.from(raw);
    var target = _string(map, 'min_app_version');
    var message = _string(map, 'force_update_message');
    var showDialog = _string(map, 'force_update_enabled');
    var blocking = false;
    var storeUrl = _string(map, 'store_url_android');

    if (target.isEmpty) {
      for (final entry in map.entries) {
        final key = entry.key;
        if (!key.startsWith('updating__')) continue;
        if (key.endsWith('__new_version')) {
          target = entry.value?.toString() ?? target;
        } else if (key.endsWith('__message')) {
          message = entry.value?.toString() ?? message;
        } else if (key.endsWith('__show_dialog')) {
          showDialog = entry.value?.toString() ?? showDialog;
        } else if (key.endsWith('__waring_degree')) {
          blocking = entry.value?.toString() == '1';
        } else if (key.endsWith('__update_link')) {
          final link = entry.value?.toString() ?? '';
          if (link.isNotEmpty) storeUrl = link;
        }
      }
    }

    if (storeUrl.isEmpty) storeUrl = Urls.googleStoreAppLink;
    if (message.isEmpty) message = 'يتوفر إصدار جديد من التطبيق';

    final enabled = showDialog == '1' ||
        showDialog.toLowerCase() == 'true' ||
        (map['min_app_version'] != null &&
            map['min_app_version'].toString().isNotEmpty);

    final shouldPrompt = enabled &&
        target.isNotEmpty &&
        _isVersionLower(currentVersion, target);

    return AppUpdatePolicy(
      shouldPrompt: shouldPrompt,
      targetVersion: target,
      message: message,
      isBlocking: blocking,
      storeUrl: storeUrl,
    );
  }

  List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList(growable: false);
    }
    final text = raw.toString().trim();
    if (text.isEmpty) return [];
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {}
    return [text];
  }

  List<EventCardData> _parseEvents(dynamic raw) {
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else {
      final text = raw?.toString().trim() ?? '[]';
      if (text.isEmpty) return [];
      try {
        final decoded = jsonDecode(text);
        if (decoded is! List) return [];
        list = decoded;
      } catch (_) {
        return [];
      }
    }

    return list
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          var image = map[EventsCardDataFields.image]?.toString() ?? '';
          final fileUrl = _fileUrlResolver.resolve(image);
          if (fileUrl != null) {
            image = fileUrl;
          } else if (image.isNotEmpty &&
              !image.startsWith('http') &&
              !image.startsWith('assets/')) {
            image = SlideImageResolver.knownAssets[image] ??
                '${ImageAssets.imagePath}/$image';
          }
          return EventCardData(
            id: map[EventsCardDataFields.id]?.toString() ?? '',
            title: map[EventsCardDataFields.title]?.toString() ?? '',
            desc: map[EventsCardDataFields.desc]?.toString() ?? '',
            image: image,
            date: map[EventsCardDataFields.date]?.toString() ?? '',
            place: map[EventsCardDataFields.place]?.toString() ?? '',
            link: map[EventsCardDataFields.link]?.toString() ?? '',
          );
        })
        .toList(growable: false);
  }

  String _string(Map<String, dynamic> map, String key) =>
      map[key]?.toString().trim() ?? '';

  bool _isVersionLower(String current, String minimum) {
    final c = _parseVersion(current);
    final m = _parseVersion(minimum);
    for (var i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false;
  }

  List<int> _parseVersion(String version) {
    final parts = version.split('.');
    return [
      int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
    ];
  }
}
