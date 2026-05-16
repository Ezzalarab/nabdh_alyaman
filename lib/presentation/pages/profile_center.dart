import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/models/center_profile_form.dart';
import '../blocs/center/center_bloc.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/resources/color_manageer.dart';
import '../../presentation/resources/strings_manager.dart';
import '../../presentation/resources/values_manager.dart';
import '../../presentation/widgets/forms/my_button.dart';
import '../widgets/common/loading_widget.dart';

class ProfileCenterPage extends StatefulWidget {
  static const String routeName = "profileCenter";
  const ProfileCenterPage({super.key});

  @override
  State<ProfileCenterPage> createState() => _ProfileCenterPageState();
}

class _ProfileCenterPageState extends State<ProfileCenterPage> {
  Map<String, int> _stockBaseline = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CenterBloc>().add(CenterProfileLoadRequested());
    });
  }

  Future<String?> _askStockReason() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب التعديل (اختياري)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'مثال: تبرع جماعي'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileAppBarTitle),
        elevation: 0,
      ),
      backgroundColor: ColorManager.white,
      body: BlocConsumer<CenterBloc, CenterState>(
        listener: (context, state) {
          if (state is CenterProfileLoaded) {
            profileCenterData = ProfileCenterData.fromBloodCenter(state.center);
            _stockBaseline = Map<String, int>.from(state.stockBaseline);
          } else if (state is CenterFailure) {
            Utils.showSnackBar(
              context: context,
              msg: state.message,
              color: ColorManager.error,
            );
          } else if (state is CenterSuccess) {
            Utils.showSnackBar(
              context: context,
              msg: state.message ?? AppStrings.profileSuccesMess,
              color: ColorManager.success,
            );
            if (state.message == null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is CenterLoadingBeforeFetch) {
            return const Center(child: LoadingWidget());
          }
          if (state is CenterLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is CenterProfileLoaded) {
            profileCenterData = ProfileCenterData.fromBloodCenter(state.center);
            _stockBaseline = Map<String, int>.from(state.stockBaseline);

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
                    const SizedBox(height: AppSize.s10),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.aPlus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.aMinus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.abPlus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.abMinus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.bPlus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.bMinus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.oPlus,
                    ),
                    PrfileCenterBloodTypeCard(
                      bloodType: BloodCenterFields.oMinus,
                    ),
                    const SizedBox(height: AppSize.s20),
                    MyButton(
                      title: AppStrings.profileButtonSave,
                      titleStyle: Theme.of(context).textTheme.titleLarge,
                      onPressed: () async {
                        if (profileCenterData == null) return;
                        final reason = await _askStockReason();
                        if (!context.mounted || reason == null) return;
                        context.read<CenterBloc>().add(
                              CenterStockSaveSubmitted(
                                current: profileCenterData!,
                                baseline: _stockBaseline,
                                reason: reason,
                              ),
                            );
                      },
                      minWidth: AppSize.s300,
                      color: ColorManager.secondary,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('خطأ غير معروف'));
          }
        },
      ),
    );
  }
}

ProfileCenterData? profileCenterData;

// ignore: must_be_immutable
class PrfileCenterBloodTypeCard extends StatefulWidget {
  PrfileCenterBloodTypeCard({super.key, required this.bloodType});

  String bloodType;

  @override
  State<PrfileCenterBloodTypeCard> createState() =>
      _PrfileCenterBloodTypeCardState();
}

class _PrfileCenterBloodTypeCardState extends State<PrfileCenterBloodTypeCard> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller.text = ProfileCenterData.getProfileCenterDataBlodTyeb(
      widget.bloodType,
      profileCenterData!,
    ).toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //----------------------------
  int counter = 0;
  bool ontap = false;

  Future<void> subtract() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      int? repoSetory =
          ProfileCenterData.getProfileCenterDataBlodTyeb(
            widget.bloodType,
            profileCenterData!,
          ) ??
          0;
      if (repoSetory >= 1) {
        --repoSetory;
        ProfileCenterData.incressProfileCenterDataBlodTyeb(
          widget.bloodType,
          profileCenterData!,
          repoSetory,
        );
        _controller.text = repoSetory.toString();
        // BlocProvider.of<ProfileCubit>(context)
        //     .sendProfileCenterData(profileCenterData!);
      }
    });
    if (ontap) {
      subtract();
    }
  }

  Future<void> addcounter() async {
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      int repoSetory =
          ProfileCenterData.getProfileCenterDataBlodTyeb(
            widget.bloodType,
            profileCenterData!,
          ) ??
          0;
      // print(repoSetory);
      // print(widget.bloodType);
      // print("adddddddddddddddddddddddd");

      ++repoSetory;
      ProfileCenterData.incressProfileCenterDataBlodTyeb(
        widget.bloodType,
        profileCenterData!,
        repoSetory,
      );
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
        const SizedBox(height: AppSize.s20),
        Container(
          color: ColorManager.white,
          child: Wrap(
            children: [
              SizedBox(
                width: AppSize.s65,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSize.s16,
                    right: AppSize.s10,
                  ),
                  child: Text(
                    widget.bloodType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize.s24,
                      color: ColorManager.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.s30),
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
                        backgroundColor: WidgetStateProperty.all(
                          ColorManager.primary,
                        ),
                        elevation: WidgetStateProperty.all(AppSize.s5),
                        shadowColor: WidgetStateProperty.all(
                          ColorManager.primary,
                        ),
                      ),
                      // icon: Icon(Icons.plus_one)
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  left: 15,
                  right: 10.0,
                ),
                child: SizedBox(
                  width: 80,
                  height: 35,
                  child: TextFormField(
                    controller: _controller,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20),
                    onChanged: (value) {
                      int intValue = int.tryParse(value) ?? 0;
                      if (kDebugMode) {
                        print("widget.bloodType");
                        print(widget.bloodType);
                      }
                      ProfileCenterData.incressProfileCenterDataBlodTyeb(
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
                        backgroundColor: WidgetStateProperty.all(
                          ColorManager.primary,
                        ),
                        alignment: Alignment.topCenter,
                        elevation: WidgetStateProperty.all(AppSize.s5),
                        shadowColor: WidgetStateProperty.all(
                          ColorManager.primary,
                        ),
                      ),
                      // icon: Icon(Icons.plus_one)
                      child: const Icon(Icons.minimize),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
