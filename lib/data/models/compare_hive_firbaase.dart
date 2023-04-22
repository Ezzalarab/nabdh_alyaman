import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/donor.dart';
import '../../presentation/pages/setting_page.dart';

class CompareHiveAndFireStore {
  void compareHiveAndFirestore() async {
    Donor donor;
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        await fireStore
            .collection(DonorFields.collectionName)
            .doc(currentUser.uid)
            .get()
            .then((value) async {
          donor = Donor.fromMap(value.data()!);

          if (Hive.box(dataBoxName) != null) {
            if (kDebugMode) {
              print("22222222222222222222222222222");
            }
            if (Hive.box(dataBoxName).get(DonorFields.name) != donor.name &&
                Hive.box(dataBoxName).get(DonorFields.bloodType) !=
                    donor.bloodType &&
                donor.isShown !=
                    Hive.box(dataBoxName).get(DonorFields.isShown) &&
                donor.isGpsOn !=
                    Hive.box(dataBoxName).get(DonorFields.isGpsOn) &&
                donor.isShownPhone !=
                    Hive.box(dataBoxName).get(DonorFields.isShownPhone) &&
                Hive.box(dataBoxName).get("date") != donor.brithDate &&
                donor.district !=
                    Hive.box(dataBoxName).get(DonorFields.district) &&
                donor.state != Hive.box(dataBoxName).get(DonorFields.state) &&
                donor.neighborhood !=
                    Hive.box(dataBoxName).get(DonorFields.neighborhood)) {
              await fireStore
                  .collection(DonorFields.collectionName)
                  .doc(currentUser.uid)
                  .update({
                DonorFields.state: Hive.box(dataBoxName).get(DonorFields.state),
                DonorFields.neighborhood:
                    Hive.box(dataBoxName).get(DonorFields.neighborhood),
                DonorFields.district:
                    Hive.box(dataBoxName).get(DonorFields.district),
                DonorFields.name: Hive.box(dataBoxName).get(DonorFields.name),
                DonorFields.bloodType:
                    Hive.box(dataBoxName).get(DonorFields.bloodType),
                DonorFields.isShown:
                    Hive.box(dataBoxName).get(DonorFields.isShown),
                DonorFields.isShownPhone:
                    Hive.box(dataBoxName).get(DonorFields.isShownPhone),
                DonorFields.isGpsOn:
                    Hive.box(dataBoxName).get(DonorFields.isGpsOn),
                DonorFields.brithDate:
                    Hive.box(dataBoxName).get(DonorFields.brithDate),
              });
            }
          } else if (Hive.box(dataBoxName).isNotEmpty) {
            print("33333333333333333333333");
            Hive.box(dataBoxName).put(DonorFields.name, donor.name);
            Hive.box(dataBoxName).put(DonorFields.bloodType, donor.bloodType);
            Hive.box(dataBoxName).put(DonorFields.isShown, donor.isShown);

            Hive.box(dataBoxName).put(DonorFields.isGpsOn, donor.isGpsOn);

            Hive.box(dataBoxName)
                .put(DonorFields.isShownPhone, donor.isShownPhone);
            Hive.box(dataBoxName).put(DonorFields.brithDate, donor.brithDate);

            Hive.box(dataBoxName).put(DonorFields.district, donor.district);
            Hive.box(dataBoxName).put(DonorFields.state, donor.state);
            Hive.box(dataBoxName)
                .put(DonorFields.neighborhood, donor.neighborhood);
          }
        });
      } else {}
    } catch (e) {
      print(e);
    }
  }
}
