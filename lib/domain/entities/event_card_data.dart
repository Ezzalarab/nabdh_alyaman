import 'dart:convert';

class EventCardData {
  final String id;
  final String title;
  final String desc;
  final String image;
  final String date;
  final String place;
  final String link;

  EventCardData({
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
      EventsCardDataFields.id: id,
      EventsCardDataFields.title: title,
      EventsCardDataFields.desc: desc,
      EventsCardDataFields.image: image,
      EventsCardDataFields.date: date,
      EventsCardDataFields.place: place,
      EventsCardDataFields.link: link,
    };
  }

  factory EventCardData.fromMap(Map<String, dynamic> map) {
    return EventCardData(
      id: map[EventsCardDataFields.id]?.toString() ?? "",
      title: map[EventsCardDataFields.title]?.toString() ?? "",
      desc: map[EventsCardDataFields.desc]?.toString() ?? "",
      image: map[EventsCardDataFields.image]?.toString() ?? "",
      date: map[EventsCardDataFields.date]?.toString() ?? "",
      place: map[EventsCardDataFields.place]?.toString() ?? "",
      link: map[EventsCardDataFields.link]?.toString() ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory EventCardData.fromJson(String source) =>
      EventCardData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class EventsCardDataFields {
  static const String id = "id";
  static const String title = "title";
  static const String desc = "desc";
  static const String image = "image";
  static const String date = "date";
  static const String place = "place";
  static const String link = "link";
}
