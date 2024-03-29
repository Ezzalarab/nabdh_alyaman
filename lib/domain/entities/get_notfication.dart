import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GetNotficationData {
  final String date;
  final String title;
  final String body;
  final String isRead;
  final String donorID;
  GetNotficationData({
    required this.date,
    required this.title,
    required this.body,
    required this.isRead,
    required this.donorID,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'title': title,
      'body': body,
      'isRead': isRead,
      'donorID': donorID,
    };
  }

  factory GetNotficationData.fromMap(Map<String, dynamic> map) {
    return GetNotficationData(
      date: map['date']?.toString() ?? "",
      title: map['title']?.toString() ?? "",
      body: map['body']?.toString() ?? "",
      isRead: map['isRead']?.toString() ?? "",
      donorID: map['donorID']?.toString() ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory GetNotficationData.fromJson(String source) =>
      GetNotficationData.fromMap(json.decode(source) as Map<String, dynamic>);
}
