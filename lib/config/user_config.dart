import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConfig extends GetxController{
  // 어플 전역 관련
  RxBool lightMode = true.obs;
  RxBool autoRotation = true.obs;
  RxBool aroundAlert = false.obs;
  RxBool popularAlert = false.obs;

  // 마커 사진 관련
  RxBool showFolderPhotos = true.obs;
  RxBool showAroundPhotos = true.obs;
  RxBool showMyPhotos = true.obs;
  RxBool showRepresentativePhotos = true.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showFolderPhotos.value = prefs.getBool("showFolderPhotos") ?? false;
    showAroundPhotos.value = prefs.getBool("showAroundPhotos") ?? false;
    showMyPhotos.value = prefs.getBool("showMyPhotos") ?? false;
    showRepresentativePhotos.value = prefs.getBool("showRepresentativePhotos") ?? false;
  }

  void convertFromJson(Map json) {
    lightMode.value = json["lightMode"];
    autoRotation.value = json["autoRotation"];
    aroundAlert.value = json["aroundAlert"];
    popularAlert.value = json["popularAlert"];
  }

  void toggleShowFolderPhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showFolderPhotos", !showFolderPhotos.value);
    showFolderPhotos.value = !showFolderPhotos.value;
  }
  void toggleShowAroundPhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showFolderPhotos", !showAroundPhotos.value);
    showAroundPhotos.value = !showAroundPhotos.value;
  }
  void toggleShowMyPhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showFolderPhotos", !showMyPhotos.value);
    showMyPhotos.value = !showMyPhotos.value;
  }
  void toggleShowRepresentativePhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showFolderPhotos", !showRepresentativePhotos.value);
    showRepresentativePhotos.value = !showRepresentativePhotos.value;
  }

  // true로 설정한 마커 옵션을 반환
  List<PictoMarkerType> getMarkerFilter() {
    List<PictoMarkerType> result = [];
    if(showMyPhotos.value) result.add(PictoMarkerType.userPhoto);
    if(showAroundPhotos.value) result.add(PictoMarkerType.aroundPhoto);
    if(showFolderPhotos.value) result.add(PictoMarkerType.folderPhoto);
    if(showRepresentativePhotos.value) result.add(PictoMarkerType.representativePhoto);
    return result;
  }
}
