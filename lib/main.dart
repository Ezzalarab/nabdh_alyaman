import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nabdh_alyaman/firebase_options.dart';

import 'core/constants/storage_keys.dart';
import 'core/notifications/fcm_service.dart';
import 'di.dart' as di;
import 'presentation/blocs/app_config/app_config_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/center/center_bloc.dart';
import 'presentation/blocs/blood_request/blood_request_bloc.dart';
import 'presentation/blocs/notifications/notifications_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/pages/center/center_donation_page.dart';
import 'presentation/pages/center/center_stock_history_page.dart';
import 'presentation/pages/about_page.dart';
import 'presentation/pages/edit_main_center_data.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/introduction_page.dart';
import 'presentation/pages/notfication_page.dart';
import 'presentation/pages/profile_center.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/setting_page.dart';
import 'presentation/pages/sign_in_page.dart';
import 'presentation/pages/sign_up_page.dart';
import 'presentation/pages/sing_up_center_page.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/resources/theme_manager.dart';

/// App bootstrap — FCM receipt only; REST session via [AuthBloc].
String? version;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.initApp();
  await Hive.initFlutter();
  await Hive.openBox(dataBoxName);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await di.gi<FcmService>().initialize();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.gi<AuthBloc>()),
        BlocProvider(create: (_) => di.gi<AppConfigBloc>()),
        BlocProvider(create: (_) => di.gi<SearchBloc>()),
        BlocProvider(create: (_) => di.gi<CenterBloc>()),
        BlocProvider(create: (_) => di.gi<ProfileBloc>()),
        BlocProvider(create: (_) => di.gi<NotificationsBloc>()),
        BlocProvider(create: (_) => di.gi<BloodRequestBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthUnauthenticated && previous is AuthAuthenticated,
      listener: (context, state) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignInPage()),
          (_) => false,
        );
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme(),
        locale: const Locale('ar', 'AE'),
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'AE')],
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          HomePage.routeName: (context) => const HomePage(),
          SignUpPage.routeName: (context) => const SignUpPage(),
          SignInPage.routeName: (context) => const SignInPage(),
          SignUpCenter.routeName: (context) => const SignUpCenter(),
          SearchPage.routeName: (context) => const SearchPage(),
          SettingPage.routeName: (context) => const SettingPage(),
          IntroductionPage.routeName: (context) => const IntroductionPage(),
          ProfileCenterPage.routeName: (context) => const ProfileCenterPage(),
          EditMainCenterDataPage.routeName: (context) =>
              const EditMainCenterDataPage(),
          CenterDonationPage.routeName: (context) => const CenterDonationPage(),
          CenterStockHistoryPage.routeName: (context) =>
              const CenterStockHistoryPage(),
          AboutPage.routeName: (context) => const AboutPage(),
          NotificationPage.routeName: (context) => const NotificationPage(),
        },
      ),
    );
  }
}
