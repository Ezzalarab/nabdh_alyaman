import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/blood_request.dart';
import '../../../domain/usecases/blood_request_use_case.dart';

part 'blood_request_event.dart';
part 'blood_request_state.dart';

class BloodRequestBloc extends Bloc<BloodRequestEvent, BloodRequestState> {
  BloodRequestBloc({required BloodRequestUseCase useCase})
      : _useCase = useCase,
        super(BloodRequestInitial()) {
    on<BloodRequestCreateSubmitted>(_onCreate);
    on<BloodRequestListLoadRequested>(_onListLoad);
    on<BloodRequestDetailLoadRequested>(_onDetailLoad);
    on<BloodRequestStatusUpdateSubmitted>(_onStatusUpdate);
  }

  final BloodRequestUseCase _useCase;

  Future<void> _onCreate(
    BloodRequestCreateSubmitted event,
    Emitter<BloodRequestState> emit,
  ) async {
    emit(BloodRequestLoading());
    final result = await _useCase.create(event.params);
    result.fold(
      (failure) => emit(
        BloodRequestFailure(_messageForCreateFailure(failure)),
      ),
      (request) => emit(
        BloodRequestSuccess(request: request, createdId: request.id),
      ),
    );
  }

  Future<void> _onListLoad(
    BloodRequestListLoadRequested event,
    Emitter<BloodRequestState> emit,
  ) async {
    emit(BloodRequestLoading());
    final result = await _useCase.loadList(
      bloodType: event.bloodType,
      stateId: event.stateId,
      cursor: event.cursor,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(BloodRequestFailure(getFailureMessage(failure))),
      (page) => emit(BloodRequestListLoaded(items: page.items)),
    );
  }

  Future<void> _onDetailLoad(
    BloodRequestDetailLoadRequested event,
    Emitter<BloodRequestState> emit,
  ) async {
    emit(BloodRequestLoading());
    final result = await _useCase.loadDetail(event.id);
    result.fold(
      (failure) => emit(BloodRequestFailure(getFailureMessage(failure))),
      (request) => emit(BloodRequestDetailLoaded(request: request)),
    );
  }

  Future<void> _onStatusUpdate(
    BloodRequestStatusUpdateSubmitted event,
    Emitter<BloodRequestState> emit,
  ) async {
    emit(BloodRequestLoading());
    final result = await _useCase.updateStatus(
      id: event.id,
      status: event.status,
    );
    result.fold(
      (failure) => emit(BloodRequestFailure(getFailureMessage(failure))),
      (request) => emit(BloodRequestDetailLoaded(request: request)),
    );
  }

  String _messageForCreateFailure(Failure failure) {
    if (failure is ThrottledFailure) {
      return failure.message ??
          'لديك طلب استغاثة مفتوح بالفعل. ألغِه أو أكمله قبل إنشاء طلب جديد.';
    }
    return getFailureMessage(failure);
  }
}
