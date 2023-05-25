import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/methode/shared_method.dart';
import 'di.dart' as di;
import 'domain/entities/donor.dart';
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
//---------------------
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'com.google.firebase.messaging.default_notification_channel_id',
    description: 'This channel is used for important notifications.',
    // title // description
    importance: Importance.high,
    playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
  await SharedMethod().getLocation();
  // position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high)
  //     .then((value) {
  //   print(position.latitude);
  //   print(position.longitude);
  //   Fluttertoast.showToast(msg: message.notification!.body.toString());
  //   return value;
  // });
  // Fluttertoast.showToast(msg: message.notification!.body.toString());
  RemoteNotification? notification = message.notification;
  // AndroidNotification? android = message.notification?.android;
  flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ));
}

late Position position;
//-------------------------------------.
const AndroidInitializationSettings _androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
// final DarwinInitializationSettings _darwinInitializationSettings =
//     const DarwinInitializationSettings();

void initialisendNotfications() async {
  InitializationSettings initializationSettings =
      InitializationSettings(android: _androidInitializationSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> backgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  // await SharedMethod().checkGps();
  Future.delayed(const Duration(seconds: 2)).then((value) {
    Fluttertoast.showToast(msg: message.notification!.body.toString());
  });
  await SharedMethod().checkGps();
  position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high)
      .then((value) {
    print(position.latitude);
    print(position.longitude);
    return value;
  });

  await FirebaseFirestore.instance
      .collection('donors')
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .update({
    DonorFields.lat: position.latitude.toString(),
    DonorFields.lon: position.longitude.toString()
  }).then((value) => print("location updated"));
}

// Future updateLocation(RemoteMessage msg) async {
//   print("==========onBackground==========");
//   Fluttertoast.showToast(msg: "update location\n${msg.notification!.body}");
//   await Firebase.initializeApp();
//   print("=========update====location=======\n${msg.notification!.body}");
//   await FirebaseFirestore.instance
//       .collection("donors")
//       .doc("H5PPBI8VBBNikBYvmifb")
//       .update({
//     "lan": 2.02121510,
//     "lon": 2.42144775,
//   }).then((value) {
//     print("==========Done==========");
//   });
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.initApp();
  await Hive.initFlutter();
  await Hive.openBox(dataBoxName);

  //-----------------------------------
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {});

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  initialisendNotfications();
  //-----------------------------------------------------

  // FirebaseMessaging.onBackgroundMessage(
  //     (message) => backgroundMessage(message));
  // FirebaseMessaging.onMessage.listen((event) {
  //   print("--------------------------------00");
  //   print(event.data);
  // });
  runApp(MultiBlocProvider(
    providers: [
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
  const MyApp({Key? key}) : super(key: key);

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
        EditMainCenterDataPage.routeName: (context) => EditMainCenterDataPage(),
        AboutPage.routeName: (context) => const AboutPage(),
      },
    );
  }
}
