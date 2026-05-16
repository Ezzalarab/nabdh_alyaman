/// REST paths relative to [AppConfig.apiBaseUrl] (`/api/v1` included in base).
class ApiEndpoints {
  ApiEndpoints._();

  static const health = '/health';

  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const authDevice = '/auth/device';
  static const authForgotPassword = '/auth/forgot-password';
  static const authVerifyOtp = '/auth/verify-otp';
  static const authResetPassword = '/auth/reset-password';

  static String locationsDistricts(int stateId) =>
      '/locations/$stateId/districts';

  /// Public list under `/locations`.
  static const locationsStates = '/locations';

  static const donorsMe = '/donors/me';
  static const donorsMeDonations = '/donors/me/donations';

  static const filesUpload = '/files/upload';

  static String fileById(int fileId) => '/files/$fileId';

  static const donorSearch = '/donor-search';
  static const donorSearchManual = '/donor-search/manual';
  static const centers = '/centers';
}
