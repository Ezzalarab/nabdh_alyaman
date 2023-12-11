import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/blood_center.dart';
import '../../../domain/entities/donor.dart';
import '../../../domain/entities/search_log.dart';
import '../../../domain/usecases/search_centers_uc.dart';
import '../../../domain/usecases/search_state_donors_uc.dart';
import '../../../presentation/pages/setting_page.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchStateDonorsUC searchStateDonorsUseCase;
  final SearchCentersUC searchCentersUseCase;
  SearchCubit({
    required this.searchStateDonorsUseCase,
    required this.searchCentersUseCase,
  }) : super(SearchInitial());

  List<Donor> donors = [], stateDonors = [];
  List<BloodCenter> centers = [];
  String selectedState = '', selectedDistrict = '';
  String? selectedBloodType;
  int selectedTabBloodType = 0;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<void> searchDonorsAndCenters() async {
    emit(SearchLoading());
    if (selectedState == '' ||
        selectedDistrict == '' ||
        selectedBloodType == null) {
      emit(SearchFailure(error: 'يجب تحديد الخيارات المطلوب البحث عنها'));
    } else {
      try {
        searchStateDonorsUseCase(
          state: selectedState,
        ).then((stateDonorsOrFailure) {
          stateDonorsOrFailure.fold(
              (failure) =>
                  emit(SearchFailure(error: getFailureMessage(failure))),
              (fetchedStateDonors) async {
            stateDonors = fetchedStateDonors;
            if (kDebugMode) {
              print("stateDonors.length");
              print(stateDonors.length);
            }
            donors = fetchedStateDonors.where((donor) {
              bool inDistrict =
                  donor.district == selectedDistrict || donor.district == "";
              if (donor.district == '') {
                donor.neighborhood = '${donor.district} (المديرية غير محددة)';
              }
              if (donor.district != '' && donor.neighborhood == '') {
                donor.neighborhood = '(المنطقة غير محددة)';
              }
              return inDistrict;
            }).toList();
            if (kDebugMode) {
              print("donors.length");
              print(donors.length);
            }
            await searchCentersUseCase(
              state: selectedState,
              district: selectedDistrict,
            ).then((centersOrFailure) {
              centersOrFailure.fold(
                  (failure) =>
                      emit(SearchFailure(error: getFailureMessage(failure))),
                  (fetchedCenters) {
                centers = fetchedCenters;
                emit(SearchSuccess(
                  donors: donors,
                  centers: fetchedCenters,
                  stateDonors: stateDonors,
                  selectedTabIndex: selectedTabBloodType,
                ));
              });
            });
          });
        });
        fireStore
            .collection("search_logs")
            .add(
              SearchLog(
                state: selectedState,
                district: selectedDistrict,
                bloodType: selectedBloodType!,
                date: DateTime.now().toString(),
                donorsCount: donors
                    .where((donor) =>
                        donor.district == selectedDistrict &&
                        donor.bloodType == selectedBloodType!)
                    .toList()
                    .length
                    .toString(),
                token: (await FirebaseMessaging.instance.getToken()).toString(),
                userType: await Hive.box(dataBoxName).get('user') ?? "0",
              ).toMap(),
            )
            .then((_) {
          if (kDebugMode) {
            print("log has recorded");
          }
        });
      } on FirebaseException catch (e) {
        emit(SearchFailure(error: e.code));
      } catch (e) {
        emit(SearchFailure(error: e.toString()));
      }
    }
  }

  void setSelectedTabBloodType({required int tabIndex}) async {
    emit(
      SearchSuccess(
        donors: donors,
        centers: centers,
        stateDonors: stateDonors,
        selectedTabIndex: tabIndex,
      ),
    );
  }
}
