/// Collects listeners for session expiry (e.g. failed token refresh).
/// [AuthBloc] will subscribe in Phase 1; until then this is a no-op unless wired.
class SessionLifecycle {
  final List<void Function()> _onSessionExpired = [];

  void addSessionExpiredListener(void Function() listener) {
    _onSessionExpired.add(listener);
  }

  void removeSessionExpiredListener(void Function() listener) {
    _onSessionExpired.remove(listener);
  }

  void notifySessionExpired() {
    for (final listener in List<void Function()>.from(_onSessionExpired)) {
      listener();
    }
  }
}
