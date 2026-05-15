# دليل API — قواعد عامة

## Base URL

| البيئة | مثال |
|--------|------|
| محلي | `http://localhost:3000/api/v1` |
| إنتاج | `https://api.<your-domain>/api/v1` |

جميع المسارات أدناه **نسبية** بعد `/api/v1`.

## Headers موصى بها

| Header | مطلوب | الوصف |
|--------|--------|--------|
| `Authorization` | للمسارات المحمية | `Bearer <accessToken>` |
| `Content-Type` | للـ JSON | `application/json` |
| `x-device-id` | موصى به دائماً | معرف جهاز ثابت (لتجاوز CGNAT في اليمن) |

## تنسيق الأخطاء

```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

أخطاء خاصة قد تتضمن `code`:

```json
{
  "statusCode": 403,
  "message": "...",
  "error": "Forbidden",
  "code": "NEEDS_FIREBASE_PASSWORD"
}
```

## Throttling

- عام: ~200 طلب/دقيقة لكل `IP + x-device-id` (قابل للتعطيل: `THROTTLE_ENABLED=false`)
- `POST /auth/login`: 10 / 15 دقيقة
- `POST /auth/forgot-password`: 3 / ساعة
- `POST /blood-requests`: 5 / دقيقة
- `POST /files/upload`: 5 / 10 دقائق

## الأدوار

`DONOR` | `CENTER` | `ADMIN` — تُرجع في جسم تسجيل الدخول.

## Pagination (Cursor)

قوائم كثيرة تستخدم:

```json
{
  "items": [],
  "nextCursor": 42,
  "hasNextPage": true
}
```

الطلب التالي: `?cursor=42&limit=20` (حيث `cursor` = آخر `id` من الصفحة السابقة).

**استثناء:** البحث الجغرافي `GET /donor-search` — بدون pagination، حد 100 نتيجة.

## التواريخ

السيرفر يخزن ويُرجع **UTC** (`TIMESTAMPTZ`). حوّل للعرض محلياً في العميل.

## فهرس الوحدات

| الملف | المحتوى |
|-------|---------|
| [authentication.md](authentication.md) | تسجيل دخول، OTP، جهاز، مهاجرون |
| [donors-and-search.md](donors-and-search.md) | متبرع، بحث، مواقع |
| [centers-and-inventory.md](centers-and-inventory.md) | مراكز ومخزون |
| [blood-requests-and-notifications.md](blood-requests-and-notifications.md) | استغاثة وإشعارات |
| [files-and-app-config.md](files-and-app-config.md) | ملفات وإعدادات |
| [admin.md](admin.md) | مسارات المشرف |

دمج العميل: [client-integration.md](../client-integration.md).
