import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/datasources/local/locations_local_datasource.dart';
import '../../../data/datasources/remote/locations_remote_datasource.dart';
import '../../../data/models/cached_location_row.dart';
import '../../../di.dart' as di;
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';

/// Governorate + district dropdowns backed by `/locations` API (and local cache).
class StateDistrictPicker extends StatefulWidget {
  const StateDistrictPicker({
    super.key,
    this.initialStateId,
    this.initialDistrictId,
    required this.onStateChanged,
    required this.onDistrictChanged,
  });

  final int? initialStateId;
  final int? initialDistrictId;
  final ValueChanged<int?> onStateChanged;
  final ValueChanged<int?> onDistrictChanged;

  @override
  State<StateDistrictPicker> createState() => _StateDistrictPickerState();
}

class _StateDistrictPickerState extends State<StateDistrictPicker> {
  List<CachedLocationState> _states = [];
  List<CachedLocationDistrict> _districts = [];
  int? _stateId;
  int? _districtId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _stateId = widget.initialStateId;
    _districtId = widget.initialDistrictId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _loadStates();
    if (_stateId != null) {
      await _loadDistricts(_stateId!, notify: false);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadStates() async {
    final local = di.gi<LocationsLocalDataSource>();
    var rows = await local.getStates();
    if (rows.isEmpty) {
      try {
        final remote = di.gi<LocationsRemoteDataSource>();
        rows = await remote.fetchStates();
        await local.replaceStates(rows);
      } catch (_) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'تعذّر تحميل المحافظات');
        }
        return;
      }
    }
    if (mounted) setState(() => _states = rows);
  }

  Future<void> _loadDistricts(int stateId, {bool notify = true}) async {
    final local = di.gi<LocationsLocalDataSource>();
    var list = await local.getDistrictsForState(stateId);
    if (list.isEmpty) {
      try {
        final remote = di.gi<LocationsRemoteDataSource>();
        list = await remote.fetchDistricts(stateId);
        await local.replaceDistricts(list);
      } catch (_) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'تعذّر تحميل المديريات');
        }
        return;
      }
    }
    if (!mounted) return;
    setState(() => _districts = list);
    if (notify) {
      widget.onStateChanged(_stateId);
      widget.onDistrictChanged(_districtId);
    }
  }

  Future<void> _onState(int? id) async {
    setState(() {
      _stateId = id;
      _districtId = null;
      _districts = [];
    });
    widget.onStateChanged(id);
    widget.onDistrictChanged(null);
    if (id == null) return;
    await _loadDistricts(id);
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: ColorManager.white,
        contentPadding: const EdgeInsets.all(AppPadding.p12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColorManager.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColorManager.lightGrey),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppPadding.p12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _states.any((s) => s.stateId == _stateId) ? _stateId : null,
          decoration: _decoration('المحافظة'),
          items: _states
              .map(
                (s) => DropdownMenuItem(
                  value: s.stateId,
                  child: Text(s.nameAr, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _onState,
          validator: (v) => v == null ? 'يرجى اختيار المحافظة' : null,
        ),
        const SizedBox(height: AppSize.s14),
        DropdownButtonFormField<int>(
          value: _districts.any((d) => d.districtId == _districtId)
              ? _districtId
              : null,
          decoration: _decoration('المديرية'),
          items: _districts
              .map(
                (d) => DropdownMenuItem(
                  value: d.districtId,
                  child: Text(d.nameAr, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() => _districtId = v);
            widget.onDistrictChanged(v);
          },
          validator: (v) => v == null ? 'يرجى اختيار المديرية' : null,
        ),
      ],
    );
  }
}
