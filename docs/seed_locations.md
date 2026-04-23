# شجرة المواقع اليمنية — بيانات البذر (Yemen Location Seed Data)

هذا الملف يحتوي على بيانات المحافظات والمديريات الرئيسية في اليمن، جاهزة للاستيراد إلى جدول `Location` في قاعدة البيانات.

> **المصدر**: التقسيم الإداري الرسمي لليمن (22 محافظة).
> **إحداثيات مراكز المديريات**: تُستخدم كقيمة افتراضية للمتبرعين الذين لا يملكون GPS.

---

## 1. سكربت الاستيراد (Prisma Seed)

احفظ هذا الملف في: `prisma/seed/seed.ts`

```typescript
import { PrismaClient, LocationLevel } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('🌍 استيراد شجرة المواقع اليمنية...');

  // ==========================================
  // المستوى الأول: الدولة
  // ==========================================
  await prisma.location.upsert({
    where: { id: 1 },
    update: {},
    create: { id: 1, nameAr: 'اليمن', nameEn: 'Yemen', level: LocationLevel.COUNTRY, parentId: null },
  });

  // ==========================================
  // المستوى الثاني: المحافظات (22 محافظة)
  // ==========================================
  const states = [
    { id: 100, nameAr: 'أمانة العاصمة', nameEn: "Sana'a City", lat: 15.3694, lon: 44.1910 },
    { id: 101, nameAr: 'صنعاء',         nameEn: "Sana'a",       lat: 15.2240, lon: 44.2750 },
    { id: 102, nameAr: 'عدن',           nameEn: 'Aden',          lat: 12.7794, lon: 45.0367 },
    { id: 103, nameAr: 'تعز',           nameEn: "Ta'izz",        lat: 13.5774, lon: 44.0178 },
    { id: 104, nameAr: 'الحديدة',       nameEn: 'Al Hudaydah',   lat: 14.7978, lon: 42.9544 },
    { id: 105, nameAr: 'إب',            nameEn: 'Ibb',           lat: 13.9720, lon: 44.1818 },
    { id: 106, nameAr: 'حضرموت',        nameEn: 'Hadhramaut',    lat: 15.9367, lon: 48.8243 },
    { id: 107, nameAr: 'ذمار',          nameEn: 'Dhamar',        lat: 14.5422, lon: 44.4036 },
    { id: 108, nameAr: 'حجة',           nameEn: 'Hajjah',        lat: 15.6930, lon: 43.6000 },
    { id: 109, nameAr: 'البيضاء',       nameEn: 'Al Bayda',      lat: 14.0000, lon: 45.5750 },
    { id: 110, nameAr: 'الجوف',         nameEn: 'Al Jawf',       lat: 16.6573, lon: 45.5500 },
    { id: 111, nameAr: 'مأرب',          nameEn: "Ma'rib",        lat: 15.4692, lon: 45.3247 },
    { id: 112, nameAr: 'لحج',           nameEn: 'Lahij',         lat: 13.0500, lon: 44.8833 },
    { id: 113, nameAr: 'المهرة',        nameEn: 'Al Mahrah',     lat: 16.5167, lon: 51.6667 },
    { id: 114, nameAr: 'شبوة',          nameEn: 'Shabwah',       lat: 14.5333, lon: 46.9667 },
    { id: 115, nameAr: 'أبين',          nameEn: 'Abyan',         lat: 13.4667, lon: 45.6667 },
    { id: 116, nameAr: 'المحويت',       nameEn: 'Al Mahwit',     lat: 15.4681, lon: 43.5444 },
    { id: 117, nameAr: 'عمران',         nameEn: 'Amran',         lat: 15.6594, lon: 43.9439 },
    { id: 118, nameAr: 'ريمة',          nameEn: 'Raymah',        lat: 14.6667, lon: 43.7000 },
    { id: 119, nameAr: 'الضالع',        nameEn: 'Ad Dali',       lat: 13.6964, lon: 44.7322 },
    { id: 120, nameAr: 'سقطرى',         nameEn: 'Socotra',       lat: 12.4634, lon: 53.8238 },
    { id: 121, nameAr: 'المهرة (سقطرى)',nameEn: 'Al Mahrah',     lat: 16.5000, lon: 51.5000 },
  ];

  for (const state of states) {
    await prisma.location.upsert({
      where: { id: state.id },
      update: {},
      create: {
        id: state.id,
        nameAr: state.nameAr,
        nameEn: state.nameEn,
        level: LocationLevel.STATE,
        parentId: 1,
      },
    });
  }

  // ==========================================
  // المستوى الثالث: المديريات الرئيسية
  // مع إحداثيات مراكزها (للاستخدام كقيمة افتراضية في الهجرة)
  // ==========================================
  const districts = [
    // --- أمانة العاصمة (100) ---
    { id: 1001, nameAr: 'معين',        parentId: 100, lat: 15.3726, lon: 44.1745 },
    { id: 1002, nameAr: 'صنعاء القديمة', parentId: 100, lat: 15.3540, lon: 44.2070 },
    { id: 1003, nameAr: 'الثورة',      parentId: 100, lat: 15.3800, lon: 44.2050 },
    { id: 1004, nameAr: 'شعوب',        parentId: 100, lat: 15.3900, lon: 44.2200 },
    { id: 1005, nameAr: 'السبعين',     parentId: 100, lat: 15.3600, lon: 44.1900 },
    { id: 1006, nameAr: 'بني حشيش',   parentId: 100, lat: 15.4500, lon: 44.3500 },

    // --- محافظة عدن (102) ---
    { id: 1021, nameAr: 'كريتر',       parentId: 102, lat: 12.7714, lon: 44.9896 },
    { id: 1022, nameAr: 'المعلا',      parentId: 102, lat: 12.8000, lon: 45.0300 },
    { id: 1023, nameAr: 'خور مكسر',   parentId: 102, lat: 12.7867, lon: 45.0433 },
    { id: 1024, nameAr: 'الشيخ عثمان', parentId: 102, lat: 12.8560, lon: 45.0240 },
    { id: 1025, nameAr: 'دار سعد',    parentId: 102, lat: 12.9147, lon: 45.0264 },
    { id: 1026, nameAr: 'التواهي',     parentId: 102, lat: 12.7500, lon: 44.9800 },

    // --- محافظة تعز (103) ---
    { id: 1031, nameAr: 'مدينة تعز',  parentId: 103, lat: 13.5790, lon: 44.0210 },
    { id: 1032, nameAr: 'المظفر',     parentId: 103, lat: 13.5740, lon: 44.0180 },
    { id: 1033, nameAr: 'القاهرة',    parentId: 103, lat: 13.5800, lon: 44.0300 },
    { id: 1034, nameAr: 'صالة',       parentId: 103, lat: 13.5900, lon: 44.0400 },

    // --- محافظة الحديدة (104) ---
    { id: 1041, nameAr: 'مدينة الحديدة', parentId: 104, lat: 14.7978, lon: 42.9544 },
    { id: 1042, nameAr: 'الهالي',     parentId: 104, lat: 14.8200, lon: 42.9800 },
    { id: 1043, nameAr: 'الحيمة الخارجية', parentId: 104, lat: 14.9000, lon: 43.2000 },

    // --- محافظة إب (105) ---
    { id: 1051, nameAr: 'مدينة إب',   parentId: 105, lat: 13.9720, lon: 44.1818 },
    { id: 1052, nameAr: 'يريم',       parentId: 105, lat: 14.3000, lon: 44.3700 },
    { id: 1053, nameAr: 'جبل حبشي',  parentId: 105, lat: 13.9000, lon: 44.1000 },

    // --- محافظة مأرب (111) ---
    { id: 1111, nameAr: 'مأرب مدينة', parentId: 111, lat: 15.4692, lon: 45.3247 },
    { id: 1112, nameAr: 'مأرب',       parentId: 111, lat: 15.4500, lon: 45.3000 },

    // --- محافظة حضرموت (106) ---
    { id: 1061, nameAr: 'المكلا',     parentId: 106, lat: 14.5238, lon: 49.1268 },
    { id: 1062, nameAr: 'سيئون',      parentId: 106, lat: 15.9367, lon: 48.7878 },
    { id: 1063, nameAr: 'شبام',       parentId: 106, lat: 15.9264, lon: 48.6389 },
  ];

  for (const district of districts) {
    await prisma.location.upsert({
      where: { id: district.id },
      update: {},
      create: {
        id: district.id,
        nameAr: district.nameAr,
        level: LocationLevel.DISTRICT,
        parentId: district.parentId,
      },
    });
  }

  console.log('✅ تم استيراد شجرة المواقع بنجاح!');
  console.log(`   - 1 دولة`);
  console.log(`   - ${states.length} محافظة`);
  console.log(`   - ${districts.length} مديرية رئيسية`);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

---

## 2. خارطة الإحداثيات لمراكز المديريات (للهجرة)

هذه البيانات تُستخدم في سكربت الهجرة (`migrate.ts`) كقيمة افتراضية للمتبرعين الذين لا يملكون إحداثيات GPS:

```typescript
// يُضاف في migrate.ts
export const DISTRICT_CENTERS: Record<number, { lat: number; lon: number }> = {
  // أمانة العاصمة
  1001: { lat: 15.3726, lon: 44.1745 }, // معين
  1002: { lat: 15.3540, lon: 44.2070 }, // صنعاء القديمة
  1003: { lat: 15.3800, lon: 44.2050 }, // الثورة
  // عدن
  1021: { lat: 12.7714, lon: 44.9896 }, // كريتر
  1022: { lat: 12.8000, lon: 45.0300 }, // المعلا
  // تعز
  1031: { lat: 13.5790, lon: 44.0210 }, // مدينة تعز
  // الحديدة
  1041: { lat: 14.7978, lon: 42.9544 }, // مدينة الحديدة
  // إب
  1051: { lat: 13.9720, lon: 44.1818 }, // مدينة إب
  // مأرب
  1111: { lat: 15.4692, lon: 45.3247 }, // مأرب مدينة
  // حضرموت
  1061: { lat: 14.5238, lon: 49.1268 }, // المكلا
  1062: { lat: 15.9367, lon: 48.7878 }, // سيئون
};

