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
          GlobalAppData? appData = GlobalAppData.fromMap(dataMap);

          // set slides images url form firebase storage
          Reference sliderImagesRef = _fireStorage
              .ref()
              .child(GlobalAppDataFields.homeSliderImagesFolderName);
          List<String> slidesImagesUrls = [];
          for (var slideImage in appData.homeSlides) {
            slideImage =
                await sliderImagesRef.child(slideImage).getDownloadURL();
            slidesImagesUrls.add(slideImage);
          }
          appData.homeSlides = slidesImagesUrls;

          // set events images url from firebase storage
          Reference eventsImagesRef = _fireStorage
              .ref()
              .child(GlobalAppDataFields.eventsImagesFolderName);
          for (var event in appData.eventsCardsData) {
            event.image =
                await eventsImagesRef.child(event.image).getDownloadURL();
          }
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
