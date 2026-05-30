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
  static const authProfileEmail = '/auth/profile/email';
  static const authEmailSendVerification = '/auth/email/send-verification';
  static const authEmailVerify = '/auth/email/verify';

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
  static const centersMe = '/centers/me';
  static const centersMeStock = '/centers/me/stock';
  static const centersMeStockHistory = '/centers/me/stock/history';
  static const centersMeDonations = '/centers/me/donations';

  static String centerById(int id) => '/centers/$id';

  static String centerStockById(int id) => '/centers/$id/stock';

  static const appConfig = '/app-config';

  static String appConfigKey(String key) => '/app-config/$key';

  static const notifications = '/notifications';

  static String notificationRead(int id) => '/notifications/$id/read';

  static const notificationsReadAll = '/notifications/read-all';

  static const bloodRequests = '/blood-requests';

  static const bloodRequestsMy = '/blood-requests/my';

  static String bloodRequestById(String id) => '/blood-requests/$id';

  static String bloodRequestStatus(String id) => '/blood-requests/$id/status';
}
