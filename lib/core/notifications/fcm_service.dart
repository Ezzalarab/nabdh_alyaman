import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/repositories/auth_repo.dart';

/// Registers FCM token with the API and listens for refresh / foreground messages.
class FcmService {
  FcmService({required AuthRepo authRepo}) : _authRepo = authRepo;

  final AuthRepo _authRepo;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _requestPermissionIfNeeded();
    await _authRepo.registerDeviceIfPossible();
    _messaging.onTokenRefresh.listen((_) async {
      await _authRepo.registerDeviceIfPossible();
    });
  }

  void listenForeground(void Function(RemoteMessage message) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  void listenOpenedApp(void Function(RemoteMessage message) onOpened) {
    FirebaseMessaging.onMessageOpenedApp.listen(onOpened);
  }

  Future<RemoteMessage?> initialMessage() => _messaging.getInitialMessage();

  Future<void> _requestPermissionIfNeeded() async {
    try {
      await _messaging.requestPermission();
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM permission: $e');
      }
    }
  }
}
