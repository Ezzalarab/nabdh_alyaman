import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

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
    print(servicestatus);
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
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();
    });
    return done;
  }
}
