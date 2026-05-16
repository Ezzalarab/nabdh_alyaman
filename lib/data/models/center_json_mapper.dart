import '../../domain/entities/blood_center.dart';

int readStockQty(Map<String, dynamic> map, String key) {
  final v = map[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

String? locationName(dynamic obj) {
  if (obj is! Map) return null;
  final m = Map<String, dynamic>.from(obj);
  return m['nameAr']?.toString() ??
      m['name']?.toString() ??
      m['nameEn']?.toString();
}

int? readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

BloodCenter bloodCenterFromApiJson(Map<String, dynamic> json) {
  final stock = json['bloodStock'];
  final stockMap =
      stock is Map ? Map<String, dynamic>.from(stock) : <String, dynamic>{};

  return BloodCenter(
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    password: '',
    phone: json['phone']?.toString() ?? '',
    state: locationName(json['state']) ?? '',
    district: locationName(json['district']) ?? '',
    neighborhood: json['locationName']?.toString() ??
        locationName(json['location']) ??
        '',
    image: json['imageUrl']?.toString() ?? '',
    lastUpdate: json['updatedAt']?.toString() ?? '',
    lat: json['lat']?.toString() ?? '',
    lon: json['lon']?.toString() ?? '',
    token: '',
    status: '1',
    stateId: readInt(json['stateId']),
    districtId: readInt(json['districtId']),
    locationId: readInt(json['locationId']),
    aPlus: readStockQty(stockMap, 'A+'),
    aMinus: readStockQty(stockMap, 'A-'),
    bPlus: readStockQty(stockMap, 'B+'),
    bMinus: readStockQty(stockMap, 'B-'),
    abPlus: readStockQty(stockMap, 'AB+'),
    abMinus: readStockQty(stockMap, 'AB-'),
    oPlus: readStockQty(stockMap, 'O+'),
    oMinus: readStockQty(stockMap, 'O-'),
  );
}
