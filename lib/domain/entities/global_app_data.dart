import 'dart:convert';

import 'event_card_data.dart';

class GlobalAppData {
  String appName;
  String aboutApp;
  String homeHeader;
  String infoTitle;
  String eventsTitle;
  String reportLink;
  List<String> infoList;
  List<String> homeSlides;
  List<EventCardData> eventsCardsData;

  GlobalAppData({
    required this.appName,
    required this.aboutApp,
    required this.homeHeader,
    required this.infoTitle,
    required this.eventsTitle,
    required this.reportLink,
    required this.infoList,
    required this.homeSlides,
    required this.eventsCardsData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GlobalAppDataFields.appName: appName,
      GlobalAppDataFields.aboutApp: aboutApp,
      GlobalAppDataFields.homeHeader: homeHeader,
      GlobalAppDataFields.infoTitile: infoTitle,
      GlobalAppDataFields.eventsTitile: eventsTitle,
      GlobalAppDataFields.reportLink: reportLink,
      GlobalAppDataFields.infoList: infoList,
      GlobalAppDataFields.homeSlides: homeSlides,
      GlobalAppDataFields.eventsCardsData: eventsCardsData,
    };
  }

  factory GlobalAppData.fromMap(Map<String, dynamic> map) {
    List<String> newInfoList =
        (jsonDecode(map[GlobalAppDataFields.infoList] ?? '[]') as List<dynamic>)
            .map((e) => e.toString())
            .toList();

    List<String> homeSileds =
        List<String>.from(map[GlobalAppDataFields.homeSlides] as List<String>);

    List<EventCardData> eventCardsData =
        (jsonDecode(map[GlobalAppDataFields.eventsCardsData] ?? "[]") as List)
            .map((cardMap) => EventCardData.fromMap(cardMap))
            .toList();
    return GlobalAppData(
      appName: map[GlobalAppDataFields.appName]?.toString() ?? "",
      aboutApp: map[GlobalAppDataFields.aboutApp]?.toString() ?? "",
      homeHeader: map[GlobalAppDataFields.homeHeader]?.toString() ?? "",
      infoTitle: map[GlobalAppDataFields.infoTitile]?.toString() ?? "",
      eventsTitle: map[GlobalAppDataFields.eventsTitile]?.toString() ?? "",
      reportLink: map[GlobalAppDataFields.reportLink]?.toString() ?? "",
      infoList: newInfoList,
      homeSlides: homeSileds,
      eventsCardsData: eventCardsData,
    );
  }

  String toJson() => json.encode(toMap());

  factory GlobalAppData.fromJson(String source) =>
      GlobalAppData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GlobalAppDataFields {
  static const String collectionName = "global_app_data";
  static const String homeSliderImageFolderName = "home_slider_images";
  static const String appName = "app_name";
  static const String aboutApp = "about_app";
  static const String homeHeader = "home_header";
  static const String infoTitile = "info_titile";
  static const String eventsTitile = "events_title";
  static const String reportLink = "report_link";
  static const String infoList = "info_list";
  static const String homeSlides = "home_slides";
  static const String eventsCardsData = "events_cards_data";
}
