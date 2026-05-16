// ignore_for_file: public_member_api_docs, sort_constructors_first, depend_on_referenced_packages
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/blood_types.dart';
import '../../domain/entities/donor.dart';
import '../../domain/entities/donor_point.dart';
import '../blocs/blood_request/blood_request_bloc.dart';
import '../resources/color_manageer.dart';
import '../widgets/common/loading_widget.dart';
import 'blood_request/blood_request_detail_page.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({
    super.key,
    required this.stateDonors,
    required this.selectedBloodType,
    this.stateId,
  });

  final List<Donor> stateDonors;
  final String selectedBloodType;
  final int? stateId;

  static const String routeName = 'search_map';

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  final UrlLauncherPlatform _launcher = UrlLauncherPlatform.instance;
  Position? _position;
  List<DonorPoint> _nearbyDonors = [];
  List<BloodRequest> _nearbyRequests = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    final bloodRequestBloc = context.read<BloodRequestBloc>();
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
      final nearbyDonors =
          _filterDonorPoints(base: me, points: points, distanceKm: 20);

      List<BloodRequest> nearbyRequests = [];
      bloodRequestBloc.add(
        BloodRequestListLoadRequested(
          bloodType: widget.selectedBloodType,
          stateId: widget.stateId,
          limit: 50,
        ),
      );
      await bloodRequestBloc.stream.firstWhere(
        (s) => s is BloodRequestListLoaded || s is BloodRequestFailure,
      );
      final listState = bloodRequestBloc.state;
      if (listState is BloodRequestListLoaded) {
        nearbyRequests = listState.items
            .where((r) => r.isOpen && r.lat != 0 && r.lon != 0)
            .where((r) => _distanceKm(me.lat, me.lon, r.lat, r.lon) < 20)
            .toList(growable: false);
      }

      if (!mounted) return;
      setState(() {
        _position = position;
        _nearbyDonors = nearbyDonors;
        _nearbyRequests = nearbyRequests;
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

  List<DonorPoint> _filterDonorPoints({
    required DonorPoint base,
    required List<DonorPoint> points,
    required double distanceKm,
  }) {
    return points
        .where((p) => _distanceKm(base.lat, base.lon, p.lat, p.lon) < distanceKm)
        .toList(growable: false);
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    for (var i = 0; i < _nearbyDonors.length; i++) {
      final p = _nearbyDonors[i];
      markers.add(
        Marker(
          markerId: MarkerId('donor_$i'),
          position: LatLng(p.lat, p.lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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
        ),
      );
    }
    for (var i = 0; i < _nearbyRequests.length; i++) {
      final r = _nearbyRequests[i];
      markers.add(
        Marker(
          markerId: MarkerId('request_${r.id}'),
          position: LatLng(r.lat, r.lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'طلب استغاثة • ${r.bloodType}',
            snippet: r.hospitalName,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BloodRequestDetailPage(requestId: r.id),
                ),
              );
            },
          ),
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BloodRequestDetailPage(requestId: r.id),
              ),
            );
          },
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخريطة'),
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
                    : Stack(
                        children: [
                          GoogleMap(
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
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  '🔵 متبرعون (${_nearbyDonors.length})  •  🔴 طلبات استغاثة (${_nearbyRequests.length})',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
