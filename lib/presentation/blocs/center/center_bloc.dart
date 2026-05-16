import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/check_active.dart';
import '../../../core/error/failures.dart';
import '../../../data/models/center_profile_dto.dart';
import '../../../domain/entities/blood_center.dart';
import '../../../domain/models/center_profile_form.dart';
import '../../../domain/usecases/center/center_use_case.dart';

part 'center_event.dart';
part 'center_state.dart';

class CenterBloc extends Bloc<CenterEvent, CenterState> {
  CenterBloc({required CenterUseCase centerUseCase})
      : _centerUseCase = centerUseCase,
        super(CenterInitial()) {
    on<CenterProfileLoadRequested>(_onLoad);
    on<CenterProfileUpdateSubmitted>(_onProfileUpdate);
    on<CenterStockSaveSubmitted>(_onStockSave);
    on<CenterDonationRecordSubmitted>(_onDonation);
    on<CenterStockHistoryLoadRequested>(_onHistory);
  }

  final CenterUseCase _centerUseCase;

  Map<String, int> _baselineFromCenter(BloodCenter center) {
    return ProfileCenterData.fromBloodCenter(center).stockSnapshot();
  }

  Future<void> _onLoad(
    CenterProfileLoadRequested event,
    Emitter<CenterState> emit,
  ) async {
    emit(CenterLoadingBeforeFetch());
    final result = await _centerUseCase.loadProfile();
    result.fold(
      (failure) => emit(CenterFailure(message: getFailureMessage(failure))),
      (center) {
        CheckActive.currentBloodCenter = center;
        emit(CenterProfileLoaded(
          center: center,
          stockBaseline: _baselineFromCenter(center),
        ));
      },
    );
  }

  Future<void> _onProfileUpdate(
    CenterProfileUpdateSubmitted event,
    Emitter<CenterState> emit,
  ) async {
    emit(CenterLoading());
    final result = await _centerUseCase.updateProfile(data: event.data);
    await result.fold(
      (failure) async {
        emit(CenterFailure(message: getFailureMessage(failure)));
      },
      (center) async {
        CheckActive.currentBloodCenter = center;
        emit(CenterSuccess(message: 'تم حفظ بيانات المركز'));
        emit(CenterProfileLoaded(
          center: center,
          stockBaseline: _baselineFromCenter(center),
        ));
      },
    );
  }

  Future<void> _onStockSave(
    CenterStockSaveSubmitted event,
    Emitter<CenterState> emit,
  ) async {
    emit(CenterLoading());
    final result = await _centerUseCase.applyStockDeltas(
      current: event.current,
      baseline: event.baseline,
      reason: event.reason,
    );
    await result.fold(
      (failure) async {
        emit(CenterFailure(message: getFailureMessage(failure)));
      },
      (_) async {
        add(CenterProfileLoadRequested());
        emit(CenterSuccess(message: 'تم تحديث المخزون'));
      },
    );
  }

  Future<void> _onDonation(
    CenterDonationRecordSubmitted event,
    Emitter<CenterState> emit,
  ) async {
    emit(CenterLoading());
    final result = await _centerUseCase.recordDonation(
      donorId: event.donorId,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(CenterFailure(message: getFailureMessage(failure))),
      (donation) {
        final parts = <String>['تم تسجيل التبرع'];
        if (donation.eligibleUntil != null &&
            donation.eligibleUntil!.isNotEmpty) {
          parts.add('أهلية المتبرع حتى: ${donation.eligibleUntil}');
        }
        emit(CenterSuccess(message: parts.join('\n')));
      },
    );
  }

  Future<void> _onHistory(
    CenterStockHistoryLoadRequested event,
    Emitter<CenterState> emit,
  ) async {
    if (!event.append) {
      emit(CenterLoading());
    }
    final result = await _centerUseCase.loadStockHistory(cursor: event.cursor);
    result.fold(
      (failure) => emit(CenterFailure(message: getFailureMessage(failure))),
      (page) {
        final previous = state;
        var items = page.items;
        if (event.append && previous is CenterStockHistoryLoaded) {
          items = [...previous.items, ...page.items];
        }
        emit(CenterStockHistoryLoaded(
          items: items,
          nextCursor: page.nextCursor,
          hasNextPage: page.hasNextPage,
          append: event.append,
        ));
      },
    );
  }
}
