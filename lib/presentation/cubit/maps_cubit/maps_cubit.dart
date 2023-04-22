import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'dart:math' as math;

import '../../../domain/entities/blood_types.dart';
import '../../../domain/entities/donor.dart';
import '../../../domain/entities/donor_point.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  MapsCubit() : super(MapsInitial());

  var location = loc.Location();
  final Completer<GoogleMapController> _mapcontroller = Completer();
  bool servicestatus = false;
  bool haspermission = false;
  bool hasCurrentLocation = false;
  String long = "", lat = "";
  late DonorPoint myPoint;
  late LocationPermission permission;
  late Position currentPosition;

  Future<void> showMaps({
    required List<Donor> stateDonors,
    required String selectedBloodType,
  }) async {
    emit(MapsLoading());
    await checkGps();
    // await refreshDeviceLocation();
    myPoint = DonorPoint(
      lat: currentPosition.latitude,
      lon: currentPosition.longitude,
      name: "أنا",
      bloodType: "",
      phone: "",
      token: "",
    );
    List<DonorPoint> listPoints = getDonorPoints(
      stateDonors: stateDonors,
      selectedBloodType: selectedBloodType,
    );
    listPoints = getNearbyPoints(
      base: myPoint,
      points: listPoints,
      distanceKm: 5.0,
    );
    emit(MapsSuccess(
      nearbyDonors: listPoints,
      position: currentPosition,
    ));
  }

  checkGps() async {
    servicestatus = await location.serviceEnabled();
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
        await getLocation();
      }
    } else {
      if (!await location.serviceEnabled()) {
        await location.requestService();
      }
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }
  }

  getLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (kDebugMode) {
      print(currentPosition.longitude);
      print(currentPosition.latitude);
    }
    long = currentPosition.longitude.toString();
    lat = currentPosition.latitude.toString();
    hasCurrentLocation = true;
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      long = position.longitude.toString();
      lat = position.latitude.toString();
    });
  }

  List<DonorPoint> getDonorPoints({
    required List<Donor> stateDonors,
    required String selectedBloodType,
  }) {
    List<DonorPoint> points = [];
    List<Donor> suitableDonors = stateDonors
        .where((donor) =>
            BloodTypes.canReceiveFrom(bloodType: selectedBloodType)
                .contains(donor.bloodType))
        .toList();
    for (var donor in suitableDonors) {
      points.add(DonorPoint(
        lat: double.tryParse(donor.lat) ?? 0.0,
        lon: double.tryParse(donor.lon) ?? 0.0,
        name: donor.name,
        phone: donor.phone,
        bloodType: donor.bloodType,
        token: donor.token,
      ));
    }
    return points;
  }

  // Filtering Points
  List<DonorPoint> getNearbyPoints({
    required DonorPoint base,
    required List<DonorPoint> points,
    required double distanceKm,
  }) {
    List<DonorPoint> nearPoints = [];
    print(distanceKm);
    for (var point in points) {
      double far = getDistanceFromLatLonInKM(point1: base, point2: point);
      print("========far====distanceKm=====");
      print(far);
      if (far < distanceKm) {
        nearPoints.add(point);
      }
    }
    return nearPoints;
  }

  getDistanceFromLatLonInKM({
    required DonorPoint point1,
    required DonorPoint point2,
  }) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(point2.lat - point1.lat); // deg2rad below
    var dLon = deg2rad(point2.lon - point1.lon);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(point1.lat)) *
            math.cos(deg2rad(point2.lat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  deg2rad(deg) {
    return deg * (math.pi / 180);
  }

  refreshDeviceLocation() async {
    location.getLocation().then(
      (location) {
        location = location;
      },
    );
    GoogleMapController googleMapController = await _mapcontroller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        final currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
      },
    );
  }
}
