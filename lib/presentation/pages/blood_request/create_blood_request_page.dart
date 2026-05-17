import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/blood_request.dart';
import '../../../domain/entities/blood_types.dart';
import '../../blocs/blood_request/blood_request_bloc.dart';
import '../../blocs/blood_request/blood_request_scope.dart';
import '../../resources/color_manageer.dart';
import '../../widgets/blood_request/hospital_form.dart';
import '../../widgets/blood_request/urgency_selector.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/my_button.dart';
import '../../widgets/locations/state_district_picker.dart';
import 'blood_request_detail_page.dart';

class CreateBloodRequestPage extends StatelessWidget {
  const CreateBloodRequestPage({super.key});

  static const String routeName = '/blood-request/create';

  @override
  Widget build(BuildContext context) {
    return const BloodRequestScope(child: _CreateBloodRequestView());
  }
}

class _CreateBloodRequestView extends StatefulWidget {
  const _CreateBloodRequestView();

  @override
  State<_CreateBloodRequestView> createState() => _CreateBloodRequestViewState();
}

class _CreateBloodRequestViewState extends State<_CreateBloodRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _patientController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');

  String? _bloodType;
  String _urgency = 'NORMAL';
  int? _stateId;
  int? _districtId;
  double? _lat;
  double? _lon;
  bool _locating = false;

  @override
  void dispose() {
    _hospitalController.dispose();
    _patientController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: 'يُرجى السماح بالوصول إلى الموقع');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
      });
    } catch (_) {
      Fluttertoast.showToast(msg: 'تعذّر تحديد الموقع');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_bloodType == null) {
      Fluttertoast.showToast(msg: 'اختر فصيلة الدم');
      return;
    }
    if (_districtId == null) {
      Fluttertoast.showToast(msg: 'اختر المحافظة والمديرية');
      return;
    }
    if (_lat == null || _lon == null || _lat == 0 || _lon == 0) {
      Fluttertoast.showToast(msg: 'حدّد موقعك على الخريطة أولاً');
      return;
    }
    final units = int.parse(_unitsController.text.trim());
    context.read<BloodRequestBloc>().add(
          BloodRequestCreateSubmitted(
            BloodRequestCreateParams(
              bloodType: _bloodType!,
              locationId: _districtId!,
              hospitalName: _hospitalController.text.trim(),
              lat: _lat!,
              lon: _lon!,
              unitsNeeded: units,
              patientName: _patientController.text.trim().isEmpty
                  ? null
                  : _patientController.text.trim(),
              urgency: _urgency,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        title: const Text('طلب استغاثة'),
        backgroundColor: ColorManager.primaryBg,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.primaryBg,
        ),
      ),
      body: BlocConsumer<BloodRequestBloc, BloodRequestState>(
        listener: (context, state) {
          if (state is BloodRequestSuccess && state.createdId != null) {
            Navigator.pushReplacement<void, void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BloodRequestDetailPage(
                  requestId: state.createdId!,
                ),
              ),
            );
          }
          if (state is BloodRequestFailure) {
            Fluttertoast.showToast(msg: state.message);
          }
        },
        builder: (context, state) {
          final loading = state is BloodRequestLoading;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _bloodType,
                        decoration: const InputDecoration(
                          labelText: 'فصيلة الدم المطلوبة *',
                          border: OutlineInputBorder(),
                        ),
                        items: BloodTypes.bloodTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: loading ? null : (v) => setState(() => _bloodType = v),
                        validator: (v) => v == null ? 'اختر الفصيلة' : null,
                      ),
                      const SizedBox(height: 16),
                      StateDistrictPicker(
                        initialStateId: _stateId,
                        initialDistrictId: _districtId,
                        onStateChanged: (id) => setState(() => _stateId = id),
                        onDistrictChanged: (id) => setState(() => _districtId = id),
                      ),
                      const SizedBox(height: 16),
                      HospitalFormFields(
                        hospitalController: _hospitalController,
                        patientController: _patientController,
                        unitsController: _unitsController,
                      ),
                      const SizedBox(height: 16),
                      UrgencySelector(
                        value: _urgency,
                        onChanged: loading ? (_) {} : (v) => setState(() => _urgency = v),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: loading || _locating ? null : _captureLocation,
                        icon: _locating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _lat != null
                              ? 'الموقع: ${_lat!.toStringAsFixed(4)}, ${_lon!.toStringAsFixed(4)}'
                              : 'تحديد موقعي الحالي *',
                        ),
                      ),
                      const SizedBox(height: 24),
                      MyButton(
                        title: 'إرسال طلب الاستغاثة',
                        color: Theme.of(context).primaryColor,
                        onPressed: loading ? () {} : _submit,
                      ),
                    ],
                  ),
                ),
              ),
              if (loading)
                const ColoredBox(
                  color: Colors.black26,
                  child: Center(child: LoadingWidget()),
                ),
            ],
          );
        },
      ),
    );
  }
}
