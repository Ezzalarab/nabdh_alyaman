import '../../domain/entities/blood_center.dart';
import 'center_json_mapper.dart';

class CenterProfileDto {
  CenterProfileDto({
    required this.center,
    this.centerId,
  });

  final BloodCenter center;
  final int? centerId;

  factory CenterProfileDto.fromJson(Map<String, dynamic> json) {
    return CenterProfileDto(
      center: bloodCenterFromApiJson(json),
      centerId: readInt(json['id'] ?? json['centerId']),
    );
  }
}

class CenterStockAdjustResult {
  CenterStockAdjustResult({
    required this.bloodType,
    required this.quantity,
  });

  final String bloodType;
  final int quantity;

  factory CenterStockAdjustResult.fromJson(Map<String, dynamic> json) {
    final updated = json['updatedStock'];
    if (updated is Map) {
      final m = Map<String, dynamic>.from(updated);
      return CenterStockAdjustResult(
        bloodType: m['bloodType']?.toString() ?? '',
        quantity: readInt(m['quantity']) ?? 0,
      );
    }
    return CenterStockAdjustResult(
      bloodType: json['bloodType']?.toString() ?? '',
      quantity: readInt(json['quantity']) ?? 0,
    );
  }
}

class CenterStockHistoryEntry {
  CenterStockHistoryEntry({
    required this.id,
    required this.bloodType,
    required this.change,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String bloodType;
  final int change;
  final String reason;
  final String createdAt;

  factory CenterStockHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CenterStockHistoryEntry(
      id: json['id']?.toString() ?? '',
      bloodType: json['bloodType']?.toString() ?? '',
      change: readInt(json['change']) ?? 0,
      reason: json['reason']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class CenterStockHistoryPage {
  CenterStockHistoryPage({
    required this.items,
    this.nextCursor,
    this.hasNextPage = false,
  });

  final List<CenterStockHistoryEntry> items;
  final String? nextCursor;
  final bool hasNextPage;
}

class CenterDonationResult {
  CenterDonationResult({
    this.message,
    this.eligibleUntil,
  });

  final String? message;
  final String? eligibleUntil;

  factory CenterDonationResult.fromJson(Map<String, dynamic> json) {
    final donor = json['donor'];
    String? eligible;
    if (donor is Map) {
      eligible = donor['eligibleUntil']?.toString();
    }
    return CenterDonationResult(
      message: json['message']?.toString(),
      eligibleUntil: eligible ?? json['eligibleUntil']?.toString(),
    );
  }
}
