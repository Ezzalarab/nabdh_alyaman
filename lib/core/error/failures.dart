abstract class Failure {}

class OffLineFailure extends Failure {}

class ServerFailure extends Failure {}

class EmptyCacheFailure extends Failure {}

class WrongDataFailure extends Failure {}

class UnknownFailure extends Failure {}

class InvalidEmailFailure extends Failure {}

class WeekPasswordFailure extends Failure {}

class EmailAlreadyRegisteredFailure extends Failure {}

class DoesnotSaveData extends Failure {}

/// Transport / timeout / DNS (REST client).
class NetworkFailure extends Failure {}

/// 401 — e.g. expired or invalid JWT after refresh attempt.
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({this.message});
  final String? message;
}

/// 403 — may include [apiCode] such as `BLOCKED` or `NEEDS_FIREBASE_PASSWORD`.
class ForbiddenFailure extends Failure {
  ForbiddenFailure({this.message, this.apiCode});
  final String? message;
  final String? apiCode;
}

/// 400 validation / bad request.
class ValidationFailure extends Failure {
  ValidationFailure({this.message});
  final String? message;
}

/// 429 throttling.
class ThrottledFailure extends Failure {
  ThrottledFailure({this.message, this.retryAfterSeconds});
  final String? message;
  final int? retryAfterSeconds;
}

String getFailureMessage(Failure failur) {
  if (failur is UnauthorizedFailure) {
    return failur.message ?? 'انتهت الجلسة، يُرجى تسجيل الدخول مرة أخرى';
  }
  if (failur is ForbiddenFailure) {
    return failur.message ?? 'تم رفض الطلب';
  }
  if (failur is ValidationFailure) {
    return failur.message ?? 'تأكد من صحة البيانات المدخلة';
  }
  if (failur is ThrottledFailure) {
    return failur.message ??
        'تم تجاوز الحد المسموح، حاول لاحقاً';
  }
  if (failur is NetworkFailure) {
    return 'تعذّر الاتصال بالخادم؛ تحقق من الإنترنت';
  }

  switch (failur.runtimeType) {
    case OffLineFailure:
      return "لا يوجد إنترنت";
    case WrongDataFailure:
      return "تأكد من صحة البيانات المدخلة";
    case ServerFailure:
      return "خطأ في السرفر حاول مرة أخرى لاحقاً";
    case EmptyCacheFailure:
      return "لا يوجد بيانات محلية";
    case UnknownFailure:
      return "خطأ غير معروف";
    case InvalidEmailFailure:
      return "تحقق من صحة بريدك الالكتروني";
    case DoesnotSaveData:
      return "لم يتم تحديث البيانات";
    default:
      return "خطأ غير معروف";
  }
}
