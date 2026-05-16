// ignore_for_file: public_member_api_docs, sort_constructors_first, depend_on_referenced_packages
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../domain/entities/blood_types.dart';
import '../../domain/entities/donor.dart';
import '../../domain/entities/donor_point.dart';
import '../resources/color_manageer.dart';
import '../widgets/common/loading_widget.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({
    super.key,
    required this.stateDonors,
    required this.selectedBloodType,
  });

  final List<Donor> stateDonors;
  final String selectedBloodType;

  static const String routeName = 'search_map';

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  final UrlLauncherPlatform _launcher = UrlLauncherPlatform.instance;
  Position? _position;
  List<DonorPoint> _nearby = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final me = DonorPoint(
        lat: position.latitude,
        lon: position.longitude,
        name: 'أنا',
        bloodType: '',
        phone: '',
        token: '',
      );
      final compatible = BloodTypes.canReceiveFrom(
        bloodType: widget.selectedBloodType,
      );
      final points = <DonorPoint>[];
      for (final donor in widget.stateDonors) {
        if (!compatible.contains(donor.bloodType)) continue;
        final lat = double.tryParse(donor.lat);
        final lon = double.tryParse(donor.lon);
        if (lat == null || lon == null || lat == 0 || lon == 0) continue;
        points.add(
          DonorPoint(
            lat: lat,
            lon: lon,
            name: donor.name,
            phone: donor.phone,
            bloodType: donor.bloodType,
            token: donor.token,
          ),
        );
      }
      final nearby = _filterNearby(base: me, points: points, distanceKm: 20);
      if (!mounted) return;
      setState(() {
        _position = position;
        _nearby = nearby;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذّر تحديد الموقع';
        _loading = false;
      });
    }
  }

  List<DonorPoint> _filterNearby({
    required DonorPoint base,
    required List<DonorPoint> points,
    required double distanceKm,
  }) {
    return points
        .where((p) => _distanceKm(base, p) < distanceKm)
        .toList(growable: false);
  }

  double _distanceKm(DonorPoint a, DonorPoint b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.lat - a.lat);
    final dLon = _deg2rad(b.lon - a.lon);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(a.lat)) *
            math.cos(_deg2rad(b.lat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  Set<Marker> _buildMarkers() {
    return Set<Marker>.from(
      List<Marker>.generate(_nearby.length, (index) {
        final p = _nearby[index];
        return Marker(
          markerId: MarkerId('donor_$index'),
          position: LatLng(p.lat, p.lon),
          infoWindow: InfoWindow(
            title: p.bloodType,
            snippet: '${p.name} • 📞 ${p.phone}',
            onTap: () async {
              final uri = Uri(scheme: 'tel', path: p.phone);
              await _launcher.launch(
                uri.toString(),
                useSafariVC: false,
                useWebView: false,
                enableJavaScript: false,
                enableDomStorage: false,
                universalLinksOnly: true,
                headers: <String, String>{},
              );
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقع المتبرعين'),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: ColorManager.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: LoadingWidget())
            : _error != null
                ? Center(child: Text(_error!))
                : _position == null
                    ? const Center(child: Text('لا يوجد موقع'))
                    : GoogleMap(
                        markers: _buildMarkers(),
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _position!.latitude,
                            _position!.longitude,
                          ),
                          zoom: 12,
                        ),
                        myLocationEnabled: true,
                      ),
      ),
    );
  }
}
