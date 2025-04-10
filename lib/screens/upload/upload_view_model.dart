import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/upload/upload_request.dart';
import 'package:picto_frontend/services/pre_processor_service/processor_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

class UploadViewModel extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // 단일 이미지 선택에 맞게 observable 정의
  Rxn<XFile> selectedImage = Rxn<XFile>();

  RxBool isShared = false.obs;

  RxBool isLoading = false.obs;

  RxString result = "사진을 저장하고 결과를 확인하세요 !".obs;

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
    try {
      isLoading.value = true;
      final googleViewModel = Get.find<GoogleMapViewModel>();
      UploadRequest request = UploadRequest(
        userId: UserManagerApi().ownerId as int,
        lat: googleViewModel.currentLat.value,
        lng: googleViewModel.currentLng.value,
        file: File(selectedImage.value!.path),
        frameActive: false,
        sharedActive: isShared,
      );
      final data = await PreProcessorApi().validatePhoto(request: request);
      result.value = "사진 저장에 성공했습니다! \n ${data.toString()}";
    } on DioException catch(e) {
      result.value = e.response?.data["error"];
    }
    isLoading.value = false;
    Get.back();
  }

  void removeSelectedPhoto() {
    selectedImage.value = null;
  }
}
