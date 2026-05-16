# Goal:

المرحلة 4 — استبدال `GlobalCubit`/Firestore بـ `GET /app-config` (08)، ثم FCM + `/notifications` (09).

# Plan:

1. 08 — `app_config` datasource/repository/mapper + `AppConfigBloc` + حذف `GlobalCubit`
2. 08 — force update من app-config + إصلاح `home_drawer` (دور الجلسة)
3. 09 — `fcm_service` + `NotificationsBloc` + صفحة الإشعارات
4. 09 — حذف `SendNotficationCubit` وتنظيف `home_page`

# Progress:

- [x] ملف المهمة + Context في migration_master
- [x] 08 طبقة البيانات + Bloc + UI
- [x] 08 اختبارات
- [x] 09 FCM + إشعارات
- [x] 09 تنظيف + اختبارات
- [x] تحديث migration_master بنود 08–09

# Context:

- وثائق: `docs/restructure/المرحلة-4-المحتوى-والإشعارات/08-*.md`, `09-*.md`
- API: `docs/backend_guide/api/files-and-app-config.md`, `blood-requests-and-notifications.md`
- **مفاتيح `GET /app-config` إنتاج (2026-05-16):** `app_name`, `about_app`, `home_header`, `home_slides` (JSON أسماء ملفات), `events_cards_data`, `events_title`, `info_list`, `info_titile`, `report_link`, `updating__*__new_version|show_dialog|message|update_link|waring_degree` — لا `min_app_version` بعد
- فهرس: `tasks/migration_master.md` بنود 08–09
