import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../presentation/resources/font_manager.dart';
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
            runSpacing: AppSize.s10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const SizedBox(width: AppSize.s10),
              Container(
                height: AppSize.s100,
                width: AppSize.s100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.r50),
                  color: ColorManager.white,
                ),
                child: const Center(
                    child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/nabdh square.png"),
                  radius: 80,
                )),
              ),
              const SizedBox(width: AppSize.s20),
              Wrap(
                children: [
                  Text(
                    (currentUser != null)
                        ? currentUser.email ?? currentUser.phoneNumber!
                        : AppStrings.homeDrawerHeaderAppName,
                    style: const TextStyle(
                        color: ColorManager.white,
                        fontFamily: FontConstants.fontFamily,
                        fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
