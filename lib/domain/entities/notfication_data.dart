// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SendNotificationData {
  List<String> listToken;
  String title;
  String body;
  SendNotificationData({
    required this.listToken,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'listToken': listToken,
      'title': title,
      'body': body,
    };
  }

  factory SendNotificationData.fromMap(Map<String, dynamic> map) {
    return SendNotificationData(
      listToken: List<String>.from((map['listToken'] as List<String>)),
      title: map['title'] as String,
      body: map['body'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SendNotificationData.fromJson(String source) =>
      SendNotificationData.fromMap(json.decode(source) as Map<String, dynamic>);
}

//   static  fromJson(json) => LostReport(
//         device: Device(
//           name: json["deviceName"],
//           model: json["deviceName"],
//           IMEI: json["deviceName"],
//         ),
//         country: json["country"],
//         governorate: json["governorate"],
//         district: json["district"],
//         place: json["place"],
//         date: json["contactNumber"],
//         contactNumber: json["contactNumber"],
//       );
// }