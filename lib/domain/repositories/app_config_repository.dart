import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_update_policy.dart';
import '../entities/global_app_data.dart';

class AppConfigBundle {
  const AppConfigBundle({
    required this.data,
    required this.updatePolicy,
    required this.raw,
  });

  final GlobalAppData data;
  final AppUpdatePolicy updatePolicy;
  final Map<String, dynamic> raw;
}

abstract class AppConfigRepository {
  Future<Either<Failure, AppConfigBundle>> load({required String currentVersion});
}
