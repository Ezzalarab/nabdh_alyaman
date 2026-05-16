/// REST paths relative to [AppConfig.apiBaseUrl] (`/api/v1` included in base).
class ApiEndpoints {
  ApiEndpoints._();

  static const health = '/health';

  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
}
