import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/local_data.dart';
import '../cubit/global_cubit/global_cubit.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manageer.dart';
import '../resources/values_manager.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  static const String routeName = "about_page";

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String about = '''
  .هو تطبيق خدمي إنساني لتسهيل عملية الحصول على مصدر للدم بحيث يوفر قاعدة بيانات من المتبرعين والمراكز الطبية بحيث تكون عملية البحث سهلة وذو فائدة أكبر مع إمكانية إنشاء حساب للمتبرعين المتطوعين أصحاب النفوس الطيبة.\n\nتم تقديم هذا التطبيق كمشروع لنيل درجة البكلوريوس في قسم علوم الحاسوب وتقنية المعلومات في جامعة إب عام 2022.\n\nبنشر التطبيق يمكن أن تشارك في عملية الإنقاذ والدال على الخير كفاعله.\nللمساعدة أكثر يمكنك التواصل مع فريق التطوير لدعم نشر التطبيق بطرق الترويج الممول''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حول التطبيق"),
      ),
      backgroundColor: ColorManager.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppPadding.p30),
              child: Image.asset(
                ImageAssets.appLogo,
                fit: BoxFit.cover,
                cacheHeight: 100,
              ),
            ),
            const SizedBox(height: AppSize.s20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Align(
                alignment: Alignment.centerRight,
                child: BlocBuilder<GlobalCubit, GlobalState>(
                  builder: (context, state) {
                    String appName = LocalData.initialAppData.appName;
                    if (state is GlobalStateSuccess) {
                      appName = state.appData.appName;
                    }
                    String abouteHeader = "تطبيق $appName";
                    return Text(
                      abouteHeader,
                      style: Theme.of(context).textTheme.headlineLarge,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSize.s20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: BlocBuilder<GlobalCubit, GlobalState>(
                  builder: (context, state) {
                    if (state is GlobalStateSuccess) {
                      about = state.appData.aboutApp;
                      about = about.replaceAll("\\n", "\n");
                    }
                    return Text(
                      about,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(height: 1.5),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSize.s50),
          ],
        ),
      ),
    );
  }
}
