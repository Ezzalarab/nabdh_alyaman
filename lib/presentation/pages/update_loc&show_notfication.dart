import '../../domain/entities/donor.dart';
import '../../domain/entities/get_notfication.dart';
import '../../domain/entities/notfication_data.dart';
import '../../core/methode/shared_method.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/constatns.dart';
import '../../presentation/resources/values_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class UpdateLocNotFicationPage extends StatefulWidget {
  UpdateLocNotFicationPage(
      {required this.remoteMessage, required this.dateTime, super.key});
  RemoteNotification remoteMessage;
  DateTime dateTime;
  static const String routeName = "notfication_page";

  @override
  State<UpdateLocNotFicationPage> createState() =>
      _UpdateLocNotFicationPageState();
}

class _UpdateLocNotFicationPageState extends State<UpdateLocNotFicationPage> {
  late Position position;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  getLocation() async {
    print(";;;;;;;;");
    await SharedMethod().checkGps();
    position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      print("value.latitude");
      print(value.latitude);
      print(value.longitude);
      Fluttertoast.showToast(msg: widget.remoteMessage.body.toString());
      return value;
    });
    if (_firebaseAuth.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({
        DonorFields.lat: position.latitude.toString(),
        DonorFields.lon: position.longitude.toString()
      }).then((value) async {
        print("okkkkkkkkkkkkkkkkkkkkkkkk");
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    // final RemoteNotification remoteMessager =
    //     ModalRoute.of(context)?.settings.arguments as RemoteNotification;

    // print(widget.remoteMessage!.title);
    // print(FirebaseMessaging.instance.getToken().then(
    //       (value) => print(value),
    //     ));

    return Scaffold(
        appBar: AppBar(
          title: const Text("الاشعارات"),
        ),
        backgroundColor: ColorManager.grey1,
        body: AnimationLimiter(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 50),
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                delay: const Duration(milliseconds: 100),
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.fastLinearToSlowEaseIn,
                  horizontalOffset: -20,
                  verticalOffset: -100,
                  child: Column(
                    children: [
                      // const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Stack(
                          children: [
                            Container(
                              height: 160,
                              decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius:
                                      BorderRadius.circular(AppSize.s20)),
                            ),
                            Positioned(
                                top: 50,
                                right: 10,
                                child: Image.asset(
                                  "assets/images/boy.png",
                                  height: 80,
                                  width: 100,
                                )),
                            Positioned(
                                top: 20,
                                left: 70,
                                child: Text(
                                    "${widget.dateTime.toString().substring(0, 10)}")),
                            Positioned(
                                bottom: 80,
                                right: 130,
                                child: Text(
                                  "${widget.remoteMessage.title}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                            Positioned(
                                bottom: 50,
                                right: 130,
                                child: Text("${widget.remoteMessage.body}")),
                            Positioned(
                                top: 20, right: 60, child: Text("تاريخ ")),
                            Positioned(
                                top: 5,
                                left: 0,
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.close),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
