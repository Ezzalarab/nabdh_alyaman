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
- [ ] 00 — نظرة عامة والمراحل (قراءة/اتفاق فريقي على الترتيب وعدم Admin)
- [x] 01 — شبكة وجلسة: Dio، اعتراضات JWT + refresh + `x-device-id`، `ApiClient`/`ApiEndpoints`/`AppConfig(apiBaseUrl)`، توسعة `failures`
- [x] 02 — تخزين: مصادر جلسة (secure tokens + meta)، `PreferencesLocalDataSource` (device UUID)، كاش مواقع يدويًا عبر SharedPreferences (+ JSON؛ الانتقال لـ Drift عند تشغيل `build_runner`)
- [x] 03 — DI: ترتيب GetIt Phase 0، `MapsCubit` يُحمَّل من DI، `initSignIn`/`initSignUp` عند بدء التطبيق (بدون تأخير مسارات)

## المرحلة 1 — المصادقة
- [ ] 04 — مصادقة: `AuthBloc` + مصادر/مستودع بعيد، استبدال صفحات الدخول/التسجيل، مسار نسيت كلمة المرور + OTP، `NEEDS_FIREBASE_PASSWORD`، `POST /auth/device` عند الجلسة، حذف `signin_cubit` و`signup_cubit` و`initSignIn`/`initSignUp` من `di`

## المرحلة 2 — المتبرع
- [ ] 05 — ملف المتبرع: `ProfileBloc` (أو ما يعادله)، `GET/PATCH /donors/me`، رفع صورة عبر `/files`، إزالة اعتماد Hive للملف الشخصي
- [ ] 06 — بحث ومواقع: `SearchBloc`، `GET /donor-search` و`/manual`، مراكز على الخريطة، مزامنة Drift مع `/locations`، استبدال تدفق `csc_picker`/`country.json` بالمخطّط في الوثيقة

## المرحلة 3 — المركز
- [ ] 07 — مركز ومخزون: `CenterBloc`، `GET/PATCH /centers/me`، المخزون وتسجيل التبرع، رسائل `eligibleUntil` حسب العقد (بدون تكرار منطق السيرفر في العميل)

## المرحلة 4 — المحتوى والإشعارات
- [ ] 08 — إعدادات التطبيق والملفات: `AppConfigBloc` أو ما يعادله، `GET /app-config`، قوائم السلايدر/الفعاليات حسب الاستجابة الفعلية، استبدال `update.dart`/Firestore للإجبار على التحديث
- [ ] 09 — إشعارات FCM: تسجيل الرمز، `GET /notifications`، إزالة مسار إرسال FCM القديم من العميل، تكامل مع السيرفر فقط

## المرحلة 5 — ميزات جديدة
- [ ] 10 — طلبات الدم: Bloc + مستودع، إنشاء/إلغاء/الحدود (429)، عدم broadcast من العميل

## المرحلة 6 — الإغلاق
- [ ] 11 — مراجعة بقايا Cubit/Firestore/Hive ومسارات Firebase غير المرغوبة
- [ ] 12 — `pubspec` وتنظيف: إزالة حزم Firebase غير `core`/`messaging`، إزالة Hive، مراجعة أسرار وأكواد قديمة
- [ ] 13 — اختبار يدوي/وحدة حسب قائمة المرحلة 13، بناء الإصدار وباقة التحديث على Play حسب الوثيقة

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
