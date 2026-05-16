part of 'search_bloc.dart';

abstract class SearchEvent {}

class SearchFiltersChanged extends SearchEvent {
  SearchFiltersChanged({this.bloodType, this.stateId, this.districtId});

  final String? bloodType;
  final int? stateId;
  final int? districtId;
}

class SearchRequested extends SearchEvent {
  SearchRequested({this.bloodType, this.stateId, this.districtId});

  final String? bloodType;
  final int? stateId;
  final int? districtId;
}

class SearchTabChanged extends SearchEvent {
  SearchTabChanged(this.tabIndex);
  final int tabIndex;
}
