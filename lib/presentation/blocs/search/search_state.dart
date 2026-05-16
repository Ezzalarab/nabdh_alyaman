part of 'search_bloc.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial({this.bloodType, this.stateId, this.districtId});

  final String? bloodType;
  final int? stateId;
  final int? districtId;
}

class SearchLoading extends SearchState {
  const SearchLoading({
    required this.bloodType,
    required this.stateId,
    required this.districtId,
  });

  final String bloodType;
  final int stateId;
  final int districtId;
}

class SearchSuccess extends SearchState {
  const SearchSuccess({
    required this.donors,
    required this.centers,
    required this.stateDonors,
    required this.selectedTabIndex,
    required this.bloodType,
    required this.stateId,
    required this.districtId,
  });

  final List<Donor> donors;
  final List<BloodCenter> centers;
  final List<Donor> stateDonors;
  final int selectedTabIndex;
  final String bloodType;
  final int stateId;
  final int districtId;

  SearchSuccess copyWith({
    List<Donor>? donors,
    List<BloodCenter>? centers,
    List<Donor>? stateDonors,
    int? selectedTabIndex,
    String? bloodType,
    int? stateId,
    int? districtId,
  }) {
    return SearchSuccess(
      donors: donors ?? this.donors,
      centers: centers ?? this.centers,
      stateDonors: stateDonors ?? this.stateDonors,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      bloodType: bloodType ?? this.bloodType,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
    );
  }
}

class SearchFailure extends SearchState {
  const SearchFailure({
    required this.error,
    this.bloodType,
    this.stateId,
    this.districtId,
  });

  final String error;
  final String? bloodType;
  final int? stateId;
  final int? districtId;
}
