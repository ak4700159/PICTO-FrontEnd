import 'package:get/get.dart';

class ProfileViewModel extends GetxController {
  late int userId;
  RxString name = "".obs;
  RxString email = "".obs;
  RxString accountName = "".obs;
  RxString intro = "".obs;
  RxString profilePath = "".obs;
  RxBool profileActive = true.obs;

  void convertFromJson(Map json) {
    name.value = json["name"];
    email.value = json["email"];
    accountName.value = json["accountName"];
    profileActive.value = json["profileActive"];
    profilePath.value = json["profilePath"];
    intro.value = json["intro"];
    userId = json["userId"];
  }
}