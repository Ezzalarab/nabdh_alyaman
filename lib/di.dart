import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'data/repositories/global_repo_impl.dart';
import 'domain/repositories/global_repo.dart';
import 'domain/usecases/get_global_data_uc.dart';
import 'presentation/cubit/global_cubit/global_cubit.dart';
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

final gi = GetIt.instance;

Future<void> initApp() async {
  // Auth Repositories
  gi.registerLazySingleton<AuthRepo>(
      () => AuthRepositoryImpl(networkInfo: gi()));

  // Search Repositories
  gi.registerLazySingleton<SearchRepo>(() => SearchRepoImpl(networkInfo: gi()));
  // Search UseCases
  gi.registerLazySingleton(() => SearchDonorsUC(searchRepository: gi()));
  gi.registerLazySingleton(() => SearchStateDonorsUC(searchRepository: gi()));
  gi.registerLazySingleton(() => SearchCentersUC(searchRepository: gi()));
  // Search Cubit
  gi.registerLazySingleton(() => SearchCubit(
        searchCentersUseCase: gi(),
        searchStateDonorsUseCase: gi(),
      ));

  // Profile Repositories
  gi.registerLazySingleton<ProfileRepository>(
      () => ProfileReopsitoryImpl(networkInfo: gi()));

  // Profile UseCases
  gi.registerLazySingleton(() => ProfileUseCase(profileRepository: gi()));

  // Profile Cubits
  gi.registerLazySingleton(() => ProfileCubit(profileUseCase: gi()));

  // SendNotfication
  gi.registerLazySingleton<SendNotficationRepository>(
      () => SendNotficationImpl(networkInfo: gi()));

  // send Notfication  useCase
  gi.registerLazySingleton(
      () => SendNotficationUseCase(sendNotificationRepository: gi()));

  // send Notfication  cubit
  gi.registerLazySingleton(
      () => SendNotficationCubit(sendNotficationUseCase: gi()));

  // Global Data

  // global data  user case
  gi.registerLazySingleton(() => GetGlobalDataUC(globalRepo: gi()));

  // global data  cubit
  gi.registerLazySingleton(() => GlobalCubit(getGlobalDataUC: gi()));

  // global data repo
  gi.registerLazySingleton<GlobalRepo>(() => GlobalRepoImpl(networkInfo: gi()));

  /// Core
  ///

  // NetworkInfo
  gi.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoChecker(connectionChecker: gi()));

  /// External

  // Internet Info Checker
  gi.registerLazySingleton(() => InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 15)));
}

initSignIn() {
  if (!GetIt.I.isRegistered<SignInCubit>()) {
    // UseCases
    gi.registerFactory(() => SignInUseCase(authRepository: gi()));

    gi.registerFactory(
        () => ResetPasswordUseCase(resetPasswordRepository: gi()));
    // Cubits
    gi.registerFactory(
        () => SignInCubit(signInUseCase: gi(), resetPasswordUseCase: gi()));
  }
}

initSignUp() {
  if (!GetIt.I.isRegistered<SignUpCubit>()) {
    // UseCases
    gi.registerFactory(() => SignUpDonorAuthUseCase(authRepository: gi()));
    gi.registerFactory(() => SignUpDonorDataUseCase(authRepository: gi()));
    gi.registerFactory(() => SignUpCenterUseCase(authRepository: gi()));

    // Cubits
    gi.registerFactory(() => SignUpCubit(
        signUpDonorAuthUseCase: gi(),
        signUpCenterUseCase: gi(),
        saveDonorDataUC: gi()));
  }
}
