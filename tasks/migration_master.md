# Goal:

تحويل تطبيق نبض اليمن من الاعتماد على Firebase (بيانات، مصادقة، تخزين وسائط) إلى API الباكإند الجديد (`https://nabdh.telqaia.com/api/v1`) مع الإبقاء على FCM فقط، واعتماد **Bloc** بدل Cubit، و**Drift + secure storage + shared_preferences** بدل Hive — ثم تطوير الميزات والإصلاحات.

# Plan:

1. المرحلة 0 — الأساس: شبكة، تخزين، DI، منصات → `docs/restructure/المرحلة-0-الأساس/`
2. المرحلة 1 — المصادقة: AuthBloc، جلسة، OTP → `docs/restructure/المرحلة-1-المصادقة/`
3. المرحلة 2 — المتبرع: ملف شخصي، بحث، مواقع → `docs/restructure/المرحلة-2-المتبرع/`
4. المرحلة 3 — المركز: ملف المركز، مخزون → `docs/restructure/المرحلة-3-المركز/`
5. المرحلة 4 — المحتوى والإشعارات: app-config، ملفات، FCM → `docs/restructure/المرحلة-4-المحتوى-والإشعارات/`
6. المرحلة 5 — طلبات الدم (ميزة جديدة) → `docs/restructure/المرحلة-5-الميزات-الجديدة/`
7. المرحلة 6 — الإغلاق: إزالة Cubit/Firestore، اختبار، نشر → `docs/restructure/المرحلة-6-الإغلاق/`

# Progress:

**تتبّع يومي:** علِّم البنود الفرعية أدناه أثناء العمل. عند دمج PR، يُستحسن إضافة مرجع مختصر بجانب البند (مثلاً `#123` أو عنوان الـ commit) حتى لا يبقى التقدّم على مستوى «ملف كامل» فقط.

## التخطيط والبنية
- [x] قواعد Cursor (`.cursor/rules/`)
- [x] خطط `docs/restructure/` (كل المراحل)
- [x] ملف المهمة الرئيسي (`tasks/migration_master.md`)

## المرحلة 0 — الأساس
- [x] 00 — نظرة عامة والمراحل (قراءة/اتفاق فريقي على الترتيب وعدم Admin)
- [x] 01 — شبكة وجلسة: Dio، اعتراضات JWT + refresh + `x-device-id`، `ApiClient`/`ApiEndpoints`/`AppConfig(apiBaseUrl)`، توسعة `failures`
- [x] 02 — تخزين: مصادر جلسة (secure tokens + meta)، `PreferencesLocalDataSource` (device UUID)، كاش مواقع يدويًا عبر SharedPreferences (+ JSON؛ الانتقال لـ Drift عند تشغيل `build_runner`)
- [x] 03 — DI: ترتيب GetIt؛ `MapsCubit`؛ `AuthBloc lazySingleton`; بلا `initSignIn`/`initSignUp`.

## المرحلة 1 — المصادقة
- [x] 04 — مصادقة: `AuthBloc` + REST، توجيه Splash/Logout، `BLOCKED` + 400 تسجيل مكرر، `test/blocs/auth_bloc_test.dart` — إغلاق المرحلة 1 (2026-05-16).

## المرحلة 2 — المتبرع
- [x] 05 — ملف المتبرع: `ProfileBloc` + `GET/PATCH /donors/me`، picker مواقع API، رفع صورة `/files/upload` + `FileUrlResolver`؛ Firebase للمركز مؤقتاً
- [x] 06 — بحث ومواقع: `SearchBloc`، `GET /donor-search`/`/manual`، `/centers`، picker مواقع API، خريطة من نتائج البحث؛ حذف `SearchCubit`/`MapsCubit`؛ Drift schema في `lib/data/local/drift/` — شغّل `dart run build_runner build` عند تفعيل SQLite cache

## المرحلة 3 — المركز
- [x] 07 — مركز ومخزون: `CenterBloc`، `GET/PATCH /centers/me`، stock deltas، `POST /centers/me/donations`، سجل المخزون؛ حذف `ProfileCubit` + Firestore centers (`tasks/center_phase3.md`)

## المرحلة 4 — المحتوى والإشعارات
- [x] 08 — إعدادات التطبيق والملفات: `AppConfigBloc`، `GET /app-config`، قوائم السلايدر/الفعاليات، force-update من app-config، حذف `GlobalCubit` (`tasks/phase4_content.md`)
- [x] 09 — إشعارات FCM: `FcmService` + `onTokenRefresh`، `NotificationsBloc` + `/notifications`، حذف `SendNotficationCubit`/HTTP FCM، تنظيف `home_page`

## المرحلة 5 — ميزات جديدة
- [x] 10 — طلبات الدم: Bloc + مستودع، إنشاء/إلغاء/الحدود (429)، عدم broadcast من العميل (`tasks/phase5_blood_requests.md`)

## المرحلة 6 — الإغلاق
- [x] 11 — مراجعة بقايا Cubit/Firestore/Hive ومسارات Firebase غير المرغوبة (`tasks/phase6_closure.md`)
- [x] 12 — `pubspec` وتنظيف: إزالة حزم Firebase غير `core`/`messaging`، إزالة Hive، Drift locations، حذف أسرار FCM legacy
- [x] 13 — `flutter test` + `flutter analyze`؛ checklist يدوي/نشر Play عند الجاهزية (انظر `phase6_closure.md`)

# Context:

- دليل API: `docs/backend_guide/`
- متطلبات باكإند (منطق من العميل): `docs/restructure/متطلبات-الباكإند/`
- خطط التنفيذ: `docs/restructure/README.md`
- قواعد الوكيل: `.cursor/rules/main.mdc`, `code.mdc`, `task.mdc`
- API إنتاج: `https://nabdh.telqaia.com/api/v1`
- API محلي: `http://localhost:3000/api/v1`
- لا Admin في هذه المرحلة
- مستخدمون قدامى Firebase: OTP / نسيت كلمة المرور (لا `POST /auth/migration/complete`)
- تسجيل جديد: هاتف + كلمة مرور (لا Firebase Phone OTP)
- استبدال Cubit: **فوري** مع كل مرحلة — المرحلة 11 تدقيق فقط
- تقليل منطق العميل (`عميل رفيع`): `docs/restructure/المرحلة-0-الأساس/عميل-رفيع-ومصدر-الحقيقة.md`
- خريطة تعليقات `BACKEND` في الكود: `docs/restructure/نقاط-الربط-مع-الباكإند-في-الكود.md`
- **دليل المطور (تشغيل، بيئة، تشخيص):** `docs/developer-guide.md`
- **Drift للمواقع:** مُنفَّذ (`lib/data/local/drift/`, `LocationsLocalDataSource`) — المرحلة 2.
- **`AppConfigBloc` + `GET /app-config`:** مُنفَّذ — المرحلة 4؛ لا `GlobalCubit`/Firestore.
- **مفاتيح app-config:** يدعم الكود `min_app_version` و`updating__*`؛ الإنتاج قد يعيد `updating__*` فقط — انظر `app_config_mapper.dart`.
- **iOS + FCM:** `GoogleService-Info.plist` + `firebase_options.dart` — انظر `docs/ios-firebase-setup.md`.
