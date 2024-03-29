import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../core/app_constants.dart';
import '../../core/update.dart';
import '../../core/urls.dart';
import '../../domain/entities/donor.dart';
import '../resources/color_manageer.dart';
import '../resources/values_manager.dart';
import '../widgets/home/events_cards.dart';
import '../widgets/home/home_carousel/home_carousel.dart';
import '../widgets/home/home_drawer/home_drawer.dart';
import '../widgets/home/home_info.dart';
import '../widgets/home/home_welcome.dart';
import 'introduction_page.dart';
import 'search_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String routeName = "/home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final db = FirebaseFirestore.instance;
  late Position position;

  @override
  void initState() {
    checkUpdate();
    super.initState();

    // initialMessageing();
    // pushnot();

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   await SharedMethod().checkGps();
    //   position = await Geolocator.getCurrentPosition(
    //       desiredAccuracy: LocationAccuracy.high);
    //   if (kDebugMode) {
    //     print(position.longitude); //Output: 80.24599079
    //     print(position.latitude); //Output: 29.6593457
    //   }
    //   print("1010101");
    //   if (_firebaseAuth.currentUser != null) {
    //     await FirebaseFirestore.instance
    //         .collection('donors')
    //         .doc(_firebaseAuth.currentUser!.uid)
    //         .update({
    //       DonorFields.lat: position.latitude.toString(),
    //       DonorFields.lon: position.longitude.toString()
    //     }).then((value) => print("okkokokok"));
    //   }

    //   RemoteNotification? notification = message.notification;
    //   flutterLocalNotificationsPlugin.show(
    //     notification.hashCode,
    //     notification!.title,
    //     notification.body,
    //     NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         channel.id,
    //         channel.name,
    //         color: const Color.fromARGB(255, 214, 139, 11),
    //         playSound: true,
    //         icon: '@mipmap/ic_launcher',
    //       ),
    //     ),
    //   );
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: ((context) => NotFicationPage(
    //             remoteMessage: message.notification!,
    //             dateTime: message.sentTime!,
    //           )),
    //     ),
    //   );
    // });
  }

  // initialMessageing() async {
  //   var message = await FirebaseMessaging.instance.getInitialMessage();
  //   if (message != null) {
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: ((context) => UpdateLocNotFicationPage(
  //             remoteMessage: message.notification!,
  //             dateTime: message.sentTime!)),
  //       ),
  //     );
  //   }
  // }

  //----------- updating ------- check version
  void checkUpdate() async {
    Updating updateChecker = Updating();
    await updateChecker.getVersion();
    await Future.delayed(const Duration(seconds: 6));
    if (updateChecker.flagUpdata) {
      await updateChecker.showAlertUpdating(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool firstTimeState = Hive.box(dataBoxName).get('introduction') ?? true;
    return firstTimeState
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
                Stack(
                  children: [
                    IconButton(
                      onPressed: () async {
                        String appUrl = Urls.googleStoreAppLink;
                        String message =
                            'تطبيق (نبض اليمن) قد تكون سببًا في إنقاذ حياة\n\n$appUrl';
                        await Share.share(message);

                        // if (_firebaseAuth.currentUser != null) {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: ((context) => NotFicationPage())));
                        // } else {
                        //   di.initSignIn();
                        //   // Navigator.pushNamed(context, SignInPage.routeName);
                        //   Utils.showSnackBar(
                        //     context: context,
                        //     msg: " يتطلب تسجيل الدخول اولا  ",
                        //   );
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: ((context) => const SignInPage())));
                        // }
                      },
                      icon: const Icon(
                        Icons.share,
                      ),
                    ),
                    // const Positioned(
                    //   // draw a red marble
                    //   top: 8.0,
                    //   right: 10.0,
                    //   child: Icon(Icons.brightness_1,
                    //       size: 8.0, color: Colors.redAccent),
                    // )
                  ],
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: const SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
              child: const Icon(Icons.search_rounded),
              onPressed: () async {
                // prepareIbbDonors();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchPage(),
                  ),
                );
              },
            ),
          );
  }

  void prepareIbbDonors() async {
    List<Map<String, dynamic>> ibbDonorsMap = [
      {
        "name": "أحمد المنتصر",
        "phone": "774330229",
        "blood_type": "A+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "عماد الرباعي",
        "phone": "771215817",
        "blood_type": "A+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "عمر عبده أمين",
        "phone": "777401559",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "طاهر الشراعي",
        "phone": "775769693",
        "blood_type": "A+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "عبدالحكيم مطيع الجهمي",
        "phone": "774086679",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "مطيع الجعفري",
        "phone": "775453460",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "اكمة عيسئ"
      },
      {
        "name": "وازع محمد الصلاحي",
        "phone": "774988489",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "شعب عماق دار الشرف"
      },
      {
        "name": "وهيب عبدة المرهبي",
        "phone": "777721289",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "محمد مطيع الجهمي",
        "phone": "711301185",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "مصطفي القيفي",
        "phone": "711861544",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "عبدالسلام علي النهمي",
        "phone": "770933315",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "موفق علايه",
        "phone": "777111227",
        "blood_type": "B+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "جلال عبدالله الحراني",
        "phone": "771977949",
        "blood_type": "O+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "عبدالله الظراب",
        "phone": "770253700",
        "blood_type": "A+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "محسن قايد أمين أبو راس",
        "phone": "700062244",
        "blood_type": "A+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "كمال محمد ناجي الفقيه",
        "phone": "712563675",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "اكمه عيسئ"
      },
      {
        "name": "أحمد عبدالله عبادي العجمي",
        "phone": "715366393",
        "blood_type": "A+",
        "district": "الظهار",
        "neighborhood": "المحافظه"
      },
      {
        "name": "غمدان النهمي",
        "phone": "777665027",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "مروان الحسام",
        "phone": "772100551",
        "blood_type": "A+",
        "district": "جبلة",
        "neighborhood": "مفرق جبله"
      },
      {
        "name": "محمد عبد الواحد الحميري",
        "phone": "711900079",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "أحمد الرخمي",
        "phone": "772930434",
        "blood_type": "A+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "هشام البدوي",
        "phone": "775077620",
        "blood_type": "A+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "عبد الحكيم جوبح",
        "phone": "771288549",
        "blood_type": "O+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "فارس السلمي",
        "phone": "771306377",
        "blood_type": "B+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "عدنان سعيد البدوي",
        "phone": "715672302",
        "blood_type": "AB+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "محمد علي حمادي",
        "phone": "771480737",
        "blood_type": "A+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "شايف الرباعي",
        "phone": "773021640",
        "blood_type": "A+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "محمد الجهيم",
        "phone": "713107613",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "عماد هادي عساكر",
        "phone": "775606377",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "زكريا صادق العمدة",
        "phone": "772878622",
        "blood_type": "B+",
        "district": "جبلة",
        "neighborhood": "مفرق جبلة"
      },
      {
        "name": "عبدالملك العمدة",
        "phone": "715729801",
        "blood_type": "O+",
        "district": "جبلة",
        "neighborhood": "مفرق جبلة"
      },
      {
        "name": "هيثم عبدالله الجهراني",
        "phone": "774949775",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "نادر امين الجهراني",
        "phone": "771372590",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "بهاء علي الحبيشي",
        "phone": "777247180",
        "blood_type": "O+",
        "district": "الشعر",
        "neighborhood": "جوار فندق تاج اب"
      },
      {
        "name": "حسام عبدالله الجهراني",
        "phone": "777110021",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "عماد الدين رشاد السعيدي",
        "phone": "771255923",
        "blood_type": "-O",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "هشام عبد السلام الجبري",
        "phone": "774404476",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "أكمة عيسئ"
      },
      {
        "name": "علي أحمد قاسم جوبح",
        "phone": "771296697",
        "blood_type": "A+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "علي عبدالكريم الرباعي",
        "phone": "770970315",
        "blood_type": "O+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "أيمن محمد عبد عوض الرباعي",
        "phone": "774126209",
        "blood_type": "-B",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "إبراهيم أمين قاسم أحمد الرباعي",
        "phone": "775025638",
        "blood_type": "--A",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "بلال عبد سعيد الرباعي",
        "phone": "770017186",
        "blood_type": "O+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "ياسر أمين قاسم أحمد الرباعي",
        "phone": "774050165",
        "blood_type": "O+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "محمد أحمد ظافر",
        "phone": "770651378",
        "blood_type": "O+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "عبد الواسع الرباعي",
        "phone": "773075193",
        "blood_type": "O+",
        "district": "المشنة",
        "neighborhood": "عياد"
      },
      {
        "name": "عبدالسلام امين احمد الاصبحي",
        "phone": "774389714",
        "blood_type": "_B",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "ايمن على قحطان",
        "phone": "715626695",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "علي عبود الجماعي",
        "phone": "777329500",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "محمد عبدالله القمراء",
        "phone": "771077310",
        "blood_type": "A+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      },
      {
        "name": "طارق احمدالشعري",
        "phone": "777993635",
        "blood_type": "O+",
        "district": "ريف إب",
        "neighborhood": "دار الشرف"
      }
    ];
    List<Donor> ibbDonors = [];
    for (Map<String, dynamic> ibbDonorMap in ibbDonorsMap) {
      ibbDonorMap['state'] = 'إب';
      ibbDonorMap['created_at'] = DateTime.now();
      Donor ibbDonor = Donor.fromMap(ibbDonorMap);
      ibbDonors.add(ibbDonor);
    }
    // print('ibbDonors.last.toMap()');
    // print(ibbDonors.last.toMap());
    // print('ibbDonors.first.toMap()');
    // print(ibbDonors.first.toMap());
    for (Donor ibbDonor in ibbDonors) {
      await FirebaseFirestore.instance
          .collection('donors')
          .add(ibbDonor.toMap());
      if (kDebugMode) {
        print('ibbDonor.name');
        print(ibbDonor.name);
      }
    }
  }

  Future<bool> pushNotificationsSpecificDevice({
    required String token,
    required String title,
    required String body,
  }) async {
    String dataNotifications = '{ "to" : "$token",'
        ' "notification" : {'
        ' "title":"$title",'
        '"body":"$body"'
        ' }'
        ' }';

    await http.post(
      Uri.parse(AppConstants.baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= ${AppConstants.serverKey}',
      },
      body: dataNotifications,
    );
    return true;
  }

  Future<String> token() async {
    return FirebaseMessaging.instance.getToken().toString();
  }

  Future<bool> pushNotificationsGroupDevice({
    required String title,
    required String body,
  }) async {
    String dataNotifications = '{'
        '"operation": "create",'
        '"notification_key_name": "appUser-testUser",'
        '"registration_ids":["cscSJymiS1m6mEtyK8140J:APA91bEVPefdZNqg5jkLdvpEBYiSKBDDfeOIsnQF-1luu9lEO6_QBOuUbrsOycP4jL3OLvNZdMkZbqELRiPf9XstNPDdrwRtWVLEG28xyDPWna7UDsn_G8rPvzymwmWIANJWky45rFWX"],'
        '"notification" : {'
        '"title":"$title",'
        '"body":"$body"'
        ' }'
        ' }';

    var response = await http.post(
      Uri.parse(AppConstants.baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= ${AppConstants.serverKey}',
        'project_id': AppConstants.senderId
      },
      body: dataNotifications,
    );
    if (kDebugMode) {
      print("+1");
      print(response.body.toString());
      print("+0");
    }

    return true;
  }

  Future<bool> pushNotificationsAllUsers({
    required String title,
    required String body,
  }) async {
    // FirebaseMessaging.instance.subscribeToTopic("myTopic1");

    String dataNotifications = '{ '
        ' "to" : "/topics/myTopic1" , '
        ' "notification" : {'
        ' "title":"$title" , '
        ' "body":"$body" '
        ' } '
        ' } ';

    var response = await http.post(
      Uri.parse(AppConstants.baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= ${AppConstants.serverKey}',
      },
      body: dataNotifications,
    );
    if (kDebugMode) {
      print('response.body');
      print(response.body);
    }
    return true;
  }

  // void showNotification() {
  //   setState(() {
  //     _counter++;
  //   });
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     "Testing $_counter",
  //     "How you doin ?",
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(channel.id,
  //           "com.google.firebase.messaging.default_notification_channel_id",
  //           channelDescription:
  //               'This channel is used for important notifications.',
  //           importance: Importance.max,
  //           color: Colors.blue,
  //           priority: Priority.high,
  //           playSound: true,
  //           icon: '@mipmap/ic_launcher'),
  //     ),
  //   );
  // }
}

// floatingActionButton: GestureDetector(
//   onTap: () {
//     //  ontap = true;
//     subtract();
//   },
//   onLongPress: () {
//     ontap = true;
//     subtract();
//   },
//   onLongPressEnd: (_) {
//     setState(() {
//       ontap = false;
//     });
//   },
//   child: Container(
//     width: 50,
//     height: 50,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: Colors.red,
//     ),
//     child: Icon(Icons.remove),
//   ),
// ),
//       // di.initApp();
//       await BlocProvider.of<SendNotficationCubit>(context)
//           .sendNotfication(
//               sendNotficationData: SendNotificationData(
//                   listToken: [],
//                   title: "حالة حرجة",
//                   body: "تعال ياحيوان"))
//           .then((value) {
//       });
//       // pushNotificationsGroupDevice(
//       //     title: "حالة حرجة", body: "تعال ياحيوان");
//     } catch (e) {
//       print(e);
//     }
//     // BlocProvider.of<ProfileCubit>(context).getProfileCenterData();
//     // Navigator.pushNamed(context, ProfileCenterPage.routeName);
//     // Get a new write batch
//     // final batch = db.batch();
//     // for (var donorJson in list) {
//     //   var docRef = db.collection("donors").doc();
//     //   batch.set(docRef, donorJson);
//     // }
//     // batch.commit().then((_) {
//     //   print("======commit=done======");
//     // });
//     // Navigator.of(context).pushNamed(SearchPage.routeName);
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute<void>(
//     //     builder: (BuildContext context) => const SearchMapPage(),
//     //   ),
//     // );
//     // Navigator.of(context).pushNamed(OnBoardingView.routeName);
//     // LocationPoint point1 = LocationPoint(
//     //       lat: 13.9585003,
//     //       lon: 44.1709884,
//     //     ),
//     //     point2 = LocationPoint(
//     //       lat: 13.9556071,
//     //       lon: 44.1708585,
//     //     );
//     // print(getNearbyPoints(
//     //   base: point1,
//     //   points: [point2],
//     //   distanceKm: 0.4,
//     // ).length); // 0.3220144142025769
//     // // get the current location
//     // await LocationManager().getCurrentLocation();
//     // // start listen to location updates
//     // StreamSubscription<LocationDto> locationSubscription =
//     //     LocationManager().locationStream.listen((LocationDto dto) {
//     //   print('======================');
//     //   print(dto.altitude);
//     //   print(dto.longitude);
//     // });
//     // // cancel listening and stop the location manager
//     // locationSubscription.cancel();
//     // LocationManager().stop();
//   },
//   heroTag: "search",
//   child: const Icon(Icons.search_rounded),
// ),
//   List list = jsonDecode('''[
//      {
//         "image": "",
//         "is_gps_on": "1",
//         "gender": "male",
//         "is_shown_phone": "1",
//         "brith_date": "",
//         "lon": "44.16640231857082",
//         "password": "123456",
//         "is_shown": "1",
//         "phone": "714296685",
//         "blood_type": "O-",
//         "district": "العدين",
//         "lat": "13.95925347982098",
//         "name": "Ezz",
//         "state": "إب",
//         "neighborhood": "Alsarrah",
//         "id": "WL5996o2WbQwld7YJol11znInkq1",
//         "email": "e@g.com"
//     },
//     {
//         "image": "",
//         "is_gps_on": "1",
//         "gender": "male",
//         "is_shown_phone": "1",
//         "brith_date": "",
//         "lon": "44.16278508375451",
//         "password": "123456",
//         "is_shown": "1",
//         "phone": "714296685",
//         "blood_type": "O-",
//         "district": "العدين",
//         "lat": "13.974279144008882",
//         "name": "Ezz",
//         "state": "إب",
//         "neighborhood": "Annah",
//         "id": "WL5996o2WbQwld7YJol11znInkq1",
//         "email": "e@g.com"
//     },
//      {
//         "image": "",
//         "is_gps_on": "1",
//         "gender": "male",
//         "is_shown_phone": "1",
//         "brith_date": "",
//         "lon": "44.157411483548415",
//         "password": "123456",
//         "is_shown": "1",
//         "phone": "714296685",
//         "blood_type": "A+",
//         "district": "الظهار",
//         "lat": "13.971609757586048",
//         "name": "Ezz",
//         "state": "إب",
//         "neighborhood": "Alsabal",
//         "id": "WL5996o2WbQwld7YJol11znInkq1",
//         "email": "e@g.com"
//     },
//    {
//         "image": "",
//         "is_gps_on": "1",
//         "gender": "male",
//         "is_shown_phone": "1",
//         "brith_date": "",
//         "lon": "44.1669924226502",
//         "password": "123456",
//         "is_shown": "1",
//         "phone": "714296685",
//         "blood_type": "O+",
//         "district": "الظهار",
//         "lat": "13.950156735486098",
//         "name": "Ezz",
//         "state": "إب",
//         "neighborhood": "Harathah",
//         "id": "WL5996o2WbQwld7YJol11znInkq1",
//         "email": "e@g.com"
//     },
//      {
//         "image": "",
//         "is_gps_on": "1",
//         "gender": "male",
//         "is_shown_phone": "1",
//         "brith_date": "",
//         "lon": "44.18167133616689",
//         "password": "123456",
//         "is_shown": "1",
//         "phone": "714296685",
//         "blood_type": "O+",
//         "district": "الظهار",
//         "lat": "13.959390106818676",
//         "name": "Ezz",
//         "state": "إب",
//         "neighborhood": "Qihzah",
//         "id": "WL5996o2WbQwld7YJol11znInkq1",
//         "email": "e@g.com"
//     },
//  {
//         "image": "",
//         "is_gps_on": "1",
//         "gender": "male",
//         "is_shown_phone": "1",
//         "brith_date": "",
//         "lon": "44.193828479571074",
//         "password": "123456",
//         "is_shown": "1",
//         "phone": "714296685",
//         "blood_type": "A+",
//         "district": "شرعب السلام",
//         "lat": "13.964835321745667",
//         "name": "Ezz",
//         "state": "تعز",
//         "neighborhood": "Altibha",
//         "id": "WL5996o2WbQwld7YJol11znInkq1",
//         "email": "e@g.com"
//     }
// ]
// ''');
// const data = [
//   {
//     coords: {
//       lat: 13.974279144008882,
//       lng: 44.16278508375451,
//     },
//     name: "محمد",
//     bloodType: "O+",
//     phoneNumber: "771511569",
//   },
//   {
//     coords: {
//       lat: 13.95925347982098,
//       lng: 44.16640231857082,
//     },
//     name: "سامي",
//     bloodType: "O+",
//     phoneNumber: "771511542",
//   },
//   {
//     coords: {
//       lat: 13.971609757586048,
//       lng: 44.157411483548415,
//     },
//     name: "خالد",
//     bloodType: "O-",
//     phoneNumber: "715015696",
//   },
//   {
//     coords: {
//       lat: 13.950156735486098,
//       lng: 44.1669924226502,
//     },
//     name: "علي",
//     bloodType: "A+",
//     phoneNumber: "717015690",
//   },
//   {
//     coords: {
//       lat: 13.959390106818676,
//       lng: 44.18167133616689,
//     },
//     name: "سامي",
//     bloodType: "B+",
//     phoneNumber: "71501569",
//   },
//   {
//     coords: {
//       lat: 13.964835321745667,
//       lng: 44.193828479571074,
//     },
//     name: "راشد",
//     bloodType: "O+",
//     phoneNumber: "715017569",
//   },
//   {
//     coords: {
//       lat: 13.98106343411635,
//       lng: 44.18574205386784,
//     },
//     name: "سعيد",
//     bloodType: "O-",
//     phoneNumber: "715017569",
//   },
//   {
//     coords: {
//       lat: 13.974390828998246,
//       lng: 44.17589531780745,
//     },
//     name: "سالم",
//     bloodType: "AB-",
//     phoneNumber: "715017569",
//   },
//   {
//     coords: {
//       lat: 13.953817127862079,
//       lng: 44.172464266417265,
//     },
//     name: "خليل",
//     bloodType: "A+",
//     phoneNumber: "715017569",
//   },
//   {
//     coords: {
//       lat: 13.920863446490008,
//       lng: 44.173475415106225,
//     },
//     name: "أشرف",
//     bloodType: "O+",
//     phoneNumber: "715017569",
//   },
// ];
//   function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
// }
// function deg2rad(deg) {
//   return deg * (Math.PI/180)
// }
  // List<LocationPoint> getNearbyPoints({
  //   required LocationPoint base,
  //   required List<LocationPoint> points,
  //   required double distanceKm,
  // }) {
  //   List<LocationPoint> nearPoints = [];
  //   for (var point in points) {
  //     double far = getDistanceFromLatLonInKM(point1: base, point2: point);
  //     print(far);
  //     print(distanceKm);
  //     if (far < distanceKm) {
  //       nearPoints.add(point);
  //     }
  //   }
  //   return nearPoints;
  // }
  // getDistanceFromLatLonInKM({
  //   required LocationPoint point1,
  //   required LocationPoint point2,
  // }) {
  //   var R = 6371; // Radius of the earth in km
  //   var dLat = deg2rad(point2.lat - point1.lat); // deg2rad below
  //   var dLon = deg2rad(point2.lon - point1.lon);
  //   var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
  //       math.cos(deg2rad(point1.lat)) *
  //           math.cos(deg2rad(point2.lat)) *
  //           math.sin(dLon / 2) *
  //           math.sin(dLon / 2);
  //   var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  //   var d = R * c; // Distance in km
  //   return d;
  // }
  // deg2rad(deg) {
  //   return deg * (math.pi / 180);
  // }
//-----------------------------------------

    //---------------initState--------------------
    // initMessaging();
    // FirebaseMessaging.onMessage.listen((event) {
    //   print("on backgrounnd");
    //   print(event.data);
    //   Fluttertoast.showToast(msg: event.data.values.first);
    // });
    // pushFCMtoken();
    // LocationManager().interval = 1;
    // LocationManager().distanceFilter = 0;
    // LocationManager().notificationTitle = 'CARP Location Example';
    // LocationManager().notificationMsg = 'CARP is tracking your location';
    // _requestPermission();
    // location.changeSettings(
    //     interval: 1000, accuracy: loc.LocationAccuracy.high);
    // location.enableBackgroundMode(enable: true);

  // From Meduim "Push Notification In Flutter in Background"
  // void pushFCMtoken() async {
  //   String? token = await messaging.getToken();
  //   print("======token=======");
  //   print(token);
  // }
  // void initMessaging() {
  //   var androiInit = const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var initSetting = InitializationSettings(android: androiInit);
  //   fltNotification = FlutterLocalNotificationsPlugin();
  //   fltNotification.initialize(initSetting);
  //   var androidDetails =
  //       const AndroidNotificationDetails('1', 'notification_channel_id');
  //   var generalNotificationDetails =
  //       NotificationDetails(android: androidDetails);
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //     if (android != null) {
  //       fltNotification.show(notification.hashCode, notification?.title,
  //           notification?.body, generalNotificationDetails);
  //       print('notification initialized');
  //     }
  //   });
  // }
  // final List<String> tokens = [
  //   'fJTVExhUSKe581773y-BSD:APA91bGW8hwjQ2SIaNrGDZS4mICEBD3S1Vg2mNU6vunhQWQZDLThOGQv3FQ5jCYqoxravvX4XDs4WEYACgnKecqe0xVNwdXsx5AIejcsvr9kaaTq-vtreoBaw7Wgnr5aGOL1zy4FN8b3',
  //   'e_036JIcR7ei2e7SVOBYbl:APA91bFK_Ije-b8MiFRxKFN1yiwEwE9kvf2RFICGDeOjBm85NUMZ0UVt9yGmsmyjR313xPPoadPww0-AyNHzWJ0LwfEpM6dTZfTrlpQGGLpP16y0pYAJ77Y4sHWHeyLG9Wussp2B9v5d',
  // ];
  // Future<void> sendPushMessage() async {
  //   if (tokens.isEmpty) {
  //     print('Unable to send FCM message, no token exists.');
  //     return;
  //   }
  //   try {
  //     await http.post(
  //       Uri.parse('https://api.rnfirebase.io/messaging/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: constructFCMPayload(tokens[1]),
  //     );
  //     print('FCM request for device sent!');
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  // String constructFCMPayload(String? token) {
  //   return jsonEncode({
  //     'token': token,
  //     'data': {
  //       'via': 'FlutterFire Cloud Messaging!!!',
  //       'count': '_messageCount.toString()',
  //     },
  //     'notification': {
  //       'title': 'Hello FlutterFire!',
  //       'body': 'This notification (#_messageCount) was created via FCM!',
  //     },
  //   });
  // }
  // _requestPermission() async {
  //   var status = await Permission.location.request();
  //   if (status.isGranted) {
  //     print('done');
  //   } else if (status.isDenied) {
  //     _requestPermission();
  //   } else if (status.isPermanentlyDenied) {
  //     openAppSettings();
  //   }
  // }
  // Future<Position> getLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error('Please Turn on Location permissions manually');
  //   }
  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }
  // final loc.Location location = loc.Location();
  // StreamSubscription<loc.LocationData>? _locationSubscription;
  // Future<void> _listenLocation() async {
  //   try {
  //     _locationSubscription = location.onLocationChanged.handleError((onError) {
  //       print(onError);
  //       _locationSubscription?.cancel();
  //       setState(() {
  //         _locationSubscription = null;
  //       });
  //     }).listen((loc.LocationData currentlocation) async {
  //       print('=========================');
  //       print(currentlocation.altitude);
  //       print(currentlocation.longitude);
  //     });
  //   } catch (e) {
  //     print('Error: -----');
  //     print(e);
  //   }
  // }
  // int counter = 0;
  // bool ontap = false;
  // subtract() async {
  //   await Future.delayed(Duration(milliseconds: 100));
  //   setState(() {
  //     counter--;
  //     print(counter);
  //   });
  //   if (ontap) {
  //     subtract();
  //   }
  // }
  // addcounter() async {
  //   await Future.delayed(Duration(milliseconds: 100));
  //   setState(() {
  //     counter++;
  //     print(counter);
  //   });
  //   if (ontap) {
  //     addcounter();
  //   }
  // }
