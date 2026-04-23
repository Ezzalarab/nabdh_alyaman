# الدليل التقني التفصيلي لتنفيذ الباكإند (NestJS + Prisma + PostgreSQL)

هذا المستند هو المرجع الشامل لكافة الجوانب التقنية لتطوير الباكإند، صُمم ليكون دليلاً خطوة بخطوة يمنع أي غموض أو خطأ استراتيجي.

---

## 1. مرحلة التأسيس للمشروع (Project Initialization)

### أ. إنشاء المشروع
```bash
npm i -g @nestjs/cli
nest new nabdh-backend
cd nabdh-backend
```

### ب. تثبيت التبعات الأساسية
```bash
# Prisma — ORM للتعامل مع PostgreSQL
npm install prisma --save-dev
npm install @prisma/client
npx prisma init

# Auth و JWT
npm install @nestjs/jwt @nestjs/passport passport passport-jwt bcryptjs
npm install -D @types/passport-jwt @types/bcryptjs

# الحماية والتحقق من المدخلات
npm install @nestjs/throttler class-validator class-transformer

# التشفير (AES-256-GCM لأرقام الهواتف)
# مدمج في Node.js — لا حاجة لحزمة خارجية
# نستخدم: import { createCipheriv, createDecipheriv, randomBytes, createHmac } from 'crypto'

# FCM (إشعارات Firebase)
npm install firebase-admin

# التواريخ
npm install luxon
npm install -D @types/luxon
```

---

## 2. هندسة الوحدات والمجلدات (Modular Architecture)

> [!TIP]
> **مبدأ الثقة الصفرية (Zero-Trust)**: الباكإند لا يُرسل أي بيانات حساسة (مخزون، بيانات إدارية) إلا للأدوار المصرح لها عبر `RolesGuard`. لا ثقة بالـ Client-side أبداً.

```text
/src
  /auth           # المصادقة (Login, Signup, JWT) والحماية والأدوار
  /donors         # بيانات المتبرعين وملفاتهم الشخصية
  /donor-search   # محرك البحث الجغرافي عن متبرعين
  /centers        # مراكز الدم وإدارة المخزون
  /locations      # جلب شجرة المواقع (محافظات، مديريات، أحياء)
  /blood-requests # طلبات الاستغاثة العاجلة
  /notifications  # الإشعارات عبر FCM
  /files          # Proxy آمن لرفع وجلب الملفات
  /app-config     # إدارة إعدادات التطبيق (CMS)
  /prisma         # PrismaService المشترك بين الوحدات
```

> **ملاحظة التسمية**: تم فصل `/donors` (إدارة بيانات المتبرع) عن `/donor-search` (محرك البحث الجغرافي) لتجنب الغموض.

---

## 3. حماية البيانات والتشفير

### أ. تشفير كلمات المرور
```typescript
import * as bcryptjs from 'bcryptjs';

// التشفير عند التسجيل
const passwordHash = await bcryptjs.hash(plainPassword, 12);

// التحقق عند تسجيل الدخول
const isValid = await bcryptjs.compare(plainPassword, passwordHash);
```

> **ملاحظة**: Bcryptjs تم اختياره لسهولة التوافق مع بيانات Firebase المهاجرة مستقبلاً عند إعادة ضبط كلمات المرور.

### ب. تشفير أرقام الهواتف (AES-256-GCM)
```typescript
import { createCipheriv, createDecipheriv, randomBytes, createHmac } from 'crypto';

const ENCRYPTION_KEY = Buffer.from(process.env.ENCRYPTION_KEY, 'hex'); // 32 byte = 64 hex chars
const HMAC_KEY = process.env.HMAC_KEY;

// تشفير الرقم قبل الحفظ في قاعدة البيانات
export function encryptPhone(phone: string): string {
  const iv = randomBytes(12); // 12 bytes لـ GCM
  const cipher = createCipheriv('aes-256-gcm', ENCRYPTION_KEY, iv);
  let encrypted = cipher.update(phone, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  const authTag = cipher.getAuthTag().toString('hex');
  // تخزين: iv:authTag:ciphertext
  return `${iv.toString('hex')}:${authTag}:${encrypted}`;
}

// فك التشفير عند عرض الرقم للمشرف
export function decryptPhone(stored: string): string {
  const [ivHex, authTagHex, encrypted] = stored.split(':');
  const iv = Buffer.from(ivHex, 'hex');
  const decipher = createDecipheriv('aes-256-gcm', ENCRYPTION_KEY, iv);
  decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}

// استخراج الفهرس الأعمى للبحث وتسجيل الدخول
export function hashPhone(phone: string): string {
  return createHmac('sha256', HMAC_KEY).update(phone).digest('hex');
}
```

