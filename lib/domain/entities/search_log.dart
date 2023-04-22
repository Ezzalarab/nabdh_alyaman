import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SearchLog {
  final String state;
  final String district;
  final String bloodType;
  final String date;
  final String donorsCount;
  final String token;
  final String userType;

  SearchLog({
    required this.state,
    required this.district,
    required this.bloodType,
    required this.date,
    required this.donorsCount,
    required this.token,
    required this.userType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      SearchLogFields.state: state,
      SearchLogFields.district: district,
      SearchLogFields.bloodType: bloodType,
      SearchLogFields.date: date,
      SearchLogFields.donorsCount: donorsCount,
      SearchLogFields.token: token,
      SearchLogFields.userType: userType,
    };
  }

  factory SearchLog.fromMap(Map<String, dynamic> map) {
    return SearchLog(
      state: map[SearchLogFields.state] as String,
      district: map[SearchLogFields.district] as String,
      bloodType: map[SearchLogFields.bloodType] as String,
      date: map[SearchLogFields.date] as String,
      donorsCount: map[SearchLogFields.donorsCount] as String,
      token: map[SearchLogFields.token] as String,
      userType: map[SearchLogFields.userType] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchLog.fromJson(String source) =>
      SearchLog.fromMap(json.decode(source) as Map<String, dynamic>);
}

class SearchLogFields {
  static const String state = "state";
  static const String district = "district";
  static const String bloodType = "blood_type";
  static const String date = "date";
  static const String donorsCount = "donors_count";
  static const String token = "token";
  static const String userType = "user_type";
}
