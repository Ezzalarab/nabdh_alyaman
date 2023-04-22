// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class DonerCardBody extends StatelessWidget {
  final String phone;
  DonerCardBody({
    Key? key,
    required this.phone,
  }) : super(key: key);
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: phone,
              );
              await launcher.launch(
                launchUri.toString(),
                useSafariVC: false,
                useWebView: false,
                enableJavaScript: false,
                enableDomStorage: false,
                universalLinksOnly: true,
                headers: <String, String>{},
              );
            },
            child: Container(
              height: 50,
              width: 120,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          Container(
            height: 50,
            width: 120,
            decoration: const BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
            ),
            child: const Icon(
              Icons.message,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
