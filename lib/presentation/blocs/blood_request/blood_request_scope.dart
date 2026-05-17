import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di.dart' as di;
import 'blood_request_bloc.dart';

/// Isolated [BloodRequestBloc] per screen — avoids shared state across map/create/detail.
class BloodRequestScope extends StatelessWidget {
  const BloodRequestScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.gi<BloodRequestBloc>(),
      child: child,
    );
  }
}

MaterialPageRoute<T> bloodRequestRoute<T extends Object?>(Widget page) {
  return MaterialPageRoute<T>(
    builder: (_) => BloodRequestScope(child: page),
  );
}