// معرف احتياطي لأي موقع غير معروف
export const DEFAULT_LOCATION_ID = 100; // أمانة العاصمة كقيمة افتراضية
```

---

## 3. خارطة أسماء المحافظات (للهجرة — توحيد الأسماء)

تُستخدم في دالة `resolveLocation()` لمطابقة أسماء Firebase مع IDs الجديدة:

```typescript
export const STATE_NAME_MAP: Record<string, number> = {
  // أمانة العاصمة
  'أمانة العاصمة': 100, 'صنعاء': 101, "sana'a": 101, 'sanaa': 101,
  // عدن
  'عدن': 102, 'aden': 102,
  // تعز
  'تعز': 103, 'taiz': 103, "ta'izz": 103,
  // الحديدة
  'الحديدة': 104, 'hudaydah': 104, 'hodeidah': 104,
  // إب
  'إب': 105, 'ibb': 105,
  // حضرموت
  'حضرموت': 106, 'hadhramaut': 106, 'hadramout': 106,
  // ذمار
  'ذمار': 107, 'dhamar': 107,
  // حجة
  'حجة': 108, 'hajjah': 108,
  // البيضاء
  'البيضاء': 109, 'al bayda': 109,
  // الجوف
  'الجوف': 110, 'al jawf': 110,
  // مأرب
  'مأرب': 111, "ma'rib": 111, 'marib': 111,
  // لحج
  'لحج': 112, 'lahij': 112,
  // المهرة
  'المهرة': 113, 'al mahrah': 113,
  // شبوة
  'شبوة': 114, 'shabwah': 114,
  // أبين
  'أبين': 115, 'abyan': 115,
  // المحويت
  'المحويت': 116, 'al mahwit': 116,
  // عمران
  'عمران': 117, 'amran': 117,
  // ريمة
  'ريمة': 118, 'raymah': 118,
  // الضالع
  'الضالع': 119, 'ad dali': 119,
  // سقطرى
  'سقطرى': 120, 'socotra': 120,
};
```

---

> [!NOTE]
> **هذا Seed مبدئي** — يغطي المحافظات الـ22 والمديريات الرئيسية للمدن الكبرى. يمكن تحديثه لاحقاً بالمديريات الكاملة (حوالي 330 مديرية) عند الحاجة.
