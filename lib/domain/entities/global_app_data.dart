// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GlobalAppData {
  String appName;
  String aboutApp;
  String homeHeader;
  String infoTitile;
  String reportLink;
  List<String> infoList;
  List<String> homeSlides;

  GlobalAppData({
    required this.appName,
    required this.aboutApp,
    required this.homeHeader,
    required this.infoTitile,
    required this.infoList,
    required this.homeSlides,
    required this.reportLink,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GlobalAppDataFields.appName: appName,
      GlobalAppDataFields.aboutApp: aboutApp,
      GlobalAppDataFields.homeHeader: homeHeader,
      GlobalAppDataFields.infoTitile: infoTitile,
      GlobalAppDataFields.reportLink: reportLink,
      GlobalAppDataFields.infoList: infoList,
      GlobalAppDataFields.homeSlides: homeSlides,
    };
  }

  factory GlobalAppData.fromMap(Map<String, dynamic> map) {
    List<String> newInfoList =
        (map[GlobalAppDataFields.infoList] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
    return GlobalAppData(
      appName: map[GlobalAppDataFields.appName] as String,
      aboutApp: map[GlobalAppDataFields.aboutApp] as String,
      homeHeader: map[GlobalAppDataFields.homeHeader] as String,
      infoTitile: map[GlobalAppDataFields.infoTitile] as String,
      reportLink: map[GlobalAppDataFields.reportLink] as String,
      infoList: newInfoList,
      homeSlides: List<String>.from(
          map[GlobalAppDataFields.homeSlides] as List<String>),
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
  static const String infoList = "info_list";
  static const String homeSlides = "home_slides";
  static const String reportLink = "report_link";
}
