import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart' as info;
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class Updating {
  bool flagUpdata = false, errorFlage = true;
  String? oldVersion, newVersion, errorMessage, errorDegree;

  Future getVersion() async {
    info.PackageInfo? packageInfo = await info.PackageInfo.fromPlatform();
    version = packageInfo.version;
    oldVersion = version.toString();
    try {
      FirebaseFirestore.instance
          .collection("updating")
          .snapshots()
          .listen((event) {
        // print(event.docs.first);
        if (event.docs.isNotEmpty) {
          newVersion = event.docs[0].data()['new_version'];
          errorMessage = event.docs[0].data()['message'];
          errorDegree = event.docs[0].data()['waring_degree'];
          print("check update");
          print("old");
          print(oldVersion);
          print("new");
          print(newVersion);
          if (errorDegree == "1") {
            errorFlage = false;
          } else if (errorDegree == "0") {
            errorFlage = true;
          }
          if (newVersion == oldVersion) {
            flagUpdata = false;
          } else {
            flagUpdata = true;
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future showAlertUpdating(BuildContext context) async {
    AwesomeDialog(
      context: context,
      dismissOnBackKeyPress: errorFlage,
      dismissOnTouchOutside: errorFlage,
      dialogType: errorFlage ? DialogType.warning : DialogType.error,
      borderSide: const BorderSide(color: Colors.green, width: 2),
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
      headerAnimationLoop: false,
      showCloseIcon: errorFlage,
      animType: AnimType.bottomSlide,
      // title: "يتوفر اصدار حديد",
      // desc: await errorMessage,
      body: Column(
        children: [
          const Center(
            child: Text(
              "يتوفر اصدار جديد",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(errorMessage!),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              child: const Text("تحديث"),
              onPressed: () {
                launchAppStore();
              },
            ),
          ),
        ],
      ),
      descTextStyle: const TextStyle(),
    ).show();
  }

  void launchAppStore() async {
    var appStoreURL =
        "https://play.google.com/store/apps/details?id=d.threedevils.devicey";
    if (await canLaunchUrl(Uri.parse(appStoreURL))) {
      await launchUrl(Uri.parse(appStoreURL));
    }
  }
}
