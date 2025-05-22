import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/upload/upload_request.dart';
import 'package:picto_frontend/services/session_scheduler_service/session_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../models/photo.dart';
import '../http_interceptor.dart';

class PreProcessorApi {
  PreProcessorApi._();

  static final PreProcessorApi _handler = PreProcessorApi._();

  factory PreProcessorApi() {
    return _handler;
  }

  // final String baseUrl = "${AppConfig.httpUrl}:8087";
  final String baseUrl = "http://${dotenv.env['PROCESSOR_IP']}:8087";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 100),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 100)),
  )..interceptors.add(CustomInterceptor());

  // 유효성 검사 및 사진 전송 api 호출
  Future<String> validatePhoto({required UploadRequest request}) async {
    try {
      final fileName = request.file!.path.split('/').last;
      final mimeType = lookupMimeType(request.file!.path) ?? 'application/octet-stream';
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(request.file!.path, filename: fileName, contentType: MediaType.parse(mimeType)),
        'request': MultipartFile.fromString(request.toJson(), contentType: MediaType('application', 'json')),
      });
      final response = await dio.post('$baseUrl/validate', data: formData);

      // 공유 사진인 경우 다른 사용자들에게 공유 시도
      if (request.sharedActive) {
        int photoId = response.data["photoId"];
        SessionApi().sendSharedPhoto(lat: request.lat, lng: request.lng, photoId: photoId);
      }

      // 저장한 사진 folder에 바로 적용
      final Map<String, dynamic> data = response.data;
      final folderViewModel = Get.find<FolderViewModel>();
      for (var folder in folderViewModel.folders.values) {
        if (folder.name == 'default') {
          folder.photos.add(Photo(
            userId: UserManagerApi().ownerId as int,
            photoId: data["photoId"],
            photoPath: data['photoPath'],
            lat: data['lat'],
            lng: data['lng'],
            likes: 0,
            views: 0,
            location: data['location'],
            tag: data['tag'],
          ));
          return "기본폴더에 사진이 저장되었어요!!";
        }
      }
      return "기본폴더에서 사진을 확인해주세요!";
    } catch (e) {
      rethrow;
    }
  }
}
