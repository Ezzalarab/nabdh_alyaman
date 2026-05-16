part of 'center_bloc.dart';

sealed class CenterState {}

final class CenterInitial extends CenterState {}

final class CenterLoading extends CenterState {}

final class CenterLoadingBeforeFetch extends CenterState {}

final class CenterProfileLoaded extends CenterState {
  CenterProfileLoaded({
    required this.center,
    required this.stockBaseline,
  });

  final BloodCenter center;
  final Map<String, int> stockBaseline;
}

final class CenterSuccess extends CenterState {
  CenterSuccess({this.message});

  final String? message;
}

final class CenterStockHistoryLoaded extends CenterState {
  CenterStockHistoryLoaded({
    required this.items,
    this.nextCursor,
    this.hasNextPage = false,
    this.append = false,
  });

  final List<CenterStockHistoryEntry> items;
  final String? nextCursor;
  final bool hasNextPage;
  final bool append;
}

final class CenterFailure extends CenterState {
  CenterFailure({required this.message});

  final String message;
}
