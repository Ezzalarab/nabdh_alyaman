# ملاحظات منصة iOS

## Swift Package Manager (SPM)

وفق [توثيق Flutter](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers):

- SPM **مفعّل** في المشروع (الوضع الافتراضي عند الترقية).
- الإضافات التي لا تدعم SPM بعد تُبنى عبر **CocoaPods** تلقائياً (fallback رسمي).
- تنبيهات البناء `The following plugins do not support Swift Package Manager` **متعمّدة** — تذكّر بقائمة الديون التقنية، لا تُعطَّل لإخفائها.

### إضافات iOS بانتظار دعم SPM (آخر تحديث 2026-05)

| الإضافة | الحزمة |
|---------|--------|
| permission_handler_apple | permission_handler |
| location | location |
| google_maps_flutter_ios | google_maps_flutter |
| fluttertoast | fluttertoast |
| flutter_secure_storage | flutter_secure_storage |
| flutter_image_compress_common | flutter_image_compress |

### macOS

| الإضافة |
|---------|
| location |
| flutter_secure_storage_macos |
| flutter_image_compress_macos |

**عند ظهور التنبيه:** راقب إصدارات الحزم أو افتح issue لدى المطوّر؛ لا تضف `enable-swift-package-manager: false` إلا إذا تعارض البناء مع SPM بالكامل (انظر التوثيق).

## objective_c

`dependency_overrides: objective_c: 9.3.0` في `pubspec.yaml` — إصلاح معروف لـ [dart-lang/native#3281](https://github.com/dart-lang/native/issues/3281) (فشل تحميل `DOBJC_initializeApi` على المحاكي)، وليس إخفاءً للخطأ.

## إصدار التطبيق الاحتياطي

إذا فشل `PackageInfo.fromPlatform`، يُستخدم `kAppVersionFallback` من `lib/core/config/app_version.dart` ويُضبط `AppConfigLoaded.usedFallback = true` — راقب السجل `AppConfigBloc` في وحدة التحكم.
