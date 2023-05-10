import '../../presentation/resources/constatns.dart';
import '../../presentation/widgets/common/dialog_lottie.dart';

import '../cubit/profile_cubit/profile_cubit.dart';
import '../resources/assets_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../domain/entities/donor.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../resources/color_manageer.dart';
import '../../core/utils.dart';
import '../widgets/setting/select_photo_options_screen.dart';
import '../widgets/setting/profile_body.dart';
import '../widgets/setting/display_image.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

// Table name data user in hive database
const String dataBoxName = "dataProfile";

class SettingPage extends StatefulWidget {
  static const String routeName = "setting";
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _image;
  Donor? donor, donors;
  Box? dataBox;
  bool? checkErrorFromSata;

  // Future<void> putDataTodataProfileTable() async {
  //   // var box = await Hive.openBox(dataBoxName);

  //   dataBox = Hive.box(dataBoxName);

  //   try {
  //     User? currentUser = _auth.currentUser;
  //     if (currentUser != null) {
  //       await _fireStore
  //           .collection('donors')
  //           .doc("H5PPBI8VBBNikBYvmifb")
  //           .get()
  //           .then((value) async {
  //         donor = Donor.fromMap(value.data()!);
  //         await dataBox!.add(donor!);
  //         // print(dataBox!.get("data_profile"));
  //       });
  //     } else {
  //       print("error 1");
  //     }
  //   } catch (e) {
  //     print("error 2");
  //   }
  // }

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        print(_image);
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    // getData();
    () async {
      _permissionStatus = await Permission.storage.status;

      if (_permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          _permissionStatus = permissionStatus;
        });
      }
    }();
  }

  void permission() async {
    if (_permissionStatus != PermissionStatus.granted) {
      if (await Permission.storage.request().isDenied) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(donors);
    // print(FirebaseAuth.instance.currentUser!.uid);
    permission();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileAppBarTitle),
        elevation: 0,
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: textScaleFactor),
        child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
          if (state is ProfileGetData) {
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
            );
          }
        }, builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: (state is ProfileLoading),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppPadding.p10),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showSelectPhotoOptions(context);
                    },
                    child: DisplayImage(
                      imagePath: _image ?? ImageAssets.ProfileImage,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(
                    height: AppSize.s10,
                  ),
                  if (state is ProfileGetData) ProfileBody(donor: state.donors),
                  if (state is ProfileFailure)
                    Center(
                      child: MyLottie(
                        lottie: AppStrings.lottieOnHomePage,
                      ),
                    ),

                  // (state is ProfileGetData)
                  //     ? ProfileBody(donor: state.donors)
                  //     : const Center(
                  //         child: CircularProgressIndicator(),
                  //       )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
