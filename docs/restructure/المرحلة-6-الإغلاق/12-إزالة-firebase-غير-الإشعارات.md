# 12 — إزالة Firebase (ما عدا الإشعارات)

## الهدف

**تدقيق نهائي** لـ `pubspec` وGradle — إزالة أي بقايا Firestore/Auth/Storage. يُفترض أن كل مرحلة (1–4) أزالت استخداماتها بالفعل؛ هذه المرحلة لا تؤجل الإزالة إلى النهاية فقط.

## إزالة تدريجية (مرجع حسب المرحلة)

| المرحلة | ما يُزال من Firebase/Hive |
|---------|---------------------------|
| 1 | `firebase_auth`, كتابة Firestore في auth |
| 2 | استعلامات `donors`, Hive متبرع |
| 3 | `centers` collection |
| 4 | `global_app_data`, Storage, `updating`, HTTP FCM |
| 6 | حزم pubspec + ملفات dev (`firebase_analyzer`) |

## `pubspec.yaml` — قبل / بعد

### يُزال

```yaml
cloud_firestore:
firebase_auth:
firebase_storage:
firebase_app_check:    # غير مستخدم
hive:
hive_flutter:
```

### يُبقى

```yaml
firebase_core:
firebase_messaging:
```

## ملفات تُحذف أو تُنظَّف

| مسار | إجراء |
|------|--------|
| `lib/firebase_options.dart` | إبقاء لـ Android FCM — إعادة توليد عند iOS |
| `lib/core/firebase_analyzer.dart` | حذف (أداة dev Firestore) |
| `lib/data/models/compare_hive_firbaase.dart` | حذف |
| `lib/data/repositories/auth_repo_impl.dart` (القديم) | استبدال بالكامل |
| `lib/data/repositories/search_repo_impl.dart` (قديم) | استبدال |
| `lib/data/repositories/global_repo_impl.dart` (قديم) | استبدال |
| `lib/data/repositories/profile_repository_impl.dart` (قديم) | استبدال |
| `lib/data/repositories/send_notfication_impl.dart` | حذف |
| `firebase.json` | اختياري — إبقاء لـ FlutterFire CLI |

## `main.dart`

| قبل | بعد |
|-----|-----|
| `Firebase.initializeApp` + Firestore seed في home | `initializeApp` للـ FCM فقط |
| imports firestore | لا |

## Android

| ملف | إجراء |
|-----|--------|
| `android/app/build.gradle.kts` | إزالة dependencies غير ضرورية لـ analytics إن لم تُستخدم |
| `AndroidManifest.xml` | الإبقاء على FCM meta-data |
| `google-services.json` | مطلوب لـ FCM |

## iOS / Web (مستقبل)

- عند دعم iOS: `flutterfire configure` → تحديث `firebase_options.dart`.
- Web: تقييم دعم FCM على الويب منفصلاً.

## تحقق نهائي

```bash
# من جذر المشروع — بعد التنفيذ
rg "firebase_auth|cloud_firestore|firebase_storage|FirebaseFirestore|FirebaseAuth" lib/
rg "hive|Hive" lib/
```

المتوقع: **لا نتائج** (ما عدا تعليقات أو README).

## معايير قبول

- [ ] `flutter pub get` ينجح.
- [ ] build APK debug ينجح.
- [ ] FCM token + `/auth/device` يعمل.
- [ ] لا crash عند فتح home/search/profile.

## مخاطر

| الخطر | التخفيف |
|-------|---------|
| plugins متبقية transitive | `flutter pub deps` مراجعة |
| ProGuard | قواعد FCM في release build |

## التالي

[13-الاختبار-والنشر.md](13-الاختبار-والنشر.md)
