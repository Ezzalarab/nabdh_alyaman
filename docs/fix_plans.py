import os
import re

def process_file(filepath, replacements):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        for old, new in replacements:
            content = content.replace(old, new)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception as e:
        print(f"Error processing {filepath}: {e}")

# 1. database_schema_spec.md
replacements_schema = [
    (
        "phone             String   @unique", 
        "phone             String   // البيانات مشفرة (AES-256)\n  phoneHash         String   @unique // الفهرس الأعمى (HMAC-SHA256) للبحث وتسجيل الدخول"
    ),
    (
        "2.  **أرقام الهواتف**: بما أنها بيانات حساسة، سيتم تشفيرها باستخدام **AES-256-GCM** على مستوى الباكإند قبل حفظها. المفتاح (Secret Key) سيتم تخزينه في متغيرات البيئة (`.env`).",
        "2.  **أرقام الهواتف**: سيتم تشفير الرقم باستخدام **AES-256-CBC/GCM** قبل الحفظ. ولتفعيل نظام تسجيل الدخول، سيتم استخدام **فهرس أعمى (Blind Index)** عبر استخراج `HMAC-SHA256` للرقم وتخزينه في حقل `phoneHash` لغرض المقارنة (Querying) فقط."
    ),
    (
        "## 4. الفهارس والتحسينات (Indexes & Constraints)",
        "## 4. الفهارس والتحسينات (Indexes & Constraints)\n\n### أ. الفهرسة المكانية للحفاظ على المعالج (CPU)\nلضمان سرعة البحث وعدم إرهاق السيرفر بعمليات المسح التسلسلي، يجب تنفيذ استعلام الفهرس المكاني التالي في قاعدة البيانات:\n```sql\nCREATE INDEX idx_user_coords ON \"DonorProfile\" USING GIST (coords);\n```\n"
    )
]
process_file('database_schema_spec.md', replacements_schema)

# 2. backend_implementation.md
replacements_backend = [
    (
        "const iv = randomBytes(16);",
        "const iv = randomBytes(16);\n  // ملاحظة: يُستخدم الفهرس الأعمى (Blind Index) HMAC للبحث وتسجيل الدخول\n  // const phoneHash = createHmac('sha256', process.env.HMAC_KEY).update(phone).digest('hex');"
    ),
    (
        "هندسة الوحدات والمجلدات (Modular Architecture)",
        "هندسة الوحدات والمجلدات (Modular Architecture)\n\n> [!TIP]\n> **تطبيق مبدأ الثقة الصفرية Zero-Trust**: سيتم بناء حراس Roles Guard لكل مسار (Endpoint). على سبيل المثال، لا يُرسل الباكإند أي بيانات عن المخزون الطبي أو بيانات المستخدمين الخاصة ما لم يكن الـ Token العائد للمستخدم يمتلك صلاحية `CENTER` أو `ADMIN`. عدم الثقة بالـ Client-side Rule هو أساس الحماية."
    ),
    (
        "```sql\nSELECT id, full_name, ",
        "**ملاحظة هامة جداً**: يجب تنفيذ الفهرس هذا في PostgreSQL مباشرة لضمان السرعة ومنع اختناق السيرفر (CPU Bottleneck):\n```sql\nCREATE INDEX idx_user_coords ON \"DonorProfile\" USING GIST (coords);\n```\n\n```sql\nSELECT id, full_name, "
    ),
    (
        "- `max_connections`: تقليله إلى 30 اتصال.",
        "- `max_connections`: تقليله إلى 30 اتصال.\n- **Prisma Connection Pool**: نظراً لأن السيرفر يحتوي على 4 جيجابايت مشتركة مع مشاريع أخرى، سيتم تقليل سقف سحب البيانات لـ Prisma عبر إضافة `?connection_limit=5` لتخفيف الضغط على ذاكرة الخادم."
    ),
    (
        "## 8. هجرة البيانات",
        "## 8. هجرة البيانات"
    )
]
process_file('backend_implementation.md', replacements_backend)

# 3. strategic_audit.md
replacements_audit = [
    (
        "### ب. سقف الموارد (Hardware Ceiling)\n- **الإشكالية**: سيرفر 1GB رام قد ينهار عند زيادة عدد المتبرعين وعمليات ST_DWithin المكثفة.\n- **الحل المقترح**: مراقبة مستمرة للـ RAM وتحديد \"نقطة التوسع\" (Scaling Point) للانتقال لسيرفر أقوى.",
        "### ب. سقف الموارد المشتركة (Shared Hardware Ceiling)\n- **الإشكالية**: السيرفر يمتلك 4GB RAM ولكنه مخصص لعدة مشاريع (Laravel, Python وغيرها). استخدام Prisma دون قيود قد يؤدي لـ OOM (نفاد الذاكرة).\n- **الحل المقترح**: تحديد سقف لبركة اتصالات قواعد البيانات (Connection Pool) الخاص بـ Prisma إلى 5 اتصالات متفرعة، وإنشاء فهرس GIST لتخفيف عبء معالجة (CPU) عمليات ST_DWithin."
    ),
    (
        "### ب. منطق الاستغاثة الذكي (Intelligent Broadcast)\n- **الإشكالية**: الإرسال الجماعي يسبب \"إرهاق الإشعارات\" (Notification Fatigue).\n- **الحل**: البث المستهدف بناءً على الموقع والفصيلة فقط، واستخدام نظام الدفعات (Batches).",
        "### ب. منطق الاستغاثة الذكي وتنظيف التوكنات \n- **الإشكالية**: تراكم التوكنات המيتة للمستخدمين الذين حذفوا التطبيق سيرهق الشبكة الخادم.\n- **الحل المقترح**: إضافة آلية لاصطياد خطأ `NotRegistered` من إجابات Firebase Admin SDK ومسح التوكن من خادم Postgres فوراً، مع تقسيم الإرسال إلى (Batches)."
    ),
    (
        "### أ. مخاطر كشف منطق الإدارة (Admin Logic Exposure)",
        "### أ. مخاطر الثقة بالعميل (Client-Trust Logic Exposure)"
    ),
    (
        "والضمان عدم إرسال بيانات إدارية إلا للأدوار المصرح لها (RBAC).",
        "والضمان عدم إرسال بيانات إدارية إطلاقاً (وإرجاع 403 Forbidden) إلا للأدوار المصرح لها (RBAC) باستخدام Guards مبنية في NestJS صراحةً."
    )
]
process_file('strategic_audit.md', replacements_audit)

print("Updates applied successfully.")
