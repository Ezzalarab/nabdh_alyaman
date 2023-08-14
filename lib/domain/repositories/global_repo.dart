import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../domain/entities/global_app_data.dart';

abstract class GlobalRepo {
  Future<Either<Failure, GlobalAppData>> getGlobalData();
}
