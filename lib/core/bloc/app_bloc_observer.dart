import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs Bloc transitions in debug; always logs [Bloc.onError] to the DevTools log.
class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint(
        '${bloc.runtimeType} ${transition.event.runtimeType} → ${transition.nextState.runtimeType}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      '${bloc.runtimeType} error: $error',
      name: 'nabdh_alyaman.bloc',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} error: $error\n$stackTrace');
    }
  }
}
