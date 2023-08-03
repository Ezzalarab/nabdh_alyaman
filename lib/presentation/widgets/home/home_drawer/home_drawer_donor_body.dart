import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils.dart';
import '../../../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../../../presentation/pages/about_page.dart';
import '../../../../presentation/pages/home_page.dart';
import '../../../../presentation/pages/setting_page.dart';
import '../../../../presentation/pages/sign_in_page.dart';
import '../../../../presentation/resources/strings_manager.dart';
import 'home_drawer_menu_item.dart';

class HomeDrawerDonorBody extends StatelessWidget {
  const HomeDrawerDonorBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 10,
        children: [
          // HomeDrawerMenuItem(
          //   icon: Icons.settings_outlined,
          //   title: "إعدادات",
          //   onTap: () {
          //   },
          // ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerSettings,
            icon: Icons.settings_outlined,
            onTap: () {
              BlocProvider.of<ProfileCubit>(context).getDataToProfilePage();
              if (FirebaseAuth.instance.currentUser != null) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingPage(),
                  ),
                );
              } else {
                Utils.showSnackBar(
                  context: context,
                  msg: AppStrings.homeDrawerSignInFirstToast,
                );
                // divide.initSignIn();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignInPage(),
                  ),
                );
              }
            },
          ),
          const Divider(color: Colors.black54),
          HomeDrawerMenuItem(
            title: "مشاركة التطبيق",
            icon: Icons.share,
            onTap: () => Share.share(
                'https://play.google.com/store/apps/details?id=d.threedevils.devicey'),
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerAboutApp,
            icon: Icons.info_outline,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutPage()));
            },
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerLogOut,
            icon: Icons.logout_outlined,
            onTap: () async {
              Hive.box(dataBoxName).put('user', "0");
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
