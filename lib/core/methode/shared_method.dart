import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:location/location.dart' as loc;

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
    print("=================1==================");
    servicestatus = await location.serviceEnabled();
    print("-----------------------------");
    print(servicestatus);
    if (servicestatus) {
      print("=================2==================");
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print("=================3==================");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("=================4==================");
          if (kDebugMode) {
            print("=================5==================");
            print('Location permissions are denied');
          }
        } else if (permission == LocationPermission.deniedForever) {
          print("=================6==================");
          if (kDebugMode) {
            print("=================7==================");
            print("'Location permissions are permanently denied");
          }
        } else {
          print("=================8==================");
          haspermission = true;
        }
      } else {
        print("=================9==================");
        haspermission = true;
      }
      if (haspermission) {
        print("=================10==================");
        return await getLocation();
      }
    } else {
      if (!await location.serviceEnabled()) {
        await location.requestService();
        await checkGps();
        // print("111111111111111111111111111");

        // print(servicestatus);
      } else {}

      print("=================11==================");
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
    print("=================12==================");
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
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      print("=================13==================");
    });
    return done;
  }
}
