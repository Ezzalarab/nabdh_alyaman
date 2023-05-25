import 'package:dartz/dartz.dart';

import '../../domain/entities/global_app_data.dart';
import '../../domain/repositories/global_repo.dart';
import '../../core/error/failures.dart';

class GetGlobalDataUC {
  final GlobalRepo globalRepo;
  GetGlobalDataUC({required this.globalRepo});

  Future<Either<Failure, GlobalAppData>> call() async {
    return globalRepo.getGlobalData();
  }
}
