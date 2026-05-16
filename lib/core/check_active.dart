import 'package:hive/hive.dart';

import '../data/datasources/local/session_local_datasource.dart';
import '../domain/entities/blood_center.dart';
import '../domain/entities/donor.dart';
import '../di.dart' as di;
import 'constants/storage_keys.dart';

/// Legacy static holder for donor/center payloads (Firestore-backed). Prefer REST
/// `GET …/me` in later phases — see `docs/backend_guide/api/authentication.md`.
class CheckActive {
  static Donor? currentDonor;
  static BloodCenter? currentBloodCenter;

  static Future<void> checkActiveUser() async {
    final session = di.gi<SessionLocalDataSource>();
    final role = await session.getRole();
    final box = Hive.box(dataBoxName);
    if (role == null) {
      await box.put('user', '0');
      currentDonor = null;
      currentBloodCenter = null;
      return;
    }
    await box.put(
      'user',
      role == 'CENTER' ? '2' : '1',
    );
  }
}
