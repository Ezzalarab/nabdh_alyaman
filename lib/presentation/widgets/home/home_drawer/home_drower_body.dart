import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/urls.dart';
import '../../../pages/about_page.dart';
import '../../../pages/sign_in_page.dart';
import '../../../pages/sign_up_page.dart';
import '../../../resources/strings_manager.dart';
import 'home_drawer_menu_item.dart';

class HomeDrawerBody extends StatelessWidget {
  const HomeDrawerBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 10,
        children: [
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerSignIn,
            icon: Icons.login_rounded,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SignInPage(),
                ),
              );
            },
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerSignUp,
            icon: Icons.person_add_outlined,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SignUpPage(),
                ),
              );
            },
          ),
          HomeDrawerMenuItem(
            title: 'مشاركة التطبيق',
            icon: Icons.share,
            onTap: () async {
              final url = Urls.googleStoreAppLink;
              await Share.share('تطبيق (نبض اليمن)\n$url');
            },
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerAboutApp,
            icon: Icons.info_outline,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
