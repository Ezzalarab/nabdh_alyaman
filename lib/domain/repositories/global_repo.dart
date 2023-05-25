import 'package:dartz/dartz.dart';

import '../../domain/entities/global_app_data.dart';
import '../../../core/error/failures.dart';

abstract class GlobalRepo {
  Future<Either<Failure, GlobalAppData>> getGlobalData();
}
