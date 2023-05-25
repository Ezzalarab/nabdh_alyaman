import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/network/network_info.dart';
import 'data/repositories/auth_repo_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/search_repo_impl.dart';
import 'data/repositories/send_notfication_impl.dart';
import 'domain/repositories/auth_repo.dart';
import 'domain/repositories/notfication_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/search_repo.dart';
import 'domain/usecases/profile_use_case.dart';
import 'domain/usecases/reset_password_use_case.dart';
import 'domain/usecases/search_centers_uc.dart';
import 'domain/usecases/search_donors_uc.dart';
import 'domain/usecases/search_state_donors_uc.dart';
import 'domain/usecases/send_notfication_.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/sign_up_center_usecase.dart';
import 'domain/usecases/sign_up_donor_auth_uc.dart';
import 'domain/usecases/sign_up_donor_data_uc.dart';
import 'presentation/cubit/profile_cubit/profile_cubit.dart';
import 'presentation/cubit/search_cubit/search_cubit.dart';
import 'presentation/cubit/send_notfication/send_notfication_cubit.dart';
import 'presentation/cubit/signin_cubit/signin_cubit.dart';
import 'presentation/cubit/signup_cubit/signup_cubit.dart';

final sl = GetIt.instance;

Future<void> initApp() async {
  // Auth Repositories
  sl.registerLazySingleton<AuthRepo>(
      () => AuthRepositoryImpl(networkInfo: sl()));

  // Search Repositories
  sl.registerLazySingleton<SearchRepo>(() => SearchRepoImpl(networkInfo: sl()));
  // Search UseCases
  sl.registerLazySingleton(() => SearchDonorsUC(searchRepository: sl()));
  sl.registerLazySingleton(() => SearchStateDonorsUC(searchRepository: sl()));
  sl.registerLazySingleton(() => SearchCentersUC(searchRepository: sl()));
  // Search Cubit
  sl.registerLazySingleton(() => SearchCubit(
        searchCentersUseCase: sl(),
        searchStateDonorsUseCase: sl(),
      ));
  // sl.registerLazySingleton(() => MapsCubit());

  // Profile Repositories
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileReopsitoryImpl(networkInfo: sl()));

  // Profile UseCases
  sl.registerLazySingleton(() => ProfileUseCase(profileRepository: sl()));

  // Profile Cubits
  sl.registerLazySingleton(() => ProfileCubit(profileUseCase: sl()));

  // SendNotfication
  sl.registerLazySingleton<SendNotficationRepository>(
      () => SendNotficationImpl(networkInfo: sl()));
  // send Notfication  useCase
  sl.registerLazySingleton(
      () => SendNotficationUseCase(sendNotificationRepository: sl()));

  // send Notfication  cubit
  sl.registerLazySingleton(
      () => SendNotficationCubit(sendNotficationUseCase: sl()));

  /// Core

  // NetworkInfo
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoChecker(connectionChecker: sl()));

  /// External

  // Internet Info Checker
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 15)));
}

initSignIn() {
  if (!GetIt.I.isRegistered<SignInCubit>()) {
    // UseCases
    sl.registerFactory(() => SignInUseCase(authRepository: sl()));

    sl.registerFactory(
        () => ResetPasswordUseCase(resetPasswordRepository: sl()));
    // Cubits
    sl.registerFactory(
        () => SignInCubit(signInUseCase: sl(), resetPasswordUseCase: sl()));
  }
}

initSignUp() {
  if (!GetIt.I.isRegistered<SignUpCubit>()) {
    // UseCases
    sl.registerFactory(() => SignUpDonorAuthUseCase(authRepository: sl()));
    sl.registerFactory(() => SignUpDonorDataUseCase(authRepository: sl()));
    sl.registerFactory(() => SignUpCenterUseCase(authRepository: sl()));

    // Cubits
    sl.registerFactory(() => SignUpCubit(
        signUpDonorAuthUseCase: sl(),
        signUpCenterUseCase: sl(),
        saveDonorDataUC: sl()));
  }
}
