import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils.dart';
import '../../domain/entities/donor.dart';
import '../cubit/profile_cubit/profile_cubit.dart';
import '../resources/color_manageer.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/setting/profile_body.dart';

// Table name data user in hive database
const String dataBoxName = "dataProfile";

class SettingPage extends StatefulWidget {
  static const String routeName = "setting";
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // File? _image;
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

  // Future _pickImage(ImageSource source) async {
  //   try {
  //     final image = await ImagePicker().pickImage(source: source);
  //     if (image == null) return;
  //     File? img = File(image.path);
  //     // img = await _cropImage(imageFile: img);
  //     setState(() {
  //       _image = img;
  //       if (kDebugMode) {
  //         print(_image?.path);
  //       }
  //       Navigator.of(context).pop();
  //     });
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //     Navigator.of(context).pop();
  //   }
  // }

  // Future<File?> _cropImage({required File imageFile}) async {
  //   CroppedFile? croppedImage =
  //       await ImageCropper().cropImage(sourcePath: imageFile.path);
  //   if (croppedImage == null) return null;
  //   return File(croppedImage.path);
  // }

  // void _showSelectPhotoOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(25.0),
  //       ),
  //     ),
  //     builder: (context) => DraggableScrollableSheet(
  //         initialChildSize: 0.28,
  //         maxChildSize: 0.4,
  //         minChildSize: 0.28,
  //         expand: false,
  //         builder: (context, scrollController) {
  //           return SingleChildScrollView(
  //             controller: scrollController,
  //             child: SelectPhotoOptionsScreen(
  //               onTap: _pickImage,
  //             ),
  //           );
  //         }),
  //   );
  // }

  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    // getData();
    getPermission();
  }

  Future<void> getPermission() async {
    _permissionStatus = await Permission.storage.status;
    if (_permissionStatus != PermissionStatus.granted) {
      PermissionStatus permissionStatus = await Permission.storage.request();
      setState(() {
        _permissionStatus = permissionStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileAppBarTitle),
        elevation: 0,
      ),
      backgroundColor: ColorManager.white,
      body:
          BlocConsumer<ProfileCubit, ProfileState>(listener: (context, state) {
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
            color: ColorManager.success,
          );
        }
      }, builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: (state is ProfileLoading),
          progressIndicator: const LoadingWidget(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: AppPadding.p10),
                ),
                // GestureDetector(
                //   onTap: () {
                //     _showSelectPhotoOptions(context);
                //   },
                //   child: DisplayImage(
                //     imagePath: _image ?? ImageAssets.profileImage,
                //     onPressed: () {},
                //   ),
                // ),
                const SizedBox(
                  height: AppSize.s10,
                ),
                if (state is ProfileGetData) ProfileBody(donor: state.donors),
                if (state is ProfileFailure)
                  const Center(
                    child: Text('خطأ غير معروف'),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
