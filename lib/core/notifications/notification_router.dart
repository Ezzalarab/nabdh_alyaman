import 'package:flutter/material.dart';

/// Routes FCM `data` payloads to in-app destinations (stubs until phase 5).
class NotificationRouter {
  void handleData(BuildContext context, Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (type == 'BLOOD_REQUEST') {
      final requestId = data['requestId']?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requestId == null || requestId.isEmpty
                ? 'طلب دم جديد'
                : 'طلب دم #$requestId (التفاصيل قريباً)',
          ),
        ),
      );
    }
  }
}
