
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/services/comfyui_manager_service/comfyui_api.dart';

class ComfyuiViewModel extends GetxController {
  Rxn<XFile?> currentUpscalingSelectedPhoto = Rxn();
  Rxn<XFile?> currentRemoveSelectedPhoto = Rxn();
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
  void upscalingPhoto() {}

  // 사진 + 프롬프트
  void removePhoto() async {
    currentPrompt = textController.text;
    textController.text = "";
    await ComfyuiAPI().removePhoto(prompt: currentPrompt!, original: currentRemoveSelectedPhoto.value!);
    currentRemoveSelectedPhoto.value = null;
  }

  // 선택된 사진 리셋
  void reset({required bool isFirstScreen}) {
    isFirstScreen
        ? currentUpscalingSelectedPhoto.value = null
        : currentRemoveSelectedPhoto.value = null;
  }
}
