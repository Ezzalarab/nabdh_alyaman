import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception_mapper.dart';

abstract class FilesRemoteDataSource {
  Future<int> uploadPublicImage(File file);
}

class FilesRemoteDataSourceImpl implements FilesRemoteDataSource {
  FilesRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<int> uploadPublicImage(File file) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
        'isPublic': 'true',
      });
      final res = await _api.post<dynamic>(
        ApiEndpoints.filesUpload,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (res.statusCode != 201 && res.statusCode != 200) {
        throw WrongDataFailure();
      }
      final data = res.data;
      if (data is! Map) throw WrongDataFailure();
      final map = Map<String, dynamic>.from(data);
      final id = map['fileId'] ?? map['id'];
      if (id is int) return id;
      if (id is num) return id.toInt();
      final parsed = int.tryParse(id?.toString() ?? '');
      if (parsed == null) throw WrongDataFailure();
      return parsed;
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
