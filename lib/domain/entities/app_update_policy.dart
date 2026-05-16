/// Force-update policy derived from `GET /app-config`.
class AppUpdatePolicy {
  const AppUpdatePolicy({
    required this.shouldPrompt,
    required this.targetVersion,
    required this.message,
    required this.isBlocking,
    required this.storeUrl,
  });

  final bool shouldPrompt;
  final String targetVersion;
  final String message;
  final bool isBlocking;
  final String storeUrl;

  static const empty = AppUpdatePolicy(
    shouldPrompt: false,
    targetVersion: '',
    message: '',
    isBlocking: false,
    storeUrl: '',
  );
}
