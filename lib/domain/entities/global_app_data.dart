import 'dart:convert';

import 'news_card_data.dart';

class GlobalAppData {
  String appName;
  String aboutApp;
  String homeHeader;
  String infoTitle;
  String newsTitle;
  String reportLink;
  List<String> infoList;
  List<String> homeSlides;
  List<NewsCardData> newsCardsData;

  GlobalAppData({
    required this.appName,
    required this.aboutApp,
    required this.homeHeader,
    required this.infoTitle,
    required this.newsTitle,
    required this.reportLink,
    required this.infoList,
    required this.homeSlides,
    required this.newsCardsData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GlobalAppDataFields.appName: appName,
      GlobalAppDataFields.aboutApp: aboutApp,
      GlobalAppDataFields.homeHeader: homeHeader,
      GlobalAppDataFields.infoTitile: infoTitle,
      GlobalAppDataFields.newsTitile: newsTitle,
      GlobalAppDataFields.reportLink: reportLink,
      GlobalAppDataFields.infoList: infoList,
      GlobalAppDataFields.homeSlides: homeSlides,
      GlobalAppDataFields.newsCardsData: newsCardsData,
    };
  }

  factory GlobalAppData.fromMap(Map<String, dynamic> map) {
    List<String> newInfoList =
        (jsonDecode(map[GlobalAppDataFields.infoList] ?? '[]') as List<dynamic>)
            .map((e) => e.toString())
            .toList();

    List<String> homeSileds =
        List<String>.from(map[GlobalAppDataFields.homeSlides] as List<String>);

    List<NewsCardData> newsCardsData =
        (jsonDecode(map[GlobalAppDataFields.newsCardsData] ?? "[]") as List)
            .map((cardMap) => NewsCardData.fromMap(cardMap))
            .toList();
    return GlobalAppData(
      appName: map[GlobalAppDataFields.appName]?.toString() ?? "",
      aboutApp: map[GlobalAppDataFields.aboutApp]?.toString() ?? "",
      homeHeader: map[GlobalAppDataFields.homeHeader]?.toString() ?? "",
      infoTitle: map[GlobalAppDataFields.infoTitile]?.toString() ?? "",
      newsTitle: map[GlobalAppDataFields.newsTitile]?.toString() ?? "",
      reportLink: map[GlobalAppDataFields.reportLink]?.toString() ?? "",
      infoList: newInfoList,
      homeSlides: homeSileds,
      newsCardsData: newsCardsData,
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
  static const String newsTitile = "news_title";
  static const String reportLink = "report_link";
  static const String infoList = "info_list";
  static const String homeSlides = "home_slides";
  static const String newsCardsData = "news_cards_data";
}
