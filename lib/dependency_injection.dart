import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'data/repositories/send_notfication_impl.dart';
import 'domain/repositories/notfication_repository.dart';
import 'domain/usecases/search_centers_usecase.dart';
import 'domain/usecases/search_state_donors_usecase.dart';
import 'domain/usecases/send_notfication_.dart';
import 'presentation/cubit/send_notfication/send_notfication_cubit.dart';
import 'core/network/network_info.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/search_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/usecases/profile_use_case.dart';
import 'domain/usecases/reset_password_use_case.dart';
import 'domain/usecases/search_donors_usecase.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/sign_up_center_usecase.dart';
import 'domain/usecases/sign_up_donor_usecase.dart';
import 'presentation/cubit/profile_cubit/profile_cubit.dart';
import 'presentation/cubit/search_cubit/search_cubit.dart';
import 'presentation/cubit/signin_cubit/signin_cubit.dart';
import 'presentation/cubit/signup_cubit/signup_cubit.dart';

final sl = GetIt.instance;

Future<void> initApp() async {
  // Auth Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(networkInfo: sl()));

  // Search Repositories
  sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(networkInfo: sl()));
  // Search UseCases
  sl.registerLazySingleton(() => SearchDonorsUseCase(searchRepository: sl()));
  sl.registerLazySingleton(
      () => SearchStateDonorsUseCase(searchRepository: sl()));
  sl.registerLazySingleton(() => SearchCentersUseCase(searchRepository: sl()));
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
    sl.registerFactory(() => SignUpDonorUseCase(authRepository: sl()));
    sl.registerFactory(() => SignUpCenterUseCase(authRepository: sl()));

    // Cubits
    sl.registerFactory(
        () => SignUpCubit(signUpDonorUseCase: sl(), signUpCenterUseCase: sl()));
  }
}
