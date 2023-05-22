import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../core/app_constants.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../../../domain/entities/notfication_data.dart';
import '../../../domain/repositories/notfication_repository.dart';

class SendNotficationImpl implements SendNotficationRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final NetworkInfo networkInfo;
  SendNotficationImpl({
    required this.networkInfo,
  });
  List<String>? _listToken;
  @override
  Future<Either<Failure, Unit>> senNotficationToGroup(
      {required SendNotificationData sendNotificationData}) async {
    // TODO: implement senNotficationToGroup
    if (await networkInfo.isConnected) {
      if (sendNotificationData.listToken != null) {}
      _listToken = [
        "cscSJymiS1m6mEtyK8140J:APA91bEVPefdZNqg5jkLdvpEBYiSKBDDfeOIsnQF-1luu9lEO6_QBOuUbrsOycP4jL3OLvNZdMkZbqELRiPf9XstNPDdrwRtWVLEG28xyDPWna7UDsn_G8rPvzymwmWIANJWky45rFWX",
        "eqeW-N5rRb62f3qsys66jI:APA91bEGHI6wPPEigkgqF3WuSeIQ91CG0LFy-F0MCV61LGknkvSZa9JWyG7Lwg8XGFdLEOzQ12Fsr1oLx7DEsyrJZzLzIaxYYaxGljc3DXLuy5LUWLHzJ2YxZSfTBlXcuCJ31jhxc8jM",
        "f-wunReNSZyR8BAs3xgl4y:APA91bE_FxTEdtlzH5PfdEau6vPVIfA3Hk8Ykb--azdYgONq3ZaN9D9HUQBnsDR36NYD74qEgfhHF-W_3JrMEwO8z6GIQPwXifmGeGpX4Qreb1TYgWC2ypAP6YuLcJW3UVmodljWqVx_",
      ];
      jsonEncode(_listToken);
      print(jsonEncode(_listToken));
      try {
        String dataNotifications = '{'
            '"operation": "create",'
            '"notification_key_name": "appUser-testUser",'

            // '"registration_ids":["fwSGgXVlQ1-DkWdPvwC2vU:APA91bFcNOMGE2cl9c-BPfzUk4ksX-EIOSKEIixpAoO0k0XE7blcIRugk8xIl_ZQTM3KxbPuVCyajUSrMF-9uzrRkpA6K98M8-khrQKuk_YKLhqonSHcgi5bcJhQcqcSqQcOLbhQEMUr","f-wunReNSZyR8BAs3xgl4y:APA91bE_FxTEdtlzH5PfdEau6vPVIfA3Hk8Ykb--azdYgONq3ZaN9D9HUQBnsDR36NYD74qEgfhHF-W_3JrMEwO8z6GIQPwXifmGeGpX4Qreb1TYgWC2ypAP6YuLcJW3UVmodljWqVx_"],'
            '"registration_ids":${jsonEncode(_listToken)},'
            '"notification" : {'
            '"title":"${sendNotificationData.title}",'
            '"body":"${sendNotificationData.body}"'
            ' }'
            ' }';
        var response = await http.post(
          Uri.parse(AppConstants.baseUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key= ${AppConstants.serverKey}',
            'project_id': AppConstants.senderId
          },
          body: dataNotifications,
        );

        print(response.body.toString());

        return Right(unit);
      } catch (e) {
        return Left(UnknownFailure());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  // @override
  // Future<Either<Failure, Unit>> senNotficationToGroup(
  //     {required SendNotficationData sendNotficationData}) async {
  //       throw ;
  // //   try {
  // //     String dataNotifications = '{'
  // //         '"operation": "create",'
  // //         '"notification_key_name": "appUser-testUser",'
  // //         '"registration_ids":["fwSGgXVlQ1-DkWdPvwC2vU:APA91bFcNOMGE2cl9c-BPfzUk4ksX-EIOSKEIixpAoO0k0XE7blcIRugk8xIl_ZQTM3KxbPuVCyajUSrMF-9uzrRkpA6K98M8-khrQKuk_YKLhqonSHcgi5bcJhQcqcSqQcOLbhQEMUr","f-wunReNSZyR8BAs3xgl4y:APA91bE_FxTEdtlzH5PfdEau6vPVIfA3Hk8Ykb--azdYgONq3ZaN9D9HUQBnsDR36NYD74qEgfhHF-W_3JrMEwO8z6GIQPwXifmGeGpX4Qreb1TYgWC2ypAP6YuLcJW3UVmodljWqVx_"],'
  // //         '"notification" : {'
  // //         '"title":"${sendNotficationData.title}",'
  // //         '"body":"${sendNotficationData.body}"'
  // //         ' }'
  // //         ' }';

  // //     var response = await http.post(
  // //       Uri.parse(Constants.BASE_URL),
  // //       headers: <String, String>{
  // //         'Content-Type': 'application/json',
  // //         'Authorization': 'key= ${Constants.KEY_SERVER}',
  // //         'project_id': "${Constants.SENDER_ID}"
  // //       },
  // //       body: dataNotifications,
  // //     );

  // //     print(response.body.toString());

  // //     // return true;
  // //   } catch (e) {}
  // }
}
