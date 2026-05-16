import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_refresh_interceptor.dart';
import 'core/network/dio_api_client.dart';
import 'core/network/network_info.dart';
import 'core/session/session_lifecycle.dart';
import 'data/datasources/local/locations_local_datasource.dart';
import 'data/datasources/local/preferences_local_datasource.dart';
import 'data/datasources/local/preferences_local_datasource_impl.dart';
import 'data/datasources/local/session_local_datasource.dart';
import 'data/datasources/local/session_local_datasource_impl.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'core/files/file_url_resolver.dart';
import 'data/datasources/remote/donor_remote_datasource.dart';
import 'data/datasources/remote/files_remote_datasource.dart';
import 'data/datasources/remote/locations_remote_datasource.dart';
import 'core/notifications/fcm_service.dart';
import 'data/datasources/remote/app_config_remote_datasource.dart';
import 'data/datasources/remote/center_remote_datasource.dart';
import 'data/datasources/remote/blood_request_remote_datasource.dart';
import 'data/datasources/remote/notifications_remote_datasource.dart';
import 'data/datasources/remote/search_remote_datasource.dart';
import 'data/repositories/app_config_repository_impl.dart';
import 'data/repositories/auth_repo_impl.dart';
import 'data/repositories/center_repository_impl.dart';
import 'data/repositories/blood_request_repository_impl.dart';
import 'data/repositories/notifications_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/search_repo_impl.dart';
import 'domain/repositories/app_config_repository.dart';
import 'domain/repositories/auth_repo.dart';
import 'domain/repositories/blood_request_repository.dart';
import 'domain/repositories/notifications_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/center_repository.dart';
import 'domain/repositories/search_repo.dart';
import 'domain/usecases/center/center_use_case.dart';
import 'domain/usecases/load_app_config_uc.dart';
import 'domain/usecases/blood_request_use_case.dart';
import 'domain/usecases/notifications_use_case.dart';
import 'domain/usecases/profile_use_case.dart';
import 'domain/usecases/search_centers_uc.dart';
import 'domain/usecases/search_donors_uc.dart';
import 'presentation/blocs/app_config/app_config_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/center/center_bloc.dart';
import 'presentation/blocs/blood_request/blood_request_bloc.dart';
import 'presentation/blocs/notifications/notifications_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';

final gi = GetIt.instance;

Future<void> initApp() async {
  final prefs = await SharedPreferences.getInstance();
  gi.registerSingleton<SharedPreferences>(prefs);
  gi.registerSingleton<AppConfig>(const AppConfig());
  gi.registerLazySingleton<SessionLifecycle>(() => SessionLifecycle());

  gi.registerLazySingleton(
    () => InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 15),
    ),
  );

  gi.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoChecker(connectionChecker: gi()),
  );

  gi.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  gi.registerLazySingleton<PreferencesLocalDataSource>(
    () => PreferencesLocalDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<SessionLocalDataSource>(
    () => SessionLocalDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<LocationsLocalDataSource>(
    () => LocationsLocalDataSourceImpl(gi()),
  );

  gi.registerLazySingleton<Dio>(
    () => createAppDio(prefs: gi(), session: gi(), lifecycle: gi()),
  );
  gi.registerLazySingleton<ApiClient>(() => DioApiClient(gi()));

  gi.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<DonorRemoteDataSource>(
    () => DonorRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<FilesRemoteDataSource>(
    () => FilesRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<CenterRemoteDataSource>(
    () => CenterRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<AppConfigRemoteDataSource>(
    () => AppConfigRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<BloodRequestRemoteDataSource>(
    () => BloodRequestRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<FileUrlResolver>(() => const FileUrlResolver());
  gi.registerLazySingleton<FcmService>(() => FcmService(authRepo: gi()));

  gi.registerLazySingleton<AuthRepo>(
    () => AuthRepositoryImpl(
      networkInfo: gi(),
      remote: gi(),
      sessionLocal: gi(),
    ),
  );

  gi.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepo: gi(),
      sessionLifecycle: gi(),
    ),
  );

  gi.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(gi()),
  );
  gi.registerLazySingleton<SearchRepo>(
    () => SearchRepoImpl(networkInfo: gi(), remote: gi()),
  );
  gi.registerLazySingleton(() => SearchDonorsUC(searchRepository: gi()));
  gi.registerLazySingleton(() => SearchCentersUC(searchRepository: gi()));
  gi.registerLazySingleton(
    () => SearchBloc(
      searchDonorsUC: gi(),
      searchCentersUC: gi(),
    ),
  );

  gi.registerLazySingleton<ProfileRepository>(
    () => ProfileReopsitoryImpl(
      networkInfo: gi(),
      donorRemote: gi(),
      filesRemote: gi(),
      sessionLocal: gi(),
    ),
  );
  gi.registerLazySingleton(() => ProfileUseCase(profileRepository: gi()));
  gi.registerLazySingleton(() => ProfileBloc(profileUseCase: gi()));

  gi.registerLazySingleton<CenterRepository>(
    () => CenterRepositoryImpl(
      networkInfo: gi(),
      remote: gi(),
      sessionLocal: gi(),
    ),
  );
  gi.registerLazySingleton(() => CenterUseCase(centerRepository: gi()));
  gi.registerLazySingleton(() => CenterBloc(centerUseCase: gi()));

  gi.registerLazySingleton<AppConfigRepository>(
    () => AppConfigRepositoryImpl(networkInfo: gi(), remote: gi()),
  );
  gi.registerLazySingleton(() => LoadAppConfigUseCase(repository: gi()));
  gi.registerLazySingleton(() => AppConfigBloc(loadAppConfig: gi()));

  gi.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(networkInfo: gi(), remote: gi()),
  );
  gi.registerLazySingleton(() => NotificationsUseCase(repository: gi()));
  gi.registerLazySingleton(() => NotificationsBloc(notificationsUseCase: gi()));

  gi.registerLazySingleton<BloodRequestRepository>(
    () => BloodRequestRepositoryImpl(networkInfo: gi(), remote: gi()),
  );
  gi.registerLazySingleton(() => BloodRequestUseCase(repository: gi()));
  gi.registerLazySingleton(() => BloodRequestBloc(useCase: gi()));
}
