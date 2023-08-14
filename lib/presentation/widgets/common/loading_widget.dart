import 'package:flutter/material.dart';

import '../../resources/assets_manager.dart';
import 'dialog_lottie.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(
        child: MyLottie(lottie: JsonAssets.bloodDrop),
      ),
    );
  }
}
