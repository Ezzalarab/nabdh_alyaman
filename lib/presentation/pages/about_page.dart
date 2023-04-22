import '../../presentation/resources/constatns.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const String routeName = "about_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("عن التطبيق"),
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Image.asset(
                  "assets/images/boy.png",
                  fit: BoxFit.cover,
                  cacheHeight: 200,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "بنك الدم اليمني",
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
      التبرع بالدم هو إجراء طبي يتم فيه نقل الدم من شخص سليم معافى طوعاً إلى شخص مريض محتاج للدم. يستخدم ذلك الدم في عمليات نقل الدم كاملا أو بأحد مكوناته فقط بعد ...''',
                    style: Theme.of(context).textTheme.bodyLarge,
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
