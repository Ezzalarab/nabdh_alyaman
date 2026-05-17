# إعداد Firebase لـ iOS (FCM)

التطبيق يستخدم `firebase_core` + `firebase_messaging` فقط. بعد تنفيذ الخطوات أدناه، شغّل من جذر المشروع:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=nabdh-alyaman --platforms=ios,android
```

هذا يحدّث `lib/firebase_options.dart` ويضيف `ios/Runner/GoogleService-Info.plist`.

## يدوياً (إن لم يعمل FlutterFire)

1. في [Firebase Console](https://console.firebase.google.com/) → مشروع `nabdh-alyaman` → أضف تطبيق **iOS**.
2. Bundle ID: نفس `PRODUCT_BUNDLE_IDENTIFIER` في Xcode (غالباً من `ios/Runner.xcodeproj`).
3. حمّل `GoogleService-Info.plist` إلى `ios/Runner/GoogleService-Info.plist`.
4. أعد تشغيل `flutterfire configure` أو انسخ قيم iOS إلى `DefaultFirebaseOptions.ios` في `lib/firebase_options.dart`.

## Xcode / Capabilities

- **Push Notifications** capability.
- **Background Modes** → Remote notifications.
- على الجهاز: إذن الإشعارات عند أول تشغيل.

## تحقق

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run -d <ios-device-id>
```

بعد نجاح التهيئة، `DefaultFirebaseOptions.currentPlatform` يجب ألا يرمي `UnsupportedError` على iOS.
