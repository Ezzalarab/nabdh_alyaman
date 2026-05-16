import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/data_sources/local_data.dart';
import '../../data/datasources/remote/app_config_remote_datasource.dart';
import '../../data/models/app_config_mapper.dart';
import '../../domain/entities/app_update_policy.dart';
import '../../domain/repositories/app_config_repository.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  AppConfigRepositoryImpl({
    required this.networkInfo,
    required this.remote,
    AppConfigMapper? mapper,
  }) : _mapper = mapper ?? AppConfigMapper();

  final NetworkInfo networkInfo;
  final AppConfigRemoteDataSource remote;
  final AppConfigMapper _mapper;

  @override
  Future<Either<Failure, AppConfigBundle>> load({
    required String currentVersion,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final raw = await remote.fetchConfig();
      final data = _mapper.toGlobalAppData(raw);
      final policy = _mapper.parseUpdatePolicy(
        raw,
        currentVersion: currentVersion,
      );
      return Right(
        AppConfigBundle(data: data, updatePolicy: policy, raw: raw),
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Right(
        AppConfigBundle(
          data: LocalData.initialAppData,
          updatePolicy: AppUpdatePolicy.empty,
          raw: const {},
        ),
      );
    }
  }
}
