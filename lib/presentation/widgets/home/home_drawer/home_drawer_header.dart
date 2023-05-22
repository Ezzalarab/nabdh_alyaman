import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../presentation/resources/font_manager.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/color_manageer.dart';
import '../../../resources/strings_manager.dart';
import '../../../resources/values_manager.dart';

class HomeDrawerHeader extends StatelessWidget {
  const HomeDrawerHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: ColorManager.primary,
      ),
      child: InkWell(
        onTap: () async {},
        child: Center(
          child: Wrap(
            direction: Axis.vertical,
            runSpacing: AppSize.s10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const SizedBox(width: AppSize.s10),
              Container(
                height: AppSize.s60,
                width: AppSize.s60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.r50),
                  color: ColorManager.primary,
                ),
                child: Center(
                    child: Image.asset(
                  ImageAssets.appLogo,
                  color: ColorManager.white,
                )),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  AppStrings.homeDrawerHeaderAppName,
                  style: TextStyle(
                      color: ColorManager.white,
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
