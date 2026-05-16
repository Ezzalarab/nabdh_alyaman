# البنية — وحدات NestJS

مسارات HTTP تحت البادئة العالمية **`/api/v1`** (راجع `main.ts` و `setup-app.ts`).

## وحدات رئيسية (`src/`)

| مجلد | المسؤولية |
|------|------------|
| `auth/` | تسجيل، دخول، refresh، جهاز FCM، OTP، حذف حساب، اكتمال هجرة Firebase |
| `donors/` | ملف المتبرع `me`، تاريخ التبرعات للمتبرع |
| `donor-search/` | بحث جغرافي ويدوي، تسجيل بحث (SearchLog + SystemEvent عند التفعيل) |
| `centers/` | قائمة مراكز (فلترة اختيارية)، ملف المركز، مخزون، تسجيل تبرع |
| `blood-requests/` | إنشاء طلب استغاثة، قوائم، إشعارات FCM للمتبرعين المؤهلين |
| `notifications/` | قائمة in-app، قراءة، **إرسال ADMIN** (`/admin/notifications/send`) |
| `files/` | رفع وعرض ملفات |
| `app-config/` | أزواج key/value للتطبيق والمشرف |
| `locations/` | محافظات ومديريات |
| `audit-logs/` | تسجيل أحداث نظام (مثل `SEARCH_PERFORMED`) |
| `prisma/` | طبقة DB |

`AppController` يضم مسارات عامة (`/`, `/health`) ومسارات **`/admin/*`** (إحصاءات، مستخدمون، audit).

## بحث جغرافي

بدون PostGIS — استعلام خام مع Haversine وحدود Bounding box؛ يتوافق مع قرارات التصميم في [design-decisions.md](design-decisions.md).
