// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import '../../presentation/pages/home_page.dart';
import '../../presentation/resources/constatns.dart';
import '../../presentation/resources/values_manager.dart';
import '../../presentation/widgets/common/dialog_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/cubit/profile_cubit/profile_cubit.dart';
import '../../dependency_injection.dart' as di;
import '../../domain/entities/blood_center.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../core/utils.dart';
import '../../presentation/widgets/forms/my_button.dart';

class ProfileCenterPage extends StatefulWidget {
  static const String routeName = "profileCenter";
  const ProfileCenterPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileCenterPage> createState() => _ProfileCenterPageState();
}

class _ProfileCenterPageState extends State<ProfileCenterPage> {
  // ProfileCenterData? profileCenterDataa;

  getProfileCenterData() async {
    di.initSignIn();
    await BlocProvider.of<ProfileCubit>(context).getProfileCenterData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileAppBarTitle),
        elevation: 0,
      ),
      backgroundColor: ColorManager.white,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileGetCenterData) {
              profileCenterData = ProfileCenterData(
                  aPlus: state.bloodCenter.aPlus,
                  aMinus: state.bloodCenter.aMinus,
                  abPlus: state.bloodCenter.abPlus,
                  abMinus: state.bloodCenter.abMinus,
                  oPlus: state.bloodCenter.oPlus,
                  oMinus: state.bloodCenter.oMinus,
                  bPlus: state.bloodCenter.bPlus,
                  bMinus: state.bloodCenter.bMinus);
            } else if (state is ProfileFailure) {
              Utils.showSnackBar(
                context: context,
                msg: state.error,
                color: ColorManager.error,
              );
            } else if (state is ProfileSuccess) {
              Utils.showSnackBar(
                context: context,
                msg: AppStrings.profileSuccesMess,
                color: ColorManager.success,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoadingBeforFetch) {
              return MyLottie(
                lottie: AppStrings.lottieOnHomePage,
              );
            }
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileGetCenterData) {
              profileCenterData = ProfileCenterData(
                  aPlus: state.bloodCenter.aPlus,
                  aMinus: state.bloodCenter.aMinus,
                  abPlus: state.bloodCenter.abPlus,
                  abMinus: state.bloodCenter.abMinus,
                  oPlus: state.bloodCenter.oPlus,
                  oMinus: state.bloodCenter.oMinus,
                  bPlus: state.bloodCenter.bPlus,
                  bMinus: state.bloodCenter.bMinus);

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: AppPadding.p20),
                        child: Text(
                          AppStrings.profileCenterTitle,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(
                        height: AppSize.s10,
                      ),
                      PrfileCenterBloodTypeCard(
                        bloodType: BloodCenterFields.aPlus,
                      ),
                      PrfileCenterBloodTypeCard(
                        bloodType: BloodCenterFields.aMinus,
                      ),
                      PrfileCenterBloodTypeCard(
                          bloodType: BloodCenterFields.abPlus),
                      PrfileCenterBloodTypeCard(
                          bloodType: BloodCenterFields.abMinus),
                      PrfileCenterBloodTypeCard(
                          bloodType: BloodCenterFields.bPlus),
                      PrfileCenterBloodTypeCard(
                          bloodType: BloodCenterFields.bMinus),
                      PrfileCenterBloodTypeCard(
                          bloodType: BloodCenterFields.oPlus),
                      PrfileCenterBloodTypeCard(
                          bloodType: BloodCenterFields.oMinus),
                      const SizedBox(
                        height: AppSize.s20,
                      ),
                      MyButton(
                        title: AppStrings.profileButtonSave,
                        titleStyle: Theme.of(context).textTheme.titleLarge,
                        onPressed: () {
                          BlocProvider.of<ProfileCubit>(context)
                              .sendProfileCenterData(profileCenterData!);
                        },
                        minWidth: AppSize.s300,
                        color: ColorManager.secondary,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: MyLottie(
                  lottie: AppStrings.lottieOnHomePage,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

ProfileCenterData? profileCenterData;

class PrfileCenterBloodTypeCard extends StatefulWidget {
  PrfileCenterBloodTypeCard({Key? key, required this.bloodType})
      : super(key: key);

  String bloodType;

  @override
  State<PrfileCenterBloodTypeCard> createState() =>
      _PrfileCenterBloodTypeCardState();
}

class _PrfileCenterBloodTypeCardState extends State<PrfileCenterBloodTypeCard> {
  TextEditingController _controller = TextEditingController();
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.text = ProfileCenterData.getProfileCenterDataBlodTyeb(
            widget.bloodType, profileCenterData!)
        .toString();
  }

//----------------------------
  int counter = 0;
  bool ontap = false;

  subtract() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      int repoSetory = ProfileCenterData.getProfileCenterDataBlodTyeb(
          widget.bloodType, profileCenterData!);
      if (repoSetory >= 1) {
        --repoSetory;
        ProfileCenterData.IncressProfileCenterDataBlodTyeb(
            widget.bloodType, profileCenterData!, repoSetory);
        _controller.text = repoSetory.toString();
        // BlocProvider.of<ProfileCubit>(context)
        //     .sendProfileCenterData(profileCenterData!);
      }
    });
    if (ontap) {
      subtract();
    }
  }

  addcounter() async {
    await Future.delayed(Duration(milliseconds: 100));

    setState(() {
      int repoSetory = ProfileCenterData.getProfileCenterDataBlodTyeb(
          widget.bloodType, profileCenterData!);
      print(repoSetory);
      print(widget.bloodType);
      print("adddddddddddddddddddddddd");

      ++repoSetory;
      ProfileCenterData.IncressProfileCenterDataBlodTyeb(
          widget.bloodType, profileCenterData!, repoSetory);
      _controller.text = repoSetory.toString();
      // print(widget.profileCenterData.aPlus);
    });
    if (ontap) {
      addcounter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: AppSize.s20,
        ),
        Container(
          color: ColorManager.white,
          child: Wrap(
            children: [
              SizedBox(
                width: AppSize.s65,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: AppSize.s16, right: AppSize.s10),
                  child: Text(
                    "${widget.bloodType}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSize.s24,
                        color: ColorManager.primary),
                  ),
                ),
              ),
              const SizedBox(
                width: AppSize.s30,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSize.s10,
                  left: AppSize.s8,
                ),
                child: SizedBox(
                  width: AppSize.s80,
                  height: AppSize.s35,
                  child: GestureDetector(
                    // onTap: () {
                    //   //  ontap = true;

                    //   addcounter();
                    // },
                    onLongPress: () {
                      ontap = true;
                      addcounter();
                    },
                    onLongPressEnd: (_) {
                      setState(() {
                        ontap = false;
                      });
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        addcounter();
                      },
                      // onLongPress: () {
                      //   setState(() {
                      //     int repoSetory =
                      //         ProfileCenterData.getProfileCenterDataBlodTyeb(
                      //             widget.bloodType, profileCenterData!);
                      //     print(repoSetory);
                      //     print(widget.bloodType);
                      //     print("adddddddddddddddddddddddd");

                      //     ++repoSetory;
                      //     ProfileCenterData.IncressProfileCenterDataBlodTyeb(
                      //         widget.bloodType, profileCenterData!, repoSetory);
                      //     _controller.text = repoSetory.toString();
                      //     // print(widget.profileCenterData.aPlus);
                      //   });
                      // },
                      // onPressed: () {
                      //   setState(() {
                      //     int repoSetory =
                      //         ProfileCenterData.getProfileCenterDataBlodTyeb(
                      //             widget.bloodType, profileCenterData!);
                      //     print(repoSetory);
                      //     print(widget.bloodType);
                      //     print("adddddddddddddddddddddddd");

                      //     ++repoSetory;
                      //     ProfileCenterData.IncressProfileCenterDataBlodTyeb(
                      //         widget.bloodType, profileCenterData!, repoSetory);
                      //     _controller.text = repoSetory.toString();
                      //     // print(widget.profileCenterData.aPlus);
                      //   });
                      // }
                      // ,

                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(ColorManager.primary),
                        elevation: MaterialStateProperty.all(AppSize.s5),
                        shadowColor:
                            MaterialStateProperty.all(ColorManager.primary),
                      ),
                      // icon: Icon(Icons.plus_one)
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, left: 15, right: 10.0),
                child: SizedBox(
                  width: 80,
                  height: 35,
                  child: TextFormField(
                    controller: _controller,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 20),
                    onChanged: (value) {
                      int intValue = int.tryParse(value) ?? 0;
                      print("widget.bloodType");
                      print(widget.bloodType);
                      ProfileCenterData.IncressProfileCenterDataBlodTyeb(
                        widget.bloodType,
                        profileCenterData!,
                        intValue,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSize.s10,
                  right: AppSize.s8,
                ),
                child: SizedBox(
                  width: AppSize.s80,
                  height: AppSize.s35,
                  child: GestureDetector(
                    onLongPress: () {
                      ontap = true;
                      subtract();
                    },
                    onLongPressEnd: (_) {
                      setState(() {
                        ontap = false;
                      });
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        subtract();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(ColorManager.primary),
                        alignment: Alignment.topCenter,
                        elevation: MaterialStateProperty.all(AppSize.s5),
                        shadowColor:
                            MaterialStateProperty.all(ColorManager.primary),
                      ),
                      // icon: Icon(Icons.plus_one)
                      child: const Icon(Icons.minimize),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ProfileCenterData {
  int? aPlus;
  int? aMinus;
  int? bPlus;
  int? bMinus;
  int? abPlus;
  int? abMinus;
  int? oPlus;
  int? oMinus;

  String? name;
  String? phone;
  String? district;
  String? state;
  String? neighborhood;

  ProfileCenterData({
    this.aPlus,
    this.aMinus,
    this.bPlus,
    this.bMinus,
    this.abPlus,
    this.abMinus,
    this.oPlus,
    this.oMinus,
    this.name,
    this.phone,
    this.district,
    this.state,
    this.neighborhood,
  });
  static getProfileCenterDataBlodTyeb(
      String bloodType, ProfileCenterData profileCenterData) {
    switch (bloodType) {
      case BloodCenterFields.aPlus:
        return profileCenterData.aPlus;
      case BloodCenterFields.aMinus:
        return profileCenterData.aMinus;
      case BloodCenterFields.abPlus:
        return profileCenterData.abPlus;
      case BloodCenterFields.abMinus:
        return profileCenterData.abMinus;
      case BloodCenterFields.oPlus:
        return profileCenterData.oPlus;
      case BloodCenterFields.oMinus:
        return profileCenterData.oMinus;
      case BloodCenterFields.bPlus:
        return profileCenterData.bPlus;
      case BloodCenterFields.bMinus:
        return profileCenterData.bMinus;
    }
  }

  static IncressProfileCenterDataBlodTyeb(
      String bloodType, ProfileCenterData profileCenterData, int value) {
    switch (bloodType) {
      case BloodCenterFields.aPlus:
        {
          profileCenterData.aPlus = value;
          return profileCenterData.aPlus;
        }
      case BloodCenterFields.aMinus:
        {
          profileCenterData.aMinus = value;
          return profileCenterData.aMinus;
        }
      case BloodCenterFields.abPlus:
        {
          profileCenterData.abPlus = value;
          return profileCenterData.abPlus;
        }
      case BloodCenterFields.abMinus:
        {
          profileCenterData.abMinus = value;
          return profileCenterData.abMinus;
        }
      case BloodCenterFields.oPlus:
        {
          profileCenterData.oPlus = value;
          return profileCenterData.oPlus;
        }
      case BloodCenterFields.oMinus:
        {
          profileCenterData.oMinus = value;
          return profileCenterData.oMinus;
        }
      case BloodCenterFields.bPlus:
        {
          profileCenterData.bPlus = value;
          return profileCenterData.bPlus;
        }
      case BloodCenterFields.bMinus:
        {
          profileCenterData.bMinus = value;
          return profileCenterData.bMinus;
        }
    }
  }

  // static IncOrDec(
  //     String bloodType, ProfileCenterData profileCenterData, String op) {
  //   print(op);
  //   switch (bloodType) {
  //     case BloodCenterField.aPlus:
  //       {
  //         // checkOperation(op,profileCenterData.aPlus!);
  //         print(checkOperation(op, profileCenterData.aPlus!).toString());
  //         return checkOperation(op, profileCenterData.aPlus!);
  //       }
  //     case BloodCenterField.aMinus:
  //       {
  //         return checkOperation(op, profileCenterData.aMinus!);
  //       }
  //     case BloodCenterField.abPlus:
  //       {
  //         return checkOperation(op, profileCenterData.abPlus!);
  //       }
  //     case BloodCenterField.abMinus:
  //       {
  //         return checkOperation(op, profileCenterData.abMinus!);
  //       }
  //     case BloodCenterField.oPlus:
  //       {
  //         return checkOperation(op, profileCenterData.oPlus!);
  //       }
  //     case BloodCenterField.oMinus:
  //       {
  //         print(checkOperation(op, profileCenterData.oMinus!).toString());
  //         return checkOperation(op, profileCenterData.oMinus!);
  //       }
  //     case BloodCenterField.bPlus:
  //       {
  //         return checkOperation(op, profileCenterData.bPlus!);
  //       }
  //     case BloodCenterField.bMinus:
  //       {
  //         return checkOperation(op, profileCenterData.bMinus!);
  //       }
  //   }
  // }

  // static checkOperation(String bloodType, int value) {
  //   print(value);
  //   print(";;;;;;;;;;;;;;;;;");
  //   switch (bloodType) {
  //     case "plus":
  //       {
  //         print((value + 1).toString());
  //         return (value = value + 1);
  //       }
  //     case "minus":
  //       {
  //         print((value - 1).toString());
  //         return value - 1;
  //       }
  //   }
  // }
}
