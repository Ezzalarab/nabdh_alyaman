import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../domain/entities/blood_request.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/blood_request/blood_request_bloc.dart';
import '../../resources/color_manageer.dart';
import '../../widgets/blood_request/urgency_selector.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/my_button.dart';

class BloodRequestDetailPage extends StatefulWidget {
  const BloodRequestDetailPage({super.key, required this.requestId});

  final String requestId;

  static const String routeName = '/blood-request/detail';

  @override
  State<BloodRequestDetailPage> createState() => _BloodRequestDetailPageState();
}

class _BloodRequestDetailPageState extends State<BloodRequestDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BloodRequestBloc>().add(
          BloodRequestDetailLoadRequested(id: widget.requestId),
        );
  }

  Future<void> _confirmStatus(String status, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<BloodRequestBloc>().add(
          BloodRequestStatusUpdateSubmitted(
            id: widget.requestId,
            status: status,
          ),
        );
  }

  bool _isOwner(BloodRequest request, AuthState auth) {
    if (auth is! AuthAuthenticated) return false;
    final owner = request.requesterId;
    if (owner == null || owner.isEmpty) return false;
    return owner == auth.session.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryBg,
      appBar: AppBar(
        title: const Text('تفاصيل طلب الاستغاثة'),
        backgroundColor: ColorManager.primaryBg,
      ),
      body: BlocConsumer<BloodRequestBloc, BloodRequestState>(
        listener: (context, state) {
          if (state is BloodRequestFailure) {
            Fluttertoast.showToast(msg: state.message);
          }
        },
        builder: (context, state) {
          if (state is BloodRequestLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is BloodRequestFailure) {
            return Center(child: Text(state.message));
          }
          if (state is! BloodRequestDetailLoaded) {
            return const SizedBox.shrink();
          }
          final request = state.request;
          final auth = context.watch<AuthBloc>().state;
          final showActions = request.isOpen && _isOwner(request, auth);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DetailRow(label: 'الحالة', value: _statusLabel(request.status)),
                _DetailRow(label: 'فصيلة الدم', value: request.bloodType),
                _DetailRow(label: 'المستشفى', value: request.hospitalName),
                if (request.patientName != null && request.patientName!.isNotEmpty)
                  _DetailRow(label: 'المريض', value: request.patientName!),
                _DetailRow(
                  label: 'الوحدات',
                  value: request.unitsNeeded.toString(),
                ),
                _DetailRow(
                  label: 'الإلحاح',
                  value: urgencyLabel(request.urgency),
                ),
                _DetailRow(
                  label: 'الموقع',
                  value:
                      '${request.lat.toStringAsFixed(4)}, ${request.lon.toStringAsFixed(4)}',
                ),
                if (request.expiresAt != null && request.expiresAt!.isNotEmpty)
                  _DetailRow(label: 'ينتهي في', value: request.expiresAt!),
                if (request.createdAt != null && request.createdAt!.isNotEmpty)
                  _DetailRow(label: 'تاريخ الإنشاء', value: request.createdAt!),
                if (showActions) ...[
                  const SizedBox(height: 24),
                  MyButton(
                    title: 'تم تلبية الطلب',
                    color: Colors.green.shade700,
                    onPressed: () => _confirmStatus('FULFILLED', 'إتمام الطلب'),
                  ),
                  const SizedBox(height: 12),
                  MyButton(
                    title: 'إلغاء الطلب',
                    color: Colors.red.shade700,
                    onPressed: () => _confirmStatus('CANCELLED', 'إلغاء الطلب'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'FULFILLED':
        return 'مكتمل';
      case 'CANCELLED':
        return 'ملغى';
      case 'OPEN':
        return 'مفتوح';
      default:
        return status;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