### ج. حماية الـ API (Rate Limiting)
```typescript
// app.module.ts
import { ThrottlerModule } from '@nestjs/throttler';

ThrottlerModule.forRoot([{
  name: 'default',
  ttl: 60000,  // نافذة زمنية: دقيقة
  limit: 30,   // الحد الافتراضي: 30 طلباً في الدقيقة
}]),
```

> **للاستغاثة تحديداً**: استخدام `@Throttle({ default: { limit: 5, ttl: 60000 } })` على endpoint طلبات الاستغاثة.

---

## 4. نظام المصادقة (Auth System — JWT)

### أ. استراتيجية JWT
- **خوارزمية التوقيع**: `HS256` باستخدام `JWT_SECRET` من `.env`
- **مدة صلاحية Access Token**: `7d` (7 أيام)
- **لا Refresh Token مرحلياً**: التطبيق يطلب من المستخدم تسجيل الدخول مجدداً بعد الانتهاء (يُبسّط التنفيذ في المرحلة الأولى).

### ب. محتوى الـ JWT Payload
```typescript
interface JwtPayload {
  sub: string;  // user.id
  role: Role;   // DONOR | CENTER | ADMIN | SUPER_ADMIN
  iat: number;
  exp: number;
}
```

### ج. حماية نقاط الـ API (Guards)
```typescript
// حماية بالدور — مثال على Endpoint خاص بالمشرف فقط
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN, Role.SUPER_ADMIN)
@Get('admin/dashboard')
getDashboard() { ... }
```

### د. تسجيل الخروج (Logout)
في المرحلة الأولى: يكتفي التطبيق بحذف الـ Token من الجهاز (Client-side). لا يلزم Blacklisting.

---

## 5. منطق البحث الجغرافي المتقدم (Geospatial Logic)

بما أن Prisma لا تدعم `Geography` بشكل كامل، نستخدم `$queryRaw`:

```typescript
// donor-search.service.ts
async searchDonors(lat: number, lon: number, bloodType: string, radiusKm: number) {
  const radiusMeters = radiusKm * 1000;
  return this.prisma.$queryRaw`
    SELECT
      dp."userId",
      dp."fullName",
      dp."bloodType",
      dp."imageUrl",
      ST_Distance(dp.coords, ST_MakePoint(${lon}, ${lat})::geography) / 1000 AS distance_km
    FROM "DonorProfile" dp
    WHERE dp."isShown" = true
      AND dp."bloodType" = ${bloodType}
      AND ST_DWithin(dp.coords, ST_MakePoint(${lon}, ${lat})::geography, ${radiusMeters})
    ORDER BY distance_km ASC
    LIMIT 50
  `;
}
```

> **الفهرس الضروري** (يُنفَّذ مرة واحدة في قاعدة البيانات):
> ```sql
> CREATE INDEX IF NOT EXISTS idx_donor_coords ON "DonorProfile" USING GIST (coords);
> ```

---

## 6. تخزين الملفات (File Storage)

الملفات تُخزن محلياً على السيرفر في مجلد `uploads/` خارج مجلد المشروع.

### أ. هيكل التخزين
```
/var/www/nabdh-uploads/
  /avatars/          # صور المتبرعين والمراكز
  /events/           # صور الفعاليات
```

### ب. آلية الوصول الآمن
1. التطبيق يطلب الصورة عبر `GET /api/v1/files/:fileId`.
2. الباكإند يتحقق من صحة الـ `fileId` ووجوده في جدول `StoredFile`.
3. الملف العام (`isPublic = true`): يُرسل مباشرة.
4. الملف الخاص: يتحقق من أن الـ Token يملك صلاحية الوصول.
5. **Nginx X-Accel-Redirect**: تفريغ عبء البث عن Node.js — الباكإند يُرسل الـ Header وNginx يُرسل الملف.

