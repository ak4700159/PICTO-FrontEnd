import 'package:get/get.dart';

class MapViewModel extends GetxController {
  RxInt navigationBarCurrentIndex = 2.obs;

  void changeNavigationBarIndex(int index) {
    navigationBarCurrentIndex.value = index;
  }


}