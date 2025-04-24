import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/upload/upload_request.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../services/photo_store_service/photo_store_api.dart';
import '../services/user_manager_service/user_api.dart';

class MapViewModel extends GetxController {
  RxInt navigationBarCurrentIndex = 2.obs;
  RxInt previousIndex = 0.obs;
  // RxBool folderUpdate = false.obs;

  void changeNavigationBarIndex(int index) {
    previousIndex.value = navigationBarCurrentIndex.value;
    navigationBarCurrentIndex.value = index;
  }

  void sendFrame() async {
    try {
      final googleMapViewModel = Get.find<GoogleMapViewModel>();
      UploadRequest request = UploadRequest(
        userId: UserManagerApi().ownerId!,
        lat: googleMapViewModel.currentLat.value,
        lng: googleMapViewModel.currentLng.value,
        frameActive: true,
        sharedActive: false,
      );
      await PhotoStoreApi().uploadPhoto(request);
      Get.back();
      showPositivePopup("현재 위치로 저장에 성공하였습니다!");
    } catch(e) {
      print("[ERROR] ${e.toString()}");
      Get.back();
      showErrorPopup("위치 저장에 실패했습니다.");
    }
  }
}