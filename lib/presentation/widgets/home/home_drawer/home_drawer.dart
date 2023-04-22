import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../presentation/pages/setting_page.dart';
import '../../../../presentation/widgets/home/home_drawer/home_drawer_center_body.dart';
import '../../../../presentation/widgets/home/home_drawer/home_drawer_donor_body.dart';
import 'home_drawer_header.dart';
import 'home_drower_body.dart';

class HomeDrower extends StatefulWidget {
  const HomeDrower({Key? key}) : super(key: key);

  @override
  State<HomeDrower> createState() => _HomeDrowerState();
}

class _HomeDrowerState extends State<HomeDrower> {
  String userType = "0";
  @override
  void initState() {
    setState(() => userType = Hive.box(dataBoxName).get('user') ?? "0");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(userType);
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const HomeDrawerHeader(),
            userType == "1"
                ? const HomeDrawerDonorBody()
                : userType == "2"
                    ? const HomeDrawerCenterBody()
                    : const HomeDrawerBody(),
          ],
        ),
      ),
    );
  }
}
