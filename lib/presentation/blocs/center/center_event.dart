part of 'center_bloc.dart';

sealed class CenterEvent {}

final class CenterProfileLoadRequested extends CenterEvent {}

final class CenterProfileUpdateSubmitted extends CenterEvent {
  CenterProfileUpdateSubmitted(this.data);

  final ProfileCenterData data;
}

final class CenterStockSaveSubmitted extends CenterEvent {
  CenterStockSaveSubmitted({
    required this.current,
    required this.baseline,
    this.reason,
  });

  final ProfileCenterData current;
  final Map<String, int> baseline;
  final String? reason;
}

final class CenterDonationRecordSubmitted extends CenterEvent {
  CenterDonationRecordSubmitted({
    required this.donorId,
    this.notes,
  });

  final int donorId;
  final String? notes;
}

final class CenterStockHistoryLoadRequested extends CenterEvent {
  CenterStockHistoryLoadRequested({this.cursor, this.append = false});

  final String? cursor;
  final bool append;
}
