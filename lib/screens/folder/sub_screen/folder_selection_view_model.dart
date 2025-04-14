import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/utils/popup.dart';

class FolderSelectionViewModel extends GetxController {
  int? selectedIdx;
  RxMap<int, bool> selectedList = <int, bool>{}.obs;
  RxBool selectedMode = false.obs;

  void setSelectionMode() {
    final folderViewModel = Get.find<FolderViewModel>();
    selectedList.clear();
    for (int folderKey in folderViewModel.folders.keys) {
      selectedList[folderKey] = false;
    }
  }

  void copyPhoto({required int photoId}) {
    final folderViewModel = Get.find<FolderViewModel>();
    selectedList.forEach((int folderId, bool selected) async {
      if (selected) {
        if (await FolderManagerApi().copyPhotoToOtherFolder(photoId: photoId, folderId: folderId)) {
          folderViewModel.folders[folderId]?.updateFolder();
          showPositivePopup("폴더에 정상적으로 복사되었습니다람쥐!");
        }
      }
    });

    for (int folderKey in folderViewModel.folders.keys) {
      selectedList[folderKey] = false;
    }
  }
}
