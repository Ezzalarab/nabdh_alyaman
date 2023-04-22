// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_cubit.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Donor> donors;
  final List<BloodCenter> centers;
  final List<Donor> stateDonors;
  int selectedTabIndex;
  SearchSuccess({
    required this.donors,
    required this.centers,
    required this.stateDonors,
    required this.selectedTabIndex,
  });
}

class SearchLoading extends SearchState {}

// class SearchLoadingMaps extends SearchState {}

// class SearchToMaps extends SearchState {
//   final List<DonorPoint> nearbyDonors;
//   SearchToMaps({
//     required this.nearbyDonors,
//   });
// }

class SearchFailure extends SearchState {
  final String error;
  SearchFailure({
    required this.error,
  });
}
