import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadViewModel extends GetxController {
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  XFile? mainImage;

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    selectedImages = images;
    mainImage = images.first;
  }
}
