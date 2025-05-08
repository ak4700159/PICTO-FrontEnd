import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/upload/upload_request.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/services/pre_processor_service/processor_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../models/photo.dart';

class UploadViewModel extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // 단일 이미지 선택에 맞게 observable 정의
  Rxn<XFile> selectedImage = Rxn<XFile>();

  RxBool isShared = false.obs;

  RxBool isLoading = false.obs;

  RxString result = "사진을 저장하고 결과를 확인하세요 !".obs;

  RxList<Photo> frames = <Photo>[].obs;

  // 프레임에 있는 사진으로 전송을 원할 경우 값을 넣으면 됨 -> 갤러리 사진일 때 null 값 유지.
  Rxn<Photo?> selectedFrame = Rxn();


  Future<void> pickSingleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
    }
  }

  void updateShare(bool? newSelected) {
    isShared.value = newSelected ?? false;
  }

  void savePhoto({required bool isShared}) async {
    final googleViewModel = Get.find<GoogleMapViewModel>();
    UploadRequest request;
    try {
      isLoading.value = true;
      if (selectedFrame.value != null) {
        request = UploadRequest(
          userId: UserManagerApi().ownerId as int,
          lat: selectedFrame.value!.lat,
          lng: selectedFrame.value!.lng,
          file: File(selectedImage.value!.path),
          frameActive: false,
          sharedActive: isShared,
        );
      } else {
        request = UploadRequest(
          userId: UserManagerApi().ownerId as int,
          lat: googleViewModel.currentLat.value,
          lng: googleViewModel.currentLng.value,
          file: File(selectedImage.value!.path),
          frameActive: false,
          sharedActive: isShared,
        );
      }
      final data = await PreProcessorApi().validatePhoto(request: request);
      frames.removeWhere((p) => p.photoId == selectedFrame.value!.photoId);
      selectedFrame.value = null;
      result.value = "사진 저장에 성공했습니다! \n $data";
    } on DioException catch (e) {
      result.value = e.response?.data["error"] ?? "서버 오류 발생";
    }
    isLoading.value = false;
    Get.back();
  }

  // 갤러리에서 선택한 사진 삭제
  void removeSelectedPhoto() {
    selectedImage.value = null;
    selectedFrame.value = null;
  }

  void getFrames() async {
    List<Photo> newFrames = await PhotoStoreApi().getFrames();
    frames.clear();
    frames.value = newFrames;
  }

  // 사진 선택
  void rollFrame({required Photo adapt}) {
    if (selectedFrame.value?.photoId == adapt.photoId) {
      print("[INFO] duplicated.. !");
      selectedFrame.value = null;
    } else {
      selectedFrame.value = adapt;
    }
  }

  void removeFrame(int photoId) async {
    if (await PhotoStoreApi().deletePhoto(photoId)) {
      if (photoId == selectedFrame.value!.photoId) selectedFrame.value = null;
      frames.removeWhere((photo) => photo.photoId == photoId);
    }
  }
}
