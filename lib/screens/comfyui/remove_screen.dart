import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/comfyui_result_photo.dart';

import '../../services/comfyui_manager_service/comfyui_api.dart';
import '../../utils/functions.dart';
import '../map/top_box.dart';
import 'comfyui_result_image.dart';
import 'comfyui_view_model.dart';

class RemoveScreen extends StatelessWidget {
  RemoveScreen({super.key});

  final comfyuiViewModel = Get.find<ComfyuiViewModel>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TopBox(size: 0.05),
                // [사진 + 프롬프트가 준비된 상태 / 사진만 선택된 상태 / 사진도 선택되지 않은 상태]
                Obx(() => _getPhoto(context)),
                // 아이콘 버튼
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // 흐음
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(offset: Offset(0, 0), blurRadius: 1, color: Colors.grey),
                          ],
                        ),
                        child: Obx(
                          () => Text(
                            comfyuiViewModel.currentPrompt.value == ""
                                ? "입력한 카테고리"
                                : "입력한 카테고리 : ${comfyuiViewModel.currentPrompt.value}",
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      // 사진 바꾸기
                      IconButton(
                        onPressed: () {
                          comfyuiViewModel.reset();
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      // 사진 속 불필요한 영역 지우기
                      IconButton(
                        onPressed: () {
                          // currentPrompt 빈 문자열이 아니여야 됨 -> 카테고리 지정 필수
                          // selectedPhoto 널값이 아닝여야 됨 -> 선택 필수
                          comfyuiViewModel.sendRemovePhoto();
                          // 위 함수가 실행되면 determinedPhoto에 값이 들어가짐 -> 실제 전달된 사진
                        },
                        icon: Icon(
                          Icons.send,
                          color: AppConfig.mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // 텍스트 필드
                Obx(() => _getBottom(context)),
                // 최근 사진 타이틀 위젯
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                  padding: EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 1, color: Colors.grey))),
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
                            " 최근 인페인팅 사진",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Obx(() => Text(
                            " ${comfyuiViewModel.previousPhotos.where((p) => p.type == ComfyuiPhotoType.removing).length} / 10 (10장까지 저장) ",
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
          ),
        ],
      ),
    );
  }

  Widget _getPhoto(BuildContext context) {
    if (comfyuiViewModel.determinedRmovePhoto.value != null && comfyuiViewModel.currentPrompt.value.isNotEmpty) {
      return _getAnimationPhoto(context);
    } else if (comfyuiViewModel.currentRemoveSelectedPhoto.value != null) {
      return _getOriginalPhoto(context);
    }
    return _getSelection(context);
  }

  Widget _getBottom(BuildContext context) {
    if (comfyuiViewModel.removing.value) {
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.1,
          )
        ],
      );
    }
    return Container(
      padding: EdgeInsets.all(8),
      height: MediaQuery.sizeOf(context).height * 0.1,
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: TextFormField(
        minLines: 1,
        maxLines: 1,
        controller: comfyuiViewModel.textController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(9),
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade50,
          hintStyle: TextStyle(
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.black,
          ),
          hintText: "지우고 싶은 영역의 카테고리를 입력해주세요!",
          border: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        keyboardType: TextInputType.text,
        onFieldSubmitted: (String? value) {
          comfyuiViewModel.saveCategories(value, context);
        },
      ),
    );
  }

  Widget _getOriginalPhoto(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(comfyuiViewModel.currentRemoveSelectedPhoto.value!.path),
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).width * 0.9,
        fit: BoxFit.cover,
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
              comfyuiViewModel.selectPhoto(isFirstScreen: false);
            },
            icon: Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.grey.shade400,
              size: 50,
            ),
          ),
          Text(
            "지우고 싶은 영역을 입력하고 사진을 선택해주세요.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "버튼을 눌러 실행합니다.",
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      comfyuiViewModel.removing.value = true;
    });

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: MediaQuery.sizeOf(context).width * 0.9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
      child: FutureBuilder(
          future: ComfyuiAPI().removePhoto(
            original: comfyuiViewModel.determinedRmovePhoto.value!,
            prompt: comfyuiViewModel.currentPrompt.value,
          ),
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
                        "5~6분 정도 소요됩니다. 잠시만 기다려주세요!",
                        style: TextStyle(
                            fontSize: 13, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "영역 제거에 실패했습니다.",
                    style: TextStyle(
                        fontSize: 13, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }

            // 위젯 바인딩 이후 화면 상태 변화 로직 실행
            WidgetsBinding.instance.addPostFrameCallback((_) {
              comfyuiViewModel.addResultPhotos(snapshot.data!.result, ComfyuiPhotoType.removing);
            });
            return ComfyuiResultImage(
              originalImage: snapshot.data!.original,
              upscaledImage: snapshot.data!.result,
            );
          }),
    );
  }

  Widget _getRecentPhotos(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final comfyuiViewModel = Get.find<ComfyuiViewModel>();
    // 최신순 정렬
    var photos = comfyuiViewModel.previousPhotos.where((p) => p.type == ComfyuiPhotoType.removing).toList();
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
