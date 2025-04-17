import 'package:get/get.dart';

class MapViewModel extends GetxController {
  RxInt navigationBarCurrentIndex = 2.obs;
  RxInt previousIndex = 0.obs;
  // RxBool folderUpdate = false.obs;

  void changeNavigationBarIndex(int index) {
    previousIndex.value = navigationBarCurrentIndex.value;
    navigationBarCurrentIndex.value = index;
  }
}