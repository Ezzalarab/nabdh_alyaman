/// TTL for Drift-cached governorates/districts from `GET /locations`.
class LocationsCachePolicy {
  const LocationsCachePolicy._();

  static const Duration maxAge = Duration(days: 7);

  static bool isStale(DateTime? fetchedAt) {
    if (fetchedAt == null) return true;
    return DateTime.now().toUtc().difference(fetchedAt.toUtc()) > maxAge;
  }
}
