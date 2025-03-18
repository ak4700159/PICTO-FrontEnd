import 'package:get/get.dart';

class UserConfig extends GetxController{
  RxBool lightMode = true.obs;
  RxBool autoRotation = true.obs;
  RxBool aroundAlert = false.obs;
  RxBool popularAlert = false.obs;

  void convertFromJson(Map json) {
    lightMode.value = json["lightMode"];
    autoRotation.value = json["autoRotation"];
    aroundAlert.value = json["aroundAlert"];
    popularAlert.value = json["popularAlert"];
  }
}
