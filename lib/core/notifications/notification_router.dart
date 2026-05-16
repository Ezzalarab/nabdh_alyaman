import 'package:flutter/material.dart';

import '../../presentation/pages/blood_request/blood_request_detail_page.dart';

/// Routes FCM `data` payloads to in-app destinations.
class NotificationRouter {
  void handleData(BuildContext context, Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (type == 'BLOOD_REQUEST') {
      final requestId = data['requestId']?.toString();
      if (requestId == null || requestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('طلب دم جديد')),
        );
        return;
      }
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BloodRequestDetailPage(requestId: requestId),
        ),
      );
    }
  }
}
