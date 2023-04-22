import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class OffLineFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class WrongDataFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnknownFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class FirebaseUnknownFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidEmailFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class WeekPasswordFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmailAlreadyRegisteredFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class FirebaseNullValueFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class DoesnotSaveData extends Failure {
  @override
  List<Object?> get props => [];
}

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
