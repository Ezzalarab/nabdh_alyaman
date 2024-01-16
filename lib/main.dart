import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nabdh_alyaman/presentation/cubit/global_cubit/global_cubit.dart';

import 'di.dart' as di;
import 'presentation/cubit/maps_cubit/maps_cubit.dart';
import 'presentation/cubit/profile_cubit/profile_cubit.dart';
import 'presentation/cubit/search_cubit/search_cubit.dart';
import 'presentation/cubit/send_notfication/send_notfication_cubit.dart';
import 'presentation/cubit/signin_cubit/signin_cubit.dart';
import 'presentation/cubit/signup_cubit/signup_cubit.dart';
import 'presentation/pages/about_page.dart';
import 'presentation/pages/edit_main_center_data.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/introduction_page.dart';
import 'presentation/pages/profile_center.dart';
import 'presentation/pages/search_map_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/setting_page.dart';
import 'presentation/pages/sign_in_page.dart';
import 'presentation/pages/sign_up_page.dart';
import 'presentation/pages/sing_up_center_page.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/resources/theme_manager.dart';

String? version;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.initApp();
  await Hive.initFlutter();
  await Hive.openBox(dataBoxName);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (BuildContext context) => di.gi<GlobalCubit>()),
      BlocProvider(create: (BuildContext context) => di.gi<SignUpCubit>()),
      BlocProvider(create: (BuildContext context) => di.gi<SignInCubit>()),
      BlocProvider(create: (BuildContext context) => di.gi<SearchCubit>()),
      BlocProvider(create: (BuildContext context) => di.gi<ProfileCubit>()),
      BlocProvider(
          create: (BuildContext context) => di.gi<SendNotficationCubit>()),
      BlocProvider(create: (BuildContext context) => MapsCubit()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      locale: const Locale("ar", "AE"),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale("ar", "AE")],
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomePage.routeName: (context) => const HomePage(),
        SignUpPage.routeName: (context) => const SignUpPage(),
        SignInPage.routeName: (context) => const SignInPage(),
        SignUpCenter.routeName: (context) => const SignUpCenter(),
        SearchPage.routeName: (context) => const SearchPage(),
        SettingPage.routeName: (context) => const SettingPage(),
        SearchMapPage.routeName: (context) => const SearchMapPage(),
        IntroductionPage.routeName: (context) => const IntroductionPage(),
        ProfileCenterPage.routeName: (context) => const ProfileCenterPage(),
        EditMainCenterDataPage.routeName: (context) =>
            const EditMainCenterDataPage(),
        AboutPage.routeName: (context) => const AboutPage(),
      },
    );
  }
}
