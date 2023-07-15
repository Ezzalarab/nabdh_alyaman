import 'dart:convert';

class NewsCardData {
  final String id;
  final String title;
  final String desc;
  final String image;
  final String date;
  final String place;
  final String link;

  NewsCardData({
    required this.id,
    required this.title,
    required this.desc,
    required this.image,
    required this.date,
    required this.place,
    required this.link,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      NewsCardDataFields.id: id,
      NewsCardDataFields.title: title,
      NewsCardDataFields.desc: desc,
      NewsCardDataFields.image: image,
      NewsCardDataFields.date: date,
      NewsCardDataFields.place: place,
      NewsCardDataFields.link: link,
    };
  }

  factory NewsCardData.fromMap(Map<String, dynamic> map) {
    return NewsCardData(
      id: map[NewsCardDataFields.id]?.toString() ?? "",
      title: map[NewsCardDataFields.title]?.toString() ?? "",
      desc: map[NewsCardDataFields.desc]?.toString() ?? "",
      image: map[NewsCardDataFields.image]?.toString() ?? "",
      date: map[NewsCardDataFields.date]?.toString() ?? "",
      place: map[NewsCardDataFields.place]?.toString() ?? "",
      link: map[NewsCardDataFields.link]?.toString() ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory NewsCardData.fromJson(String source) =>
      NewsCardData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NewsCardDataFields {
  static const String id = "id";
  static const String title = "title";
  static const String desc = "desc";
  static const String image = "image";
  static const String date = "date";
  static const String place = "place";
  static const String link = "link";
}
