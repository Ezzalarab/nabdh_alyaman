import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/blood_center.dart';
import '../../../domain/entities/donor.dart';
import '../../../domain/usecases/search_centers_uc.dart';
import '../../../domain/usecases/search_donors_uc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchDonorsUC searchDonorsUC,
    required SearchCentersUC searchCentersUC,
  })  : _searchDonorsUC = searchDonorsUC,
        _searchCentersUC = searchCentersUC,
        super(const SearchInitial()) {
    on<SearchFiltersChanged>(_onFiltersChanged);
    on<SearchRequested>(_onSearchRequested);
    on<SearchTabChanged>(_onTabChanged);
  }

  final SearchDonorsUC _searchDonorsUC;
  final SearchCentersUC _searchCentersUC;

  void _onFiltersChanged(SearchFiltersChanged event, Emitter<SearchState> emit) {
    final current = state;
    if (current is SearchSuccess) {
      emit(current.copyWith(
        bloodType: event.bloodType ?? current.bloodType,
        stateId: event.stateId ?? current.stateId,
        districtId: event.districtId ?? current.districtId,
      ));
    } else {
      emit(SearchInitial(
        bloodType: event.bloodType,
        stateId: event.stateId,
        districtId: event.districtId,
      ));
    }
  }

  Future<void> _onSearchRequested(
    SearchRequested event,
    Emitter<SearchState> emit,
  ) async {
    final bloodType = event.bloodType;
    final stateId = event.stateId;
    final districtId = event.districtId;
    if (bloodType == null ||
        bloodType.isEmpty ||
        stateId == null ||
        districtId == null) {
      emit(SearchFailure(
        error: 'يجب تحديد الخيارات المطلوب البحث عنها',
        bloodType: bloodType,
        stateId: stateId,
        districtId: districtId,
      ));
      return;
    }

    emit(SearchLoading(
      bloodType: bloodType,
      stateId: stateId,
      districtId: districtId,
    ));

    final donorsResult = await _searchDonorsUC(
      bloodType: bloodType,
      stateId: stateId,
      districtId: districtId,
    );

    await donorsResult.fold(
      (failure) async {
        emit(SearchFailure(
          error: getFailureMessage(failure),
          bloodType: bloodType,
          stateId: stateId,
          districtId: districtId,
        ));
      },
      (donors) async {
        final centersResult = await _searchCentersUC(
          stateId: stateId,
          districtId: districtId,
        );
        centersResult.fold(
          (failure) => emit(SearchFailure(
                error: getFailureMessage(failure),
                bloodType: bloodType,
                stateId: stateId,
                districtId: districtId,
              )),
          (centers) => emit(SearchSuccess(
            donors: donors,
            centers: centers,
            stateDonors: donors,
            selectedTabIndex: 0,
            bloodType: bloodType,
            stateId: stateId,
            districtId: districtId,
          )),
        );
      },
    );
  }

  void _onTabChanged(SearchTabChanged event, Emitter<SearchState> emit) {
    final current = state;
    if (current is SearchSuccess) {
      emit(current.copyWith(selectedTabIndex: event.tabIndex));
    }
  }
}
