import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../../domain/entities/app_notification.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationPageResult> fetchNotifications({
    String? cursor,
    int? limit,
  });

  Future<void> markRead(int id);

  Future<void> markAllRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final raw = data['items'] ?? data['data'] ?? data['notifications'];
      if (raw is List) {
        return raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false);
      }
    }
    return [];
  }

  String? _nextCursor(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    return map['nextCursor']?.toString() ?? map['cursor']?.toString();
  }

  AppNotification _mapItem(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    return AppNotification(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      isRead: json['isRead'] == true ||
          json['read'] == true ||
          json['is_read']?.toString() == 'true',
      type: dataMap?['type']?.toString() ?? json['type']?.toString(),
      requestId: dataMap?['requestId']?.toString() ??
          dataMap?['request_id']?.toString(),
    );
  }

  @override
  Future<NotificationPageResult> fetchNotifications({
    String? cursor,
    int? limit,
  }) async {
    try {
      final res = await _api.get<dynamic>(
        ApiEndpoints.notifications,
        queryParameters: {
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      if (res.statusCode != 200) throw WrongDataFailure();
      final data = res.data;
      final items = _extractItems(data).map(_mapItem).toList(growable: false);
      return NotificationPageResult(
        items: items,
        nextCursor: _nextCursor(data),
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> markRead(int id) async {
    try {
      await _api.patch<dynamic>(ApiEndpoints.notificationRead(id));
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _api.patch<dynamic>(ApiEndpoints.notificationsReadAll);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
