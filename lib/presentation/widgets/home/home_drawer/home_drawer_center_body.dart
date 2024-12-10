import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/urls.dart';
import '../../../../core/utils.dart';
import '../../../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../../../presentation/pages/about_page.dart';
import '../../../../presentation/pages/edit_main_center_data.dart';
import '../../../../presentation/pages/home_page.dart';
import '../../../../presentation/pages/profile_center.dart';
import '../../../../presentation/pages/setting_page.dart';
import '../../../../presentation/pages/sign_in_page.dart';
import '../../../../presentation/resources/strings_manager.dart';
import 'home_drawer_menu_item.dart';

class HomeDrawerCenterBody extends StatelessWidget {
  const HomeDrawerCenterBody({
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
            title: AppStrings.homeDrawerUpdateBloodBank,
            icon: Icons.sync,
            onTap: () {
              if (FirebaseAuth.instance.currentUser != null) {
                // print("+0000");
                Navigator.of(context).pop();
                BlocProvider.of<ProfileCubit>(context).getProfileCenterData();
                // Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileCenterPage()));
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
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerEditProfileCenter,
            icon: Icons.sync,
            onTap: () {
              if (FirebaseAuth.instance.currentUser != null) {
                BlocProvider.of<ProfileCubit>(context).getProfileCenterData();
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditMainCenterDataPage()));
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
            onTap: () async {
              String appUrl = Urls.googleStoreAppLink;
              String message =
                  'تطبيق (نبض اليمن) قد تكون سببًا في إنقاذ حياة\n\n$appUrl';
              await Share.share(message);
            },
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
