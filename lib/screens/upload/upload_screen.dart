import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/screens/upload/upload_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/utils/functions.dart';
import 'package:picto_frontend/utils/location.dart';

// 요구사항
// 1. 갤러리에서 사진 선택
// 2. 사진 전송
// 3. 예외 처리(글자, 얼굴, 합성, 유해 -> 예외처리)
class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});

  final googleViewModel = Get.find<GoogleMapViewModel>();
  final uploadViewModel = Get.find<UploadViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 스크롤링 중 앱바 색상 변화 방지
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Obx(
          () => uploadViewModel.selectedFrame.value == null
              ? FutureBuilder(
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snapshot.data,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                  future: fetchAddressFromKakao(
                      latitude: googleViewModel.currentLat.value,
                      longitude: googleViewModel.currentLng.value),
                )
              : Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        uploadViewModel.selectedFrame.value!.location,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
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
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(uploadViewModel.selectedImage.value!.path),
                            height: width * 0.85,
                            width: width * 0.85,
                            fit: BoxFit.cover,
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
                                      showSharePopup();
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
                      height: height * 0.495,
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
                                      fontFamily: "NotoSansKR",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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

          // 지도핀 + 등록된 위치
          Row(
            children: [
              Icon(
                Icons.pin_drop,
                size: 30,
                color: AppConfig.mainColor,
              ),
              Text(
                "등록된 위치",
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          TopBox(size: 0.02),

          // 액자 리스트
          SizedBox(
            height: height * 0.3,
            child: FutureBuilder(
                future: PhotoStoreApi().getFrames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text(
                      "등록된 위치를 불러오기 실패",
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    );
                  }
                  uploadViewModel.frames.clear();
                  uploadViewModel.frames.addAll(snapshot.data!);
                  return Obx(() => ListView.builder(
                        itemBuilder: (context, idx) {
                          return _getFrameTime(uploadViewModel.frames[idx]);
                        },
                        itemCount: uploadViewModel.frames.length,
                      ));
                }),
          ),

          // 전송 결과 확인
          // Container(
          //   width: width,
          //   height: height * 0.1,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     border: Border.all(width: 1, color: Colors.grey),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: SingleChildScrollView(
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Obx(
          //         () => Text(
          //           uploadViewModel.result.value,
          //             style: TextStyle(
          //               fontFamily: "NotoSansKR",
          //               fontSize: 14,
          //               fontWeight: FontWeight.w700,
          //               color: Colors.black,
          //             ),
          //           maxLines: 10,
          //           overflow: TextOverflow.visible,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _getFrameTime(Photo photo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 8, offset: Offset(0, 0)),
          ],
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.map,
                  color: AppConfig.mainColor,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      photo.location,
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      formatDateKorean(photo.updateDatetime!),
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: () {
                            uploadViewModel.removeFrame(photo.photoId);
                          }),
                    ),
                    Expanded(
                      flex: 1,
                      child: Obx(() => IconButton(
                            icon: Icon(
                              uploadViewModel.selectedFrame.value?.photoId == photo.photoId
                                  ? Icons.check_box
                                  : Icons.add_box_rounded,
                              color: uploadViewModel.selectedFrame.value?.photoId == photo.photoId
                                  ? Colors.green
                                  : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {
                              uploadViewModel.rollFrame(adapt: photo);
                            },
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSharePopup() {
    Get.dialog(
      Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "PICTO에 사진을 공유하시겠습니. 까?",
              ),
              Obx(
                    () => uploadViewModel.isLoading.value
                    ? Center(
                  child: CircularProgressIndicator(color: AppConfig.mainColor, strokeWidth: 6),
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
                        uploadViewModel.savePhoto(isShared: true);
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
                        uploadViewModel.savePhoto(isShared: false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
