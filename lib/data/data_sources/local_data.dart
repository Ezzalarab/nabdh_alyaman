import '../../domain/entities/global_app_data.dart';

class LocalData {
  static GlobalAppData initialAppData = GlobalAppData(
    appName: "نبض اليمن",
    aboutApp:
        ".هو تطبيق خدمي إنساني لتسهيل عملية الحصول على مصدر للدم بحيث يوفر قاعدة بيانات من المتبرعين والمراكز الطبية بحيث تكون عملية البحث سهلة وذو فائدة أكبر مع إمكانية إنشاء حساب للمتبرعين المتطوعين أصحاب النفوس الطيبة.\nتم تقديم هذا التطبيق كمشروع لنيل درجة البكلوريوس في قسم علوم الحاسوب وتقنية المعلومات في جامعة إب عام 2022.\n",
    homeHeader: "ومن أحياها\n فكأنما أحيا الناس جميعاً",
    infoTitle: "فوائد التبرع بالدم",
    reportLink:
        "whatsapp://send?phone=+967714296685&text=إبلاغ عن مشكلة في تطبيق نبض اليمن:\n_____________\n",
    infoList: [
      "تقليل احتمالية حدوث جلطات القلب.",
      "زيادة نشاط نخاع العظم لإنتاج خلايا دم جديدة (كريات حمراء وكريات بيضاء وصفائح دموية).",
      "زيادة نشاط الدورة الدموية.",
      "التبرع بالدم يساعد على تقليل نسبة الحديد في الدم لأنه يعتبر أحد أسباب الإصابة بأمراض القلب وانسداد الشرايين.",
      "الحفاظ على سلامة الكبد.",
      "الفائدة الأكبر والأهم إنقاذ حياة إنسان",
    ],
    homeSlides: [
      "blood_heart.png",
      "blood-donation-bag-heart.png",
      "hands-donate.jpg",
    ],
    eventsTitle: "مستجدات",
    eventsCardsData: [
      // EventCardData(
      //   id: "id",
      //   title: "title",
      //   desc: "desc",
      //   image:
      //       'https://cdn.sanity.io/images/0b678gck/buoy-public-site/a9d381334b41fbe7c3feb3d2e6096a5f52d2b8ae-2000x1400.png',
      //   date: "date",
      //   place: "place",
      //   link: 'link',
      // ),
    ],
  );

  static List<Map<String, dynamic>> firebaseData = [
    {
      "id": "1",
      "title": "مخيم مكافحة العمى",
      "desc":
          "عدد الحالات الممولة للعمليات الجراحية بتقنية الفاكو 145 حالة\n.التسجيل بأسبقية الحضور",
      "image": "tanzifco.png",
      "date":
          "تبدأ المعاينات ايام السبت والاحد 5-6 اغسطس 2023م من الساعه : 01:00 ظهرا",
      "place":
          "موقع المخيم مستشفى رؤيه لطب وجراحة العيون والشبكية -  سيئون - حضرموت",
      "link":
          "https://www.facebook.com/100057367784745/posts/773062291282690/?mibextid=xM1NMCEE8qaB7NWz"
    }
  ];
}
