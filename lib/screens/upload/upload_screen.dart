import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/upload/upload_view_model.dart';
import 'package:picto_frontend/utils/location.dart';

// 요구사항
// 1. 갤러리에서 사진 선택
// 2. 사진 전송
// 3. 예외 처리(글자, 얼굴, 합성, 유해 -> 예외처리)
// 4.
class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final uploadViewModel = Get.find<UploadViewModel>();
    final googleViewModel = Get.find<GoogleMapViewModel>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackButton(),
        // title: const Text(fetchAddressFromKakao(googleV: ), style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.deepPurpleAccent),
            onPressed: () {
              // 저장 로직
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (uploadViewModel.mainImage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(uploadViewModel.mainImage!.path),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('갤러리에서 사진 선택'),
            onTap: uploadViewModel.pickImages,
          ),
        ],
      ),
    );
  }
}
