import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/data_sources/local_data.dart';
import '../../../blocs/app_config/app_config_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../../presentation/widgets/home/home_drawer/home_drawer_center_body.dart';
import '../../../../presentation/widgets/home/home_drawer/home_drawer_donor_body.dart';
import 'home_drawer_header.dart';
import 'home_drawer_menu_item.dart';
import 'home_drower_body.dart';

class HomeDrower extends StatelessWidget {
  const HomeDrower({super.key});

  @override
  Widget build(BuildContext context) {
    var reportProblemLink = LocalData.initialAppData.reportLink;

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const HomeDrawerHeader(),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  if (authState.session.role == 'CENTER') {
                    return const HomeDrawerCenterBody();
                  }
                  return const HomeDrawerDonorBody();
                }
                return const HomeDrawerBody();
              },
            ),
            BlocBuilder<AppConfigBloc, AppConfigState>(
              builder: (context, state) {
                final link = switch (state) {
                  AppConfigLoaded(:final data) => data.reportLink,
                  AppUpdateRequired(:final data) => data.reportLink,
                  AppConfigFailure(:final data) => data.reportLink,
                  _ => context.read<AppConfigBloc>().data.reportLink,
                };
                if (link.isNotEmpty) {
                  reportProblemLink = link.replaceAll('\\n', '\n');
                }
                return HomeDrawerMenuItem(
                  title: 'الإبلاغ عن مشكلة في التطبيق',
                  icon: Icons.warning_amber_rounded,
                  onTap: () {
                    final url = Uri.parse(reportProblemLink);
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
