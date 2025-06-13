import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/models/comfyui_result_photo.dart';
import 'package:picto_frontend/utils/popup.dart';

class ComfyuiViewModel extends GetxController {
  Rxn<XFile?> currentUpscalingSelectedPhoto = Rxn();
  Rxn<XFile?> currentRemoveSelectedPhoto = Rxn();
  Rxn<XFile?> determinedRmovePhoto = Rxn();

  // 삭제 중
  RxBool removing = false.obs;
  RxString currentPrompt = "".obs;
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  CancelToken? cancelToken;

  // 영역제거, 업스케일링 결과 확인
  RxList<ComfyuiResultPhoto> previousPhotos = <ComfyuiResultPhoto>[].obs;
  late Box box;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    box = await Hive.openBox('comfyui');
    List<ComfyuiResultPhoto> data = box.values
        .whereType<ComfyuiResultPhoto>() // ChatbotList 타입만 필터링
        .toList();
    previousPhotos.addAll(data);
  }

  // 갤러리에서 이미지 선택
  void selectPhoto({required bool isFirstScreen}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!isFirstScreen) {
        determinedRmovePhoto.value = null;
      }
      isFirstScreen ? currentUpscalingSelectedPhoto.value = image : currentRemoveSelectedPhoto.value = image;
    }
  }

  // 사진 + 프롬프트
  void sendRemovePhoto() {
    if (currentPrompt.isEmpty) {
      showErrorPopup("지우고 싶은 카테고리를 입력해주세요!");
      return;
    }
    if (currentRemoveSelectedPhoto.value == null) {
      showErrorPopup("지우고 싶은 사진을 선택해주세요");
      return;
    }
    determinedRmovePhoto.value = currentRemoveSelectedPhoto.value;
  }

  // 선택된 사진 리셋
  void reset() {
    currentUpscalingSelectedPhoto.value = null;
    currentRemoveSelectedPhoto.value = null;
    determinedRmovePhoto.value = null;
    currentPrompt.value = "";
    removing.value = false;
    cancelToken?.cancel();
    print("[INFO]] comfyUI screen init");
  }

  // 카테고리 저장
  void saveCategories(String? value, BuildContext context) {
    currentPrompt.value = value ?? "";
    textController.text = "";
  }

  // 사진 추가 로직
  void addResultPhotos(Uint8List data, ComfyuiPhotoType type) {
    try {
      int now = DateTime.now().millisecondsSinceEpoch;
      ComfyuiResultPhoto photo = ComfyuiResultPhoto(type: type, data: data, createdTime: now);
      // 현재 타입에 해당하는 사진만 필터링 (업스케일링 등)
      List<ComfyuiResultPhoto> target = previousPhotos.where((p) => p.type == type).toList()
        ..sort((a, b) => a.createdTime.compareTo(b.createdTime)); // 오래된 순 정렬
      if (target.length >= 10) {
        ComfyuiResultPhoto oldest = target.first;
        previousPhotos.remove(oldest);

        // Hive에서 해당 항목 삭제 (key는 createdTime 사용)
        // print("box keys : ${box.keys.toString()}");
        final keyToDelete = box.keys.firstWhere(
          (key) =>
              box.get(key) is ComfyuiResultPhoto &&
              box.get(key).createdTime == oldest.createdTime &&
              box.get(key).type == oldest.type,
          orElse: () => null,
        );
        if (keyToDelete != null) {
          box.delete(keyToDelete);
          showMsgPopup(msg: "10장이 넘어 가장 오래된 사진을 삭제했습니다.", space: 0.4);
        } else {
          showMsgPopup(msg: "박스에서 지우지 못했습니다. (동작 오류)", space: 0.4);
        }
      }
      box.put(photo.createdTime.toString(), photo);
      previousPhotos.add(photo);
    } catch (e) {
      showErrorPopup("Comfyui 결과 사진 로컬 저장 실패 : ${e.toString()}");
    }
  }
}
