import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';

// 내려오는 상단바? 일단 대기
class TagSelectionViewModel extends GetxController {
  // 폼필드 안에 적어 놓은 태그
  String? addedTag;

  // 선택된 태그 목록
  RxList selectedTags = [].obs;
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
    selectedTags.addAll(tags);
  }

  void removeTag(String removedTag) {
    selectedTags.removeWhere((t) => t == removedTag);
    isChanged.value = true;
  }

  void addTag(String addedTag) {
    selectedTags.add(addedTag);
    isChanged.value = true;
  }

  void updateMap() async {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    List<String> modify = selectedTags.map((t) => t.toString()).toList();
    print('[INFO] tags : $modify');
    await UserManagerHandler().modifiedTag(modify);
    googleMapViewModel.updateAllMarkersByTag(selectedTags.map<String>((t) => t).toList());
  }
}
