import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

// 내려오는 상단바? 일단 대기
class TagSelectionViewModel extends GetxController {
  // 폼필드 안에 적어 놓은 태그
  String? addedTag;

  // 선택된 태그 목록
  RxList<String> selectedTags = <String>[].obs;
  // 업데이트 전 태그
  RxList<String> previousTags = <String>[].obs;
  RxBool isChanged = false.obs;
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void submitTag() {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
    }
  }

  void initTags(List<dynamic> tags) {
    tags.forEach((tag) => previousTags.add(tag.toString()));
    tags.forEach((tag) => selectedTags.add(tag.toString()));
  }

  void removeTag(String removedTag) {
    // List<String> emp = [];
    // selectedTags.forEach((s) => emp.add(s));
    selectedTags.removeWhere((t) => t == removedTag);
    if (!compareTags()) {
      isChanged.value = true;
    } else {
      isChanged.value = false;
    }
  }

  void addTag(String addedTag) {
    // List<String> emp = [];
    // // 이전에 선택한 태그 임시 저장
    // selectedTags.forEach((s) => emp.add(s));
    // 선택된 태그에 추가
    selectedTags.add(addedTag);
    if (!compareTags()) {
      isChanged.value = true;
    } else {
      isChanged.value = false;
    }
  }

  void updateMap() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    List<String> modify = selectedTags.map((t) => t.toString()).toList();
    // print('[INFO] tags : $modify');
    await UserManagerApi().modifiedTag(modify);
    googleMapViewModel.updateAllMarkersByTag(selectedTags.map<String>((t) => t).toList());
    isChanged.value = false;
    previousTags.clear();
    previousTags.addAll(selectedTags);
  }

  bool compareTags() {
    print("[INFO] 현재 선택 태그 : ${selectedTags.toString()}");
    print("[INFO] 이전 선택 태그 : ${previousTags.toString()}");
    for(String tag in previousTags) {
      // 이전에 선택된 태그 안에서 현재 선택된 태그 내용이 없으면 false 반환
      if(!selectedTags.contains(tag)){
        print("[INFO] 다른 항목 : $tag");
        return false;
      }
    }

    for(String tag in selectedTags) {
      // 현재 선택된 태그 안에서 이전에 선택된 태그 내용이 없으면 false 반환
      if(!previousTags.contains(tag)){
        print("[INFO] 다른 항목 : $tag");
        return false;
      }
    }
    return true;
  }
}
