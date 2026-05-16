import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/notifications/fcm_service.dart';
import '../../core/notifications/notification_router.dart';
import '../../core/update.dart';
import '../../core/urls.dart';
import '../../di.dart' as di;
import '../blocs/app_config/app_config_bloc.dart';
import '../resources/color_manageer.dart';
import '../resources/values_manager.dart';
import '../widgets/home/events_cards.dart';
import '../widgets/home/home_carousel/home_carousel.dart';
import '../widgets/home/home_drawer/home_drawer.dart';
import '../widgets/home/home_info.dart';
import '../widgets/home/home_welcome.dart';
import 'introduction_page.dart';
import 'notfication_page.dart';
import 'search_page.dart';
import 'sign_in_page.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/notifications/notifications_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppUpdateDialog _updateDialog = AppUpdateDialog();

  final NotificationRouter _notificationRouter = NotificationRouter();

  @override
  void initState() {
    super.initState();
    context.read<AppConfigBloc>().add(AppVersionCheckRequested());
    _bindFcm();
  }

  void _bindFcm() {
    final fcm = di.gi<FcmService>();
    fcm.listenForeground((message) {
      if (!mounted) return;
      context.read<NotificationsBloc>().add(NotificationReceived(message));
      final data = message.data;
      if (data.isNotEmpty) {
        _notificationRouter.handleData(context, data);
      }
    });
    fcm.listenOpenedApp((message) {
      if (!mounted) return;
      final data = message.data;
      if (data.isNotEmpty) {
        _notificationRouter.handleData(context, data);
      }
    });
    fcm.initialMessage().then((message) {
      if (message == null || !mounted) return;
      _notificationRouter.handleData(context, message.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstTimeState = Hive.box(dataBoxName).get('introduction') ?? true;
    return BlocListener<AppConfigBloc, AppConfigState>(
      listener: (context, state) {
        if (state is AppUpdateRequired) {
          _updateDialog.showIfNeeded(context, state.policy);
        }
      },
      child: firstTimeState
          ? const IntroductionPage()
          : Scaffold(
              backgroundColor: ColorManager.primaryBg,
              appBar: AppBar(
                centerTitle: true,
                elevation: AppSize.s0,
                backgroundColor: ColorManager.primaryBg,
                surfaceTintColor: Colors.transparent,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: ColorManager.primaryBg,
                ),
                leadingWidth: 90,
                actions: [
                  IconButton(
                    onPressed: () {
                      final authed =
                          context.read<AuthBloc>().state is AuthAuthenticated;
                      if (!authed) {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const SignInPage(),
                          ),
                        );
                        return;
                      }
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      const appUrl = Urls.googleStoreAppLink;
                      const message =
                          'تطبيق (نبض اليمن) قد تكون سببًا في إنقاذ حياة\n\n$appUrl';
                      await Share.share(message);
                    },
                    icon: const Icon(Icons.share),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              body: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeWelcome(),
                    HomeCarousel(),
                    SizedBox(height: AppSize.s10),
                    HomeInfo(),
                    EventsCards(),
                    SizedBox(height: AppSize.s40),
                  ],
                ),
              ),
              drawer: const HomeDrower(),
              floatingActionButton: FloatingActionButton(
                backgroundColor: ColorManager.primary,
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SearchPage(),
                    ),
                  );
                },
                child: const Icon(Icons.search_rounded),
              ),
            ),
    );
  }
}
