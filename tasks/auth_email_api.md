# Auth Email API — تحديث المصادقة والبريد

## Context

تطبيق الواجهات يحتاج مواءمة مع [`docs/backend_guide/auth-email-api-changes.md`](../docs/backend_guide/auth-email-api-changes.md): بريد إلزامي عند التسجيل، `identifier` في استعادة كلمة المرور، حقول `emailMissing`/`emailVerified`، ومسارات البريد الجديدة.

## Plan

1. إصلاحات API (register، forgot/verify، endpoints)
2. نموذج الجلسة + refresh + تخزين محلي
3. صفحة `forgot_password_page`
4. إكمال البريد (اختياري، قابل للتخطي)
5. تحقق البريد من الإعدادات
6. اختبارات + توثيق

## Progress

- [x] تحديث register (email إلزامي) + forgot/verify (identifier) + endpoints جديدة
- [x] توسيع AuthenticatedSession + parser + session storage + refresh interceptor
- [x] صفحة forgot_password_page + إزالة dialogs من sign_in
- [x] POST profile/email + complete_email_page قابل للتخطي
- [x] send-verification + verify من الإعدادات + DonorProfileDto
- [x] تحديث tests + هذا الملف

## UX

- التسجيل: بريد إلزامي؛ التحقق اختياري
- حساب قديم بلا بريد: prompt واضح قابل للتخطي
- نسيت كلمة المرور: صفحة واحدة (identifier → OTP → كلمة جديدة)
