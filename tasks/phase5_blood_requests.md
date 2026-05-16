# Goal:

المرحلة 5 — طلبات الدم (استغاثة) عبر REST: إنشاء، تفاصيل، إلغاء/إتمام، FCM، زر الرئيسية، خريطة البحث — دون شاشة «طلباتي».

# Plan:

1. طبقة البيانات + entity + endpoints
2. BloodRequestBloc + DI + اختبارات
3. صفحات إنشاء وتفاصيل + widgets
4. تكامل Home / FCM / الإشعارات / خريطة البحث

# Progress:

- [x] ملف المهمة + Context في migration_master
- [x] طبقة البيانات + Bloc + اختبارات
- [x] UI إنشاء + تفاصيل
- [x] تكاملات
- [x] migration_master بند 10

# Context:

- وثيقة: `docs/restructure/المرحلة-5-الميزات-الجديدة/10-طلبات-الدم.md`
- API: `docs/backend_guide/api/blood-requests-and-notifications.md`
- لا `my_blood_requests` UI؛ خريطة البحث ضمن هذه المرحلة
- فهرس: `tasks/migration_master.md` بند 10
