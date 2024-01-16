// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../domain/entities/donor.dart';

class SharedMethod {
  bool hasCurrentLocation = false;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  var location = loc.Location();

  checkGps() async {
    servicestatus = await location.serviceEnabled();
    if (kDebugMode) {
      print(servicestatus);
    }
    if (servicestatus) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
        } else if (permission == LocationPermission.deniedForever) {
          if (kDebugMode) {
            print("'Location permissions are permanently denied");
          }
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
      if (haspermission) {
        return await getLocation();
      }
    } else {
      if (!await location.serviceEnabled()) {
        await location.requestService();
        await checkGps();

        // print(servicestatus);
      } else {}

      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }
    return false;
  }

  getLocation() async {
    bool done = false;
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (kDebugMode) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457
    }
    long = position.longitude.toString();
    lat = position.latitude.toString();

    done = true;

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (kDebugMode) {
        print(position.longitude);
        print(position.latitude); //Output: 29.6593457
      } //Output: 80.24599079

      long = position.longitude.toString();
      lat = position.latitude.toString();
    });
    if (kDebugMode) {
      print(positionStream);
    }
    return done;
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
      if (kDebugMode) {
        print(position.latitude);
        print(position.longitude);
      }
      return value;
    });

    await FirebaseFirestore.instance
        .collection('donors')
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .update({
      DonorFields.lat: position.latitude.toString(),
      DonorFields.lon: position.longitude.toString()
    }).then((value) {
      if (kDebugMode) {
        print("location updated");
      }
    });
  }

  // For main funtion:
  /*
  //-----------------------------------
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {});
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  initialisendNotfications();
  -----------------------------------------------------

  FirebaseMessaging.onBackgroundMessage(
      (message) => backgroundMessage(message));
  FirebaseMessaging.onMessage.listen((event) {
    print("--------------------------------00");
    print(event.data);
  });
  */

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'com.google.firebase.messaging.default_notification_channel_id',
//     description: 'This channel is used for important notifications.',
//     // title // description
//     importance: Importance.high,
//     playSound: true);
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up :  ${message.messageId}');
//   await SharedMethod().getLocation();
//   // position = await Geolocator.getCurrentPosition(
//   //         desiredAccuracy: LocationAccuracy.high)
//   //     .then((value) {
//   //   print(position.latitude);
//   //   print(position.longitude);
//   //   Fluttertoast.showToast(msg: message.notification!.body.toString());
//   //   return value;
//   // });
//   // Fluttertoast.showToast(msg: message.notification!.body.toString());
//   RemoteNotification? notification = message.notification;
//   // AndroidNotification? android = message.notification?.android;
//   flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification!.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           color: Colors.blue,
//           playSound: true,
//           icon: '@mipmap/ic_launcher',
//         ),
//       ));
// }

// late Position position;

// const AndroidInitializationSettings _androidInitializationSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
// final DarwinInitializationSettings _darwinInitializationSettings =
//     const DarwinInitializationSettings();

// void initialisendNotfications() async {
//   InitializationSettings initializationSettings =
//       const InitializationSettings(android: _androidInitializationSettings);
//   flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

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
}
