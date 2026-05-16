part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchFiltersChanged extends SearchEvent {
  const SearchFiltersChanged({this.bloodType, this.stateId, this.districtId});

  final String? bloodType;
  final int? stateId;
  final int? districtId;

  @override
  List<Object?> get props => [bloodType, stateId, districtId];
}

class SearchRequested extends SearchEvent {
  const SearchRequested({this.bloodType, this.stateId, this.districtId});

  final String? bloodType;
  final int? stateId;
  final int? districtId;

  @override
  List<Object?> get props => [bloodType, stateId, districtId];
}

class SearchTabChanged extends SearchEvent {
  const SearchTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}
