import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/donor.dart';
import '../../cubit/profile_cubit/profile_cubit.dart';
import '../../pages/edit_main_data_page.dart';
import '../../resources/color_manageer.dart';
import '../../resources/style.dart';
import '../../../core/utils.dart';
import '../forms/my_button.dart';
import '../forms/my_switchlist_tile.dart';
import '../forms/my_text_form_field.dart';

class ProfileBody extends StatefulWidget {
  ProfileBody({
    Key? key,
    required this.donor,
  }) : super(key: key);
  Donor? donor;
  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  DateTime? newDate;
  String? selectedGender;
  ProfileLocalData? profileLocalData;
  Future<String> showDateTimePicker(context) async {
    final DateTime initDateTime = DateTime.now();
    newDate = await showDatePicker(
      context: context,
      initialDate: initDateTime,
      firstDate: DateTime(1900),
      lastDate: initDateTime,
    ).then((value) => newDate = value);
    if (newDate == null) return AppStrings.profileNullValue;
    // final pickedDateTime = DateTime(
    //   newDate.year,
    //   newDate.month,
    //   newDate.day,
    // );
    // setDateTime(pickedDateTime);
    // setDateController(formatOnlyDate(pickedDateTime));
    return newDate.toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.donor == null) {}
    fillProfileLocalData();
    // BlocProvider.of<ProfileCubit>(context).getDataToProfilePage();
  }

  fillProfileLocalData() {
    profileLocalData = ProfileLocalData(
        date: widget.donor!.brithDate,
        isShown: widget.donor!.isShown,
        isGpsOn: widget.donor!.isGpsOn,
        isShownPhone: widget.donor!.isShownPhone);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      const SizedBox(
        height: 10,
      ),
      EditBasicData(),
      valueListenableBuilder(widget.donor!),
    ]));
  }

  valueListenableBuilder(Donor donor) {
    return Column(
      children: [
        MySwitchListTile(
          title: AppStrings.profileSwitchSubTitle1,
          subTitle: "",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontSize: AppSize.s16),
          onChange: (val) {
            setState(() {
              profileLocalData!.isShown = val == true ? "1" : "0";
            });
          },
          onchangValue: (profileLocalData!.isShown == "1") ? true : false,
        ),
        // MySwitchListTile(
        //   title: AppStrings.profileSwitchListTile2,
        //   subTitle: AppStrings.profileSwitchSubTitle2,
        //   onChange: (val) {
        //     setState(() {
        //       profileLocalData!.isShownPhone = val == true ? "1" : "0";
        //     });
        //   },
        //   onchangValue: (profileLocalData!.isShownPhone == "1") ? true : false,
        // ),
        MySwitchListTile(
          title: AppStrings.profileSwitchSubTitle3,
          subTitle: "",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontSize: AppSize.s16),
          onChange: (val) {
            setState(() {
              profileLocalData!.isGpsOn = val == true ? "1" : "0";
            });
          },
          onchangValue: (profileLocalData!.isGpsOn == "1") ? true : false,
        ),
        const SizedBox(height: AppSize.s24),
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p30, vertical: AppPadding.p10),
            child: Column(
              children: [
                MyTextFormField(
                  hint: AppStrings.profileDataBrithday,
                  hintStyle: Theme.of(context).textTheme.bodyText1!,
                  suffixIcon: true,
                  blurrBorderColor: ColorManager.grey,
                  focusBorderColor: eSecondColor,
                  icon: const Icon(
                    Icons.calendar_month,
                    color: eSecondColor,
                  ),
                  readOnly: true,
                  onTap: () {
                    showDateTimePicker(context).then((value) {
                      if (value != "") {
                        profileLocalData!.date = value;
                      }
                    });
                  },
                ),
              ],
            )),
        MyButton(
            title: AppStrings.profileButtonSave,
            color: Theme.of(context).primaryColor,
            titleStyle: Theme.of(context).textTheme.titleLarge,
            minWidth: MediaQuery.of(context).size.width * 0.85,
            onPressed: (() {
              if (profileLocalData != null) {
                BlocProvider.of<ProfileCubit>(context)
                    .sendDataProfileSectionOne(profileLocalData!);
              } else {
                Utils.showSnackBar(
                  context: context,
                  msg: AppStrings.profileSuccesMess,
                  color: ColorManager.error,
                );
              }
            }))
      ],
    );
  }
}

class EditBasicData extends StatelessWidget {
  EditBasicData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.keyboard_arrow_left,
          size: AppSize.s30,
        ),
      ),
      title: Text(
        AppStrings.profileEditMainDataPageTitle,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () {
        // di.initProfile();
        BlocProvider.of<ProfileCubit>(context).getDataToProfilePage();

        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => EditMainDataPage()));
      },
    );
  }
}

class ProfileLocalData {
  String? isShown;
  String? date;
  String? isGpsOn;
  String? isShownPhone;
  String? name;
  String? bloodType;
  String? district;
  String? state;
  String? neighborhood;

  ProfileLocalData(
      {this.name,
      this.bloodType,
      this.district,
      this.neighborhood,
      this.state,
      this.isShown,
      this.date,
      this.isGpsOn,
      this.isShownPhone});
}
