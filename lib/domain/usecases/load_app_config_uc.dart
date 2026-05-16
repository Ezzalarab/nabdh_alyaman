import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../repositories/app_config_repository.dart';

class LoadAppConfigUseCase {
  LoadAppConfigUseCase({required AppConfigRepository repository})
      : _repository = repository;

  final AppConfigRepository _repository;

  Future<Either<Failure, AppConfigBundle>> call({
    required String currentVersion,
  }) =>
      _repository.load(currentVersion: currentVersion);
}