```nginx
# إعداد Nginx لـ X-Accel-Redirect
location /protected-uploads/ {
  internal;
  alias /var/www/nabdh-uploads/;
}
```

```typescript
// files.controller.ts
@Get(':fileId')
async serveFile(@Param('fileId') fileId: string, @Res() res: Response) {
  const file = await this.filesService.findById(fileId);
  // Nginx يستلم الطلب ويُرسل الملف مباشرة
  res.set('X-Accel-Redirect', `/protected-uploads/${file.storedPath}`);
  res.send();
}
```

---

## 7. الإشعارات (Firebase Cloud Messaging)

```typescript
// notifications.service.ts
import * as admin from 'firebase-admin';

async sendToToken(token: string, title: string, body: string) {
  try {
    await admin.messaging().send({ token, notification: { title, body } });
  } catch (error) {
    // إذا كان التوكن منتهياً أو غير صالح — احذفه من قاعدة البيانات
    if (error.code === 'messaging/registration-token-not-registered') {
      await this.prisma.user.update({
        where: { fcmToken: token },
        data: { fcmToken: null },
      });
    }
  }
}

// إرسال لمجموعة (Batch) — حد Firebase هو 500 رسالة في الدفعة
async sendBatch(tokens: string[], title: string, body: string) {
  const chunks = chunk(tokens, 500); // تقسيم إلى دفعات
  for (const batch of chunks) {
    const message: admin.messaging.MulticastMessage = {
      tokens: batch,
      notification: { title, body },
    };
    const response = await admin.messaging().sendEachForMulticast(message);
    // تنظيف التوكنات الميتة
    response.responses.forEach((res, index) => {
      if (!res.success && res.error?.code === 'messaging/registration-token-not-registered') {
        this.cleanDeadToken(batch[index]);
      }
    });
  }
}
```

---

## 8. استراتيجية النشر (Bare-metal Deployment)

نظراً لمحدودية موارد السيرفر (4GB RAM مشتركة)، نعتمد التنصيب المباشر بدون Docker.

### أ. سكربت الإعداد الأولي للسيرفر
```bash
#!/bin/bash
# setup-server.sh
sudo apt update && sudo apt upgrade -y

# تثبيت Node.js v20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# تثبيت PostgreSQL 16 وPostGIS
sudo apt install -y postgresql-16 postgresql-16-postgis-3

# تفعيل PostGIS
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# تثبيت Nginx و PM2
sudo apt install -y nginx
sudo npm install -g pm2

# إنشاء مجلد الملفات
sudo mkdir -p /var/www/nabdh-uploads/avatars
sudo mkdir -p /var/www/nabdh-uploads/events
sudo chown -R $USER:$USER /var/www/nabdh-uploads
```

### ب. إعدادات PostgreSQL الموصى بها (مناسبة للـ 4GB)
في ملف `/etc/postgresql/16/main/postgresql.conf`:
```
shared_buffers = 128MB
work_mem = 4MB
max_connections = 30
```

### ج. تشغيل التطبيق (PM2)
```bash
# بناء المشروع
npm run build

# تشغيل مع PM2
pm2 start dist/main.js --name "nabdh-backend"
pm2 save
pm2 startup  # لضمان التشغيل عند إعادة تشغيل السيرفر
```

### د. إعداد Prisma لتناسب موارد السيرفر
في `DATABASE_URL` داخل `.env`:
```
DATABASE_URL="postgresql://user:pass@localhost:5432/nabdh_db?connection_limit=5"
```

---

## 9. معايير التوقيت العالمي (Timezone Management)

- **قاعدة البيانات**: تخزين بصيغة **UTC** (`TIMESTAMPTZ`).
- **الباكإند**: مكتبة `Luxon` للتعامل مع التواريخ.
- **التطبيق**: يحول UTC إلى التوقيت المحلي للمستخدم (GMT+3 في اليمن).

---

## 10. ملاحظات مستقبلية

- **نظام التحقق الطبي**: منع التبرع إذا مرّ أقل من 90 يوماً (يعتمد على جدول `Donation`).
- **لوحة تحكم ويب**: مؤجلة — التركيز الآن على استقرار تطبيق الموبايل.

---

> [!IMPORTANT]
> جميع متغيرات البيئة المطلوبة موثقة في ملف `env_variables.md`. لا تبدأ التطوير قبل الاطلاع عليه.
