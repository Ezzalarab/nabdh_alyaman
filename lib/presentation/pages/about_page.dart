import 'package:nabdh_alyaman/presentation/resources/assets_manager.dart';

import '../../presentation/resources/constatns.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const String routeName = "about_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نبض اليمن"),
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(50),
                child: Image.asset(
                  ImageAssets.appLogo,
                  fit: BoxFit.cover,
                  cacheHeight: 100,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "تطبيق نبض اليمن",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '''
  .هو تطبيق خدمي إنساني لتسهيل عملية الحصول على مصدر للدم بحيث يوفر قاعدة بيانات من المتبرعين والمراكز الطبية بحيث تكون عملية البحث سهلة وذو فائدة أكبر مع إمكانية إنشاء حساب للمتبرعين المتطوعين أصحاب النفوس الطيبة.\nتم تقديم هذا التطبيق كمشروع لنيل درجة البكلوريوس في قسم علوم الحاسوب وتقنية المعلومات في جامعة إب عام 2022.\n''',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
