import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/entities/app_update_policy.dart';
import 'urls.dart';

/// Shows force-update UI from [AppUpdatePolicy] (app-config), not Firestore.
class AppUpdateDialog {
  Future<void> showIfNeeded(
    BuildContext context,
    AppUpdatePolicy policy,
  ) async {
    if (!policy.shouldPrompt || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: policy.isBlocking ? false : true,
      builder: (ctx) => PopScope(
        canPop: !policy.isBlocking,
        child: AlertDialog(
          title: const Text('يتوفر إصدار جديد'),
          content: Text(policy.message),
          actions: [
            if (!policy.isBlocking)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('لاحقاً'),
              ),
            ElevatedButton(
              onPressed: () => _launchStore(policy.storeUrl),
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showAwesome(
    BuildContext context,
    AppUpdatePolicy policy,
  ) async {
    if (!policy.shouldPrompt || !context.mounted) return;
    await AwesomeDialog(
      context: context,
      dismissOnBackKeyPress: !policy.isBlocking,
      dismissOnTouchOutside: !policy.isBlocking,
      dialogType:
          policy.isBlocking ? DialogType.error : DialogType.warning,
      headerAnimationLoop: false,
      showCloseIcon: !policy.isBlocking,
      animType: AnimType.bottomSlide,
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Center(child: Text('يتوفر إصدار جديد')),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Center(child: Text(policy.message)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () => _launchStore(policy.storeUrl),
              child: const Text('تحديث'),
            ),
          ),
        ],
      ),
    ).show();
  }

  Future<void> _launchStore(String link) async {
    final url = link.isNotEmpty ? link : Urls.googleStoreAppLink;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
