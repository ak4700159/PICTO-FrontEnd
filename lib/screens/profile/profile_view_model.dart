import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';

class ProfileViewModel extends GetxController {
  late int userId;
  late Uint8List profilePhoto;
  int? profilePhotoId;
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

  void convertFromJson(Map json, int? profilePhotoId) async {
    name.value = json["name"];
    email.value = json["email"];
    accountName.value = json["accountName"];
    profileActive.value = json["profileActive"];
    profilePath.value = json["profilePath"];
    intro.value = json["intro"];
    userId = json["userId"];
    if (profilePhotoId != null) {
      profilePhoto = await PhotoStoreApi().downloadPhoto(photoId: profilePhotoId, scale: 0.5);
    }
  }

  // 프로필 사진 선택 이벤트
  void selectedProfilePhoto({required PictoMarker marker}) {
    if(selectedPictoMarker.value == null) {
      selectedPictoMarker.value = marker;
    } else if(selectedPictoMarker.value == marker) {
      selectedPictoMarker.value = null;
    }
  }
}
