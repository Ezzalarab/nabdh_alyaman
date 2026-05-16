import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../../core/urls.dart';
import '../../../../core/utils.dart';
import '../../../blocs/profile/profile_bloc.dart';
import '../../../pages/about_page.dart';
import '../../../pages/setting_page.dart';
import '../../../pages/sign_in_page.dart';
import '../../../resources/strings_manager.dart';
import 'home_drawer_menu_item.dart';

class HomeDrawerDonorBody extends StatelessWidget {
  const HomeDrawerDonorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 10,
        children: [
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerSettings,
            icon: Icons.settings_outlined,
            onTap: () {
              final authed =
                  context.read<AuthBloc>().state is AuthAuthenticated;
              context.read<ProfileBloc>().add(ProfileLoadRequested());
              if (authed) {
                Navigator.of(context).pop();
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingPage(),
                  ),
                );
              } else {
                Utils.showSnackBar(
                  context: context,
                  msg: AppStrings.homeDrawerSignInFirstToast,
                );
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SignInPage(),
                  ),
                );
              }
            },
          ),
          const Divider(color: Colors.black54),
          HomeDrawerMenuItem(
            title: 'مشاركة التطبيق',
            icon: Icons.share,
            onTap: () async {
              final appUrl = Urls.googleStoreAppLink;
              const messagePrefix = 'تطبيق (نبض اليمن) قد تكون سببًا في إنقاذ حياة';
              await Share.share('$messagePrefix\n\n$appUrl');
            },
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerAboutApp,
            icon: Icons.info_outline,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (_) => const AboutPage()),
              );
            },
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerLogOut,
            icon: Icons.logout_outlined,
            onTap: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const SignInPage()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
