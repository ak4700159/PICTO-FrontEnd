
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/services/comfyui_manager_service/comfyui_api.dart';
import 'package:picto_frontend/utils/popup.dart';

class ComfyuiViewModel extends GetxController {
  Rxn<XFile?> currentUpscalingSelectedPhoto = Rxn();
  Rxn<XFile?> currentRemoveSelectedPhoto = Rxn();
  RxBool removeReady = false.obs;
  String? currentPrompt;
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지 선택
  void selectPhoto({required bool isFirstScreen}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      isFirstScreen
          ? currentUpscalingSelectedPhoto.value = image
          : currentRemoveSelectedPhoto.value = image;
    }
  }

  // 사진만 있으면 됨.
  // void upscalingPhoto() {
  //
  // }

  // 사진 + 프롬프트
  void removePhoto() async {
    if(currentPrompt!.isEmpty) {
      showErrorPopup("지우고 싶은 카테고리를 입력해주세요!");
      return;
    }
    await ComfyuiAPI().removePhoto(prompt: currentPrompt!, original: currentRemoveSelectedPhoto.value!);
    currentRemoveSelectedPhoto.value = null;
  }

  // 선택된 사진 리셋
  void reset({required bool isFirstScreen}) {
    isFirstScreen
        ? currentUpscalingSelectedPhoto.value = null
        : currentRemoveSelectedPhoto.value = null;
    if(isFirstScreen) removeReady.value = false;
  }

  // 카테고리 저장
  void saveCategories(String? value) {
    currentPrompt = value;
    textController.text = "";
    // FocusScope.of(context).unfocus();
  }
}
