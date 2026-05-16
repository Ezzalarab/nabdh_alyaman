import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/center/center_bloc.dart';
import '../../../../core/urls.dart';
import '../../../../core/utils.dart';
import '../../../pages/about_page.dart';
import '../../../pages/center/center_donation_page.dart';
import '../../../pages/center/center_stock_history_page.dart';
import '../../../pages/edit_main_center_data.dart';
import '../../../pages/profile_center.dart';
import '../../../pages/sign_in_page.dart';
import '../../../resources/strings_manager.dart';
import 'home_drawer_menu_item.dart';

class HomeDrawerCenterBody extends StatelessWidget {
  const HomeDrawerCenterBody({super.key});

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
            onTap: () => _openWhenAuthed(
              context,
              () {
                context.read<CenterBloc>().add(CenterProfileLoadRequested());
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileCenterPage(),
                  ),
                );
              },
            ),
          ),
          HomeDrawerMenuItem(
            title: AppStrings.homeDrawerEditProfileCenter,
            icon: Icons.sync,
            onTap: () => _openWhenAuthed(
              context,
              () {
                context.read<CenterBloc>().add(CenterProfileLoadRequested());
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EditMainCenterDataPage(),
                  ),
                );
              },
            ),
          ),
          HomeDrawerMenuItem(
            title: 'تسجيل تبرع',
            icon: Icons.bloodtype_outlined,
            onTap: () => _openWhenAuthed(
              context,
              () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const CenterDonationPage(),
                  ),
                );
              },
            ),
          ),
          HomeDrawerMenuItem(
            title: 'سجل المخزون',
            icon: Icons.history,
            onTap: () => _openWhenAuthed(
              context,
              () {
                context
                    .read<CenterBloc>()
                    .add(CenterStockHistoryLoadRequested());
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const CenterStockHistoryPage(),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.black54),
          HomeDrawerMenuItem(
            title: 'مشاركة التطبيق',
            icon: Icons.share,
            onTap: () async {
              final appUrl = Urls.googleStoreAppLink;
              const messagePrefix =
                  'تطبيق (نبض اليمن) قد تكون سببًا في إنقاذ حياة';
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

  void _openWhenAuthed(BuildContext context, VoidCallback action) {
    final authed = context.read<AuthBloc>().state is AuthAuthenticated;
    if (authed) {
      Navigator.of(context).pop();
      action();
    } else {
      Utils.showSnackBar(
        context: context,
        msg: AppStrings.homeDrawerSignInFirstToast,
      );
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      );
    }
  }
}
