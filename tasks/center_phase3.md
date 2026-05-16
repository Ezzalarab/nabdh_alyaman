# Goal:

تنفيذ المرحلة 3 — إدارة ملف المركز والمخزون عبر REST (`CenterBloc`) بدل Firestore و`ProfileCubit`.

# Plan:

1. Endpoints + `center_remote_datasource` + DTO + `CenterRepository`
2. `CenterBloc` + اختبارات
3. ترحيل `profile_center` / `edit_main_center_data` + شاشات تبرع وسجل مخزون
4. حذف `ProfileCubit` ومسارات Firestore للمركز

# Progress:

- [x] ملف المهمة
- [x] طبقة البيانات
- [x] CenterBloc
- [x] UI
- [x] تنظيف

# Context:

- وثيقة: `docs/restructure/المرحلة-3-المركز/07-المركز-والمخزون.md`
- API: `docs/backend_guide/api/centers-and-inventory.md`
- فهرس: `tasks/migration_master.md` بند 07
