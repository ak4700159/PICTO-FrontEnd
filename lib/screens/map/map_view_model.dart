import 'package:get/get.dart';

enum CustomNavigatorState{
  setting,
  photoBook,
  map,
  folder,
  profile;
  // setting(content:"설정", idx:0),
  // photoBook(content:"포토북", idx:1),
  // map(content:"지도", idx:2),
  // folder(content:"폴더", idx:3),
  // profile(content:"프로필", idx:4);
  //
  // final int idx;
  // final String content;
  // const NavigatorState({required this.idx, required this.content});
}

class MapViewModel extends GetxController {
  RxInt navigationBarCurrentIndex = 2.obs;

  void changeNavigationBarIndex(int index) {
    navigationBarCurrentIndex.value = index;
  }


}