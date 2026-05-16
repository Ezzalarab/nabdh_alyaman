import '../data/datasources/local/session_local_datasource.dart';
import '../domain/entities/blood_center.dart';
import '../domain/entities/donor.dart';
import '../di.dart' as di;

/// In-memory holder for loaded donor/center profiles during a session.
class CheckActive {
  static Donor? currentDonor;
  static BloodCenter? currentBloodCenter;

  static Future<void> checkActiveUser() async {
    final session = di.gi<SessionLocalDataSource>();
    final role = await session.getRole();
    if (role == null) {
      currentDonor = null;
      currentBloodCenter = null;
    }
  }
}
