import 'package:flutter/cupertino.dart';

import '../../resources/assets_manager.dart';

class MyLottie extends StatefulWidget {
  const MyLottie({required this.lottie, super.key});
  final String lottie;

  @override
  State<MyLottie> createState() => _MyLottieState();
}

class _MyLottieState extends State<MyLottie> with TickerProviderStateMixin {
  // late AnimationController _controller;
  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(vsync: this);
  //   _controller.addListener(() {
  //     print(_controller.value);
  //     if (_controller.value > 0.5) {
  //       _controller.value = 0.5;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: SizedBox(
        height: 100,
        width: 100,
        child: Image.asset(ImageAssets.appLogo),
      )
          //  Lottie.asset(
          //   widget.lottie,
          //   repeat: true,
          //   reverse: true,
          //   animate: true,
          // ),
          ),
    );
  }
}
