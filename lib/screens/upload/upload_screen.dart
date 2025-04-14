import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
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
    final uploadViewModel = Get.find<UploadViewModel>();
    final googleViewModel = Get.find<GoogleMapViewModel>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null || snapshot.data == false) {
              return CircularProgressIndicator(
                color: Colors.grey,
              );
            } else if (snapshot.hasError) {
              return Icon(
                Icons.error,
                color: Colors.red,
              );
            } else {
              return Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    snapshot.data,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }
          },
          future: fetchAddressFromKakao(
              latitude: googleViewModel.currentLat.value,
              longitude: googleViewModel.currentLng.value),
        ),
      ),
      body: Column(
        children: [
          _getPhotoFrame(context),
        ],
      ),
    );
  }

  Widget _getPhotoFrame(BuildContext context) {
    final width = context.mediaQuery.size.width;
    final height = context.mediaQuery.size.height;
    final uploadViewModel = Get.find<UploadViewModel>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 사진 OR 사진 선택 화면
          Container(
            width: width,
            // 높이는 이미지 너비에 따라 변동
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Obx(
              () => uploadViewModel.selectedImage.value != null
                  // 사진 선택된 경우
                  ? Column(
                      children: [
                        TopBox(size: 0.01),
                        // 사진
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                          child: Image.file(
                            File(uploadViewModel.selectedImage.value!.path),
                            height: height * 0.6,
                          ),
                        ),
                        // 사진 관련 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 다른 사진 선택 버튼
                            SizedBox(
                              width: width * 0.4,
                              child: TextButton(
                                onPressed: () {
                                  uploadViewModel.pickSingleImage();
                                },
                                child: Text(
                                  "다른 사진 선택하기",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            // 사진 공유하기 버튼
                            SizedBox(
                              width: width * 0.4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Get.dialog(
                                        AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: BeveledRectangleBorder(),
                                          title: Row(
                                            children: [
                                              const Icon(Icons.share, color: AppConfig.mainColor),
                                              Text(
                                                '사진 공유',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Text(
                                            "PICTO에 사진을 공유하시겠습니까?",
                                          ),
                                          actions: [
                                            Obx(
                                              () => uploadViewModel.isLoading.value
                                                  ? Center(
                                                    child: CircularProgressIndicator(
                                                        color: AppConfig.mainColor, strokeWidth: 6),
                                                  )
                                                  : Row(
                                                      children: [
                                                        TextButton(
                                                          child: const Text(
                                                            "공유하고 저장",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            uploadViewModel.savePhoto(
                                                                isShared: true);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            "공유하지 않고 저장",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            uploadViewModel.savePhoto(
                                                                isShared: false);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "사진 저장",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      uploadViewModel.removeSelectedPhoto();
                                    },
                                    icon: Icon(
                                      weight: 20,
                                      Icons.delete_outline,
                                      color: AppConfig.mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  // 사진 선택 화면
                  : SizedBox(
                      height: height * 0.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: width * 0.5,
                              child: FloatingActionButton(
                                backgroundColor: AppConfig.mainColor,
                                onPressed: () async {
                                  uploadViewModel.pickSingleImage();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '갤러리에서 사진 선택',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // 저장 결과 화면
          Container(
            width: width,
            height: height * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                left: BorderSide(width: 2, color: Colors.black),
                right: BorderSide(width: 2, color: Colors.black),
                bottom: BorderSide(width: 2, color: Colors.black),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Text(
                    uploadViewModel.result.value,
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
