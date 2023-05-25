import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../../domain/entities/global_app_data.dart';
import '../../domain/repositories/global_repo.dart';

class GlobalRepoImpl implements GlobalRepo {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _fireStorage = FirebaseStorage.instance;
  final NetworkInfo networkInfo;
  GlobalRepoImpl({
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, GlobalAppData>> getGlobalData() async {
    if (await networkInfo.isConnected) {
      try {
        return _fireStore
            .collection(GlobalAppDataFields.collectionName)
            .get()
            .then((result) async {
          Map<String, dynamic> dataMap = result.docs.first.data();
          List<String> homeSliderImagesPaths =
              (dataMap[GlobalAppDataFields.homeSlides] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
          List<String> homeSliderImagesUrls = [];
          Reference sliderImagesRef = _fireStorage
              .ref()
              .child(GlobalAppDataFields.homeSliderImageFolderName);
          for (var imgPath in homeSliderImagesPaths) {
            String imgUrl =
                await sliderImagesRef.child(imgPath).getDownloadURL();
            homeSliderImagesUrls.add(imgUrl);
          }
          dataMap[GlobalAppDataFields.homeSlides] = homeSliderImagesUrls;
          GlobalAppData? appData = GlobalAppData.fromMap(dataMap);
          return Right(appData);
        });
      } catch (e) {
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }
}
