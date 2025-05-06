import 'dart:typed_data';

import 'package:get/get.dart';
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

  void convertFromJson(Map json, int? profilePhotoId) async {
    name.value = json["name"];
    email.value = json["email"];
    accountName.value = json["accountName"];
    profileActive.value = json["profileActive"];
    profilePath.value = json["profilePath"];
    intro.value = json["intro"];
    userId = json["userId"];
    if (profilePhotoId != null) {
      profilePhoto = await PhotoStoreApi().downloadPhoto(profilePhotoId);
    }
  }
}
