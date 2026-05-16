Run from project root to enable SQLite location cache:
  dart run build_runner build --delete-conflicting-outputs

Then wire AppDatabase in di.dart and LocationsLocalDataSourceImpl.

Until then, locations use SharedPreferences JSON cache (same API).
