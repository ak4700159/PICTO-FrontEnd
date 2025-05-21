import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

class ProfileViewModel extends GetxController {
  late int userId;
  late Uint8List profilePhoto;

  Rxn<int?> profilePhotoId = Rxn();
  RxString name = "".obs;
  RxString email = "".obs;
  RxString accountName = "".obs;
  RxString intro = "".obs;
  RxString profilePath = "".obs;
  RxBool profileActive = true.obs;

  // 프로필 사진 ->어떤 사진이 선택되었는지 알아야됨
  // RxList<bool> selectedPhoto = <bool>[].obs;
  // RxBool isSelected = false.obs;
  Rxn<PictoMarker?> selectedPictoMarker = Rxn();

  // 한줄 소개 편집 여부

  // 닉네임 변경 여부

  // 비밀번호 변경

  void convertFromJson(Map json, int? profilePhotoId) async {
    name.value = json["name"];
    email.value = json["email"];
    accountName.value = json["accountName"];
    profileActive.value = json["profileActive"];
    profilePath.value = json["profilePath"];
    intro.value = json["intro"];
    userId = json["userId"];
    this.profilePhotoId.value = profilePhotoId;
    if (profilePhotoId != null) {
      profilePhoto = await PhotoStoreApi().downloadPhoto(photoId: profilePhotoId, scale: 0.5);
    }
  }

  // 프로필 사진 선택 이벤트
  void selectedProfilePhoto({required PictoMarker marker}) {
    if (selectedPictoMarker.value == marker) {
      selectedPictoMarker.value = null;
    } else {
      selectedPictoMarker.value = marker;
    }
  }

  // 프로필 적용하기
  void adaptProfile() async {
    Get.back();
    if (await UserManagerApi().updateUserProfilePhoto(photoId: selectedPictoMarker.value!.photo.photoId)) {
      profilePhotoId.value = selectedPictoMarker.value!.photo.photoId;
      profilePhoto = selectedPictoMarker.value!.imageData!;
      showPositivePopup("대표 사진이 업데이트되었습니다.");
    } else {
      showErrorPopup("대표 사진을 업데이트하지 못했습니다.");
    }
    selectedPictoMarker.value = null;
  }
}
