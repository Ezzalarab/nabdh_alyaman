abstract class Failure {}

class OffLineFailure extends Failure {}

class ServerFailure extends Failure {}

class EmptyCacheFailure extends Failure {}

class WrongDataFailure extends Failure {}

class UnknownFailure extends Failure {}

class FirebaseUnknownFailure extends Failure {}

class InvalidEmailFailure extends Failure {}

class WeekPasswordFailure extends Failure {}

class EmailAlreadyRegisteredFailure extends Failure {}

class FirebaseNullValueFailure extends Failure {}

class DoesnotSaveData extends Failure {}

String getFailureMessage(Failure failur) {
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
    case FirebaseUnknownFailure:
      return "خطأ من قاعدة البيانات غير معروف";
    case InvalidEmailFailure:
      return "تحقق من صحة بريدك الالكتروني";
    case DoesnotSaveData:
      return "لم يتم تحديث البيانات";
    default:
      return "خطأ غير معروف";
  }
}
