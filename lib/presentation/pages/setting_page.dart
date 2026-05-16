import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/files/file_url_resolver.dart';
import '../../core/utils.dart';
import '../../di.dart' as di;
import '../blocs/profile/profile_bloc.dart';
import '../resources/color_manageer.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/setting/display_image.dart';
import '../widgets/setting/profile_body.dart';
import '../widgets/setting/select_photo_options_screen.dart';

class SettingPage extends StatefulWidget {
  static const String routeName = "setting";
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _pickedImage;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
    getPermission();
  }

  Future<void> getPermission() async {
    _permissionStatus = await Permission.storage.status;
    if (_permissionStatus != PermissionStatus.granted) {
      final permissionStatus = await Permission.storage.request();
      if (mounted) {
        setState(() => _permissionStatus = permissionStatus);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final file = File(image.path);
      if (!mounted) return;
      setState(() => _pickedImage = file);
      Navigator.of(context).pop();
      context.read<ProfileBloc>().add(ProfileImageUploadRequested(file));
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.28,
        maxChildSize: 0.4,
        minChildSize: 0.28,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SelectPhotoOptionsScreen(onTap: _pickImage),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolver = di.gi<FileUrlResolver>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileAppBarTitle),
        elevation: 0,
      ),
      backgroundColor: ColorManager.white,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
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
          } else if (state is ProfileGetData && _pickedImage != null) {
            setState(() => _pickedImage = null);
          }
        },
        builder: (context, state) {
          final donor = state is ProfileGetData ? state.donors : null;
          final imageUrl = donor != null &&
                  donor.image != null &&
                  donor.image!.isNotEmpty
              ? resolver.resolve(donor.image)
              : null;
          return ModalProgressHUD(
            inAsyncCall: state is ProfileLoading,
            progressIndicator: const LoadingWidget(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: AppPadding.p10)),
                  GestureDetector(
                    onTap: () => _showSelectPhotoOptions(context),
                    child: DisplayImage(
                      imageFile: _pickedImage,
                      imageUrl: imageUrl,
                      onPressed: () => _showSelectPhotoOptions(context),
                    ),
                  ),
                  const SizedBox(height: AppSize.s10),
                  if (state is ProfileGetData) ProfileBody(donor: state.donors),
                  if (state is ProfileFailure)
                    const Center(child: Text('خطأ غير معروف')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
