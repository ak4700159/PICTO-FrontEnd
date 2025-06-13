import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/comfyui/comfyui_result_image.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/services/comfyui_manager_service/comfyui_api.dart';

import '../../config/app_config.dart';
import '../../models/comfyui_result_photo.dart';
import '../../utils/functions.dart';
import 'comfyui_view_model.dart';

class UpscalingScreen extends StatelessWidget {
  UpscalingScreen({super.key});

  final comfyuiViewModel = Get.find<ComfyuiViewModel>();

  @override
  Widget build(BuildContext context) {
    final double fullWidth = MediaQuery.of(context).size.width * 0.9;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TopBox(size: 0.05),
          Obx(() => comfyuiViewModel.currentUpscalingSelectedPhoto.value != null
              ? _getAnimationPhoto(context)
              : _getSelection(context)),
          Obx(
            () => comfyuiViewModel.currentUpscalingSelectedPhoto.value != null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.03,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            comfyuiViewModel.reset();
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ),
          // 최근 사진 조회 타이틀
          Container(
            width: fullWidth,
            margin: EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 1, color: Colors.grey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.photo,
                  color: AppConfig.mainColor,
                ),
                Row(
                  children: [
                    Text(
                      " 최근 업스케일링 사진",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(() => Text(
                          " ${comfyuiViewModel.previousPhotos.where((p) => p.type == ComfyuiPhotoType.upscaling).length} / 10 (10장까지 저장) ",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          // 최근 사진 리스트
          Obx(() => _getRecentPhotos(context)),
          // 여백
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.2,
          ),
        ],
      ),
    );
  }

  // 갤러리에서 사진 선택 화면
  Widget _getSelection(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: MediaQuery.sizeOf(context).width * 0.9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              comfyuiViewModel.selectPhoto(isFirstScreen: true);
            },
            icon: Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.grey.shade400,
              size: 50,
            ),
          ),
          Text(
            "업스케일링할 사진을 선택해주세요.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "선택하는 순간 바로 실행됩니다.",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }

  // 사진 선택시 -> 로딩 -> 애니메이션 -> 결과 확인
  Widget _getAnimationPhoto(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: MediaQuery.sizeOf(context).width * 0.9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade300),
      child: FutureBuilder(
        future: ComfyuiAPI().upscalingPhoto(original: comfyuiViewModel.currentUpscalingSelectedPhoto.value!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppConfig.mainColor,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "1~2분 정도 소요됩니다. 잠시만 기다려주세요!",
                    style: TextStyle(
                        fontSize: 13, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "업스케일링에 실패했습니다.",
                  style: TextStyle(
                      fontSize: 13, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w700),
                ),
              ),
            );
          }

          // 위젯 바인딩 이후 화면 상태 변화 로직 실행
          WidgetsBinding.instance.addPostFrameCallback((_) {
            comfyuiViewModel.addResultPhotos(snapshot.data!.result, ComfyuiPhotoType.upscaling);
          });
          return ComfyuiResultImage(
            originalImage: snapshot.data!.original,
            upscaledImage: snapshot.data!.result,
          );
        },
      ),
    );
  }

  Widget _getRecentPhotos(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final comfyuiViewModel = Get.find<ComfyuiViewModel>();
    // 최신순 정렬
    var photos = comfyuiViewModel.previousPhotos.where((p) => p.type == ComfyuiPhotoType.upscaling).toList();
    photos.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    return photos.isEmpty
        ? SizedBox(
            height: height * 0.05,
            child: Center(
              child: Text(
                "조회된 사진이 없습니다.",
                style:
                    TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "NotoSansKR", fontWeight: FontWeight.w400),
              ),
            ),
          )
        : SizedBox(
            height: height * 0.25,
            width: width,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, crossAxisSpacing: 0, mainAxisSpacing: 0, childAspectRatio: 1.2),
              itemBuilder: (context, idx) {
                return Container(
                  padding: EdgeInsets.only(left: 4, right: 4, top: 12, bottom: 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: width * 0.4,
                        width: width * 0.4,
                        child: GestureDetector(
                          onTap: () async {
                            Get.toNamed('/comfyui/photo', arguments: {
                              "data": photos[idx].data,
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.memory(
                              photos[idx].data,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        formatDateKorean(photos[idx].createdTime),
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey, fontFamily: "NotoSansKR", fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                );
              },
            ),
          );
  }
}
