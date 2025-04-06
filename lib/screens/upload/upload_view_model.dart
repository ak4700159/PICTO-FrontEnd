import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadViewModel extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // 단일 이미지 선택에 맞게 observable 정의
  Rxn<XFile> selectedImage = Rxn<XFile>();

  RxBool isShared = false.obs;

  RxString result = "사진을 저장하고 결과를 확인하세요 !".obs;

  Future<void> pickSingleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
    }
  }

  void updateShare(bool? newSelected) {
    isShared.value = newSelected ?? false;
  }

  void savePhoto() {
    // PhotoPreProcessor 서버 api 호출
  }

  void removeSelectedPhoto() {
    selectedImage.value = null;
  }
}
