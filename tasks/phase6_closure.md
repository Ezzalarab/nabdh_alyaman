# Goal:

المرحلة 6 — الإغلاق: إزالة Hive/Firebase الزائد، تفعيل Drift لكاش المواقع، تدقيق Bloc، اختبار ونشر.

# Plan:

1. بند 11 — استبدال Hive بـ SharedPreferences؛ حذف ملفات legacy
2. بند 12 — Drift locations + تنظيف pubspec
3. بند 13 — flutter test/analyze + README + checklist يدوي

# Progress:

- [x] ملف المهمة + ربط migration_master
- [x] Hive → prefs (onboarding)
- [x] حذف legacy (compare_hive, donor_hive, firebase_analyzer, shared_method, app_constants)
- [x] Drift AppDatabase + LocationsLocalDataSource
- [x] pubspec: إزالة cloud_firestore, firebase_auth, hive, …
- [x] Equatable + BlocObserver + search_bloc_test
- [x] verify: rg + flutter analyze + flutter test
- [ ] checklist يدوي 13 + appbundle (عند النشر)

# Context:

- وثائق: `docs/restructure/المرحلة-6-الإغلاق/`
- فهرس: `tasks/migration_master.md` بنود 11–13
- تدوير مفتاح FCM Legacy في Firebase Console بعد الحذف من الكود
