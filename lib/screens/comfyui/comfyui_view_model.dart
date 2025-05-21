import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/utils/popup.dart';

class ComfyuiViewModel extends GetxController {
  Rxn<XFile?> currentUpscalingSelectedPhoto = Rxn();
  Rxn<XFile?> currentRemoveSelectedPhoto = Rxn();
  Rxn<XFile?> determinedRmovePhoto = Rxn();
  RxBool removing = false.obs;
  RxString currentPrompt = "".obs;
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지 선택
  void selectPhoto({required bool isFirstScreen}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if(!isFirstScreen) {
        determinedRmovePhoto.value = null;
      }
      isFirstScreen
          ? currentUpscalingSelectedPhoto.value = image
          : currentRemoveSelectedPhoto.value = image;
    }
  }

  // 사진 + 프롬프트
  void sendRemovePhoto() {
    if (currentPrompt.isEmpty) {
      showErrorPopup("지우고 싶은 카테고리를 입력해주세요!");
      return;
    }
    if(currentRemoveSelectedPhoto.value == null) {
      showErrorPopup("지우고 싶은 사진을 선택해주세요");
      return;
    }
    determinedRmovePhoto.value = currentRemoveSelectedPhoto.value;
    // currentPrompt.value = "";
  }

  // 선택된 사진 리셋
  void reset() {
    currentUpscalingSelectedPhoto.value = null;
    currentRemoveSelectedPhoto.value = null;
    determinedRmovePhoto.value = null;
    currentPrompt.value = "";
  }

  // 카테고리 저장
  void saveCategories(String? value, BuildContext context) {
    currentPrompt.value = value ?? "";
    textController.text = "";
  }
}
