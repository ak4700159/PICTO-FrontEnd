import 'package:get/get.dart';

class MapViewModel extends GetxController {
  RxInt navigationBarCurrentIndex = 2.obs;

  RxBool chatbotInputSelected = false.obs;

  void toggleChatbotInputSelected() {
    chatbotInputSelected.value = !chatbotInputSelected.value;
  }

  void changeNavigationBarIndex(int index) {
    navigationBarCurrentIndex.value = index;
  }
}