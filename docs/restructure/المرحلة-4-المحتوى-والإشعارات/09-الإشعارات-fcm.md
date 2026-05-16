# 09 — الإشعارات FCM

## الهدف

الإبقاء على FCM للاستقبال فقط، ربط التوكن بالـ API، واستبدال قائمة/قراءة الإشعارات عبر `/notifications` — **إزالة** إرسال HTTP FCM القديم.

**تنسيق باكإند:** [`متطلبات-الباكإند/01-الإشعارات-وFCM.md`](../متطلبات-الباكإند/01-الإشعارات-وFCM.md) و [`06-الأمان-وأسرار-العميل.md`](../متطلبات-الباكإند/06-الأمان-وأسرار-العميل.md).

## الوضع الحالي

| الملف | السلوك |
|-------|--------|
| `firebase_messaging` | token في cubits → Firestore |
| `send_notfication_impl.dart` | HTTP إلى `fcm.googleapis.com/fcm/send` |
| `send_notfication_cubit.dart` | إرسال لمستخدمين |
| `home_page.dart` | helpers إرسال + listeners معطّلة |
| `notfication_page.dart` | UI معطّل/قديم |

## ما يبقى من Firebase

```yaml
dependencies:
  firebase_core: ^4.x
  firebase_messaging: ^16.x
```

- `Firebase.initializeApp` في `main.dart` **للـ FCM فقط**.
- إعادة `firebase_options.dart` لـ Android (ولاحقاً iOS عند التوسع).

## تقسيم العمل بين المرحلتين 1 و 4

| الجزء | المرحلة |
|-------|---------|
| `getToken` + `POST /auth/device` + `onTokenRefresh` | **1** (مع AuthBloc) |
| قائمة `/notifications` + UI + `notification_router` | **4** |
| حذف `send_notfication_impl` (HTTP FCM) | **4** |

## تسجيل الجهاز

راجع [`client-integration.md`](../../backend_guide/client-integration.md)

| متى | Endpoint | Body |
|-----|----------|------|
| فتح التطبيق | `POST /auth/device` | `{ token, platform: "android" }` |
| بعد login | نفس + JWT | يربط التوكن بالمستخدم |
| logout | `POST /auth/logout` | يتضمن `deviceToken` |

## NotificationsBloc

### Events

- `NotificationsLoadRequested` (cursor pagination)
- `NotificationMarkRead` (id)
- `NotificationsMarkAllRead`
- `NotificationReceived` (من FCM foreground/background)

### API

[`docs/backend_guide/api/blood-requests-and-notifications.md`](../../backend_guide/api/blood-requests-and-notifications.md)

| Method | Path |
|--------|------|
| GET | `/notifications` |
| PATCH | `/notifications/:id/read` |
| PATCH | `/notifications/read-all` |

### FCM payload

```json
{ "data": { "type": "BLOOD_REQUEST", "requestId": "123" } }
```

عند `type == BLOOD_REQUEST`: التنقل لصفحة تفاصيل الطلب (مرحلة 10).

## handlers

```text
lib/core/notifications/
  fcm_service.dart           # token, onMessage, onBackgroundMessage
  notification_router.dart   # data.type → route
```

- `onBackgroundMessage` top-level function → `Firebase.initializeApp` إن لزم.
- foreground: `FlutterLocalNotificationsPlugin` (اختياري) لعرض banner.

## الملفات — إنشاء / تعديل / حذف

| إجراء | مسار |
|-------|------|
| إنشاء | `fcm_service.dart`, `notifications_remote_ds`, `NotificationsBloc` |
| حذف | `send_notfication_impl.dart` |
| **حذف في المرحلة 4** | `send_notfication_cubit/`, `send_notfication_.dart` use case |
| تعديل | `home_page.dart` — إزالة HTTP send helpers |
| تعديل | `di.dart` — إزالة SendNotification |
| إعادة تفعيل/كتابة | `notfication_page.dart` → قائمة API |

## معايير قبول

- [ ] token يُرسل عند الفتح وعند login.
- [ ] logout يفك الربط عبر API.
- [ ] قائمة إشعارات in-app من `/notifications`.
- [ ] لا طلبات إلى `fcm.googleapis.com/fcm/send` من العميل.
- [ ] فتح إشعار `BLOOD_REQUEST` يوجّه (stub حتى مرحلة 10).

## مخاطر

| الخطر | التخفيف |
|-------|---------|
| token منتهي | `onTokenRefresh` → `POST /auth/device` |
| إذن إشعارات Android 13+ | طلب runtime permission |

## التالي

[10-طلبات-الدم.md](../المرحلة-5-الميزات-الجديدة/10-طلبات-الدم.md)
