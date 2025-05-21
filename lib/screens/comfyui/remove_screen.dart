import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';

import '../../services/comfyui_manager_service/comfyui_api.dart';
import '../map/top_box.dart';
import 'comfyui_result.dart';
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
                  width: context.mediaQuery.size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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

                Container(
                  padding: EdgeInsets.all(16),
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

                // 텍스트 필드
                Obx(() => _getBottom(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPhoto(BuildContext context) {
    if (comfyuiViewModel.determinedRmovePhoto.value != null &&
        comfyuiViewModel.currentPrompt.value.isNotEmpty) {
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
            height: context.mediaQuery.size.height * 0.2,
          )
        ],
      );
    }
    return Container(
      padding: EdgeInsets.all(8),
      height: context.mediaQuery.size.height * 0.2,
      width: context.mediaQuery.size.width,
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
        width: context.mediaQuery.size.width * 0.9,
        height: context.mediaQuery.size.width * 0.9,
        fit: BoxFit.cover,
      ),
    );
  }

  // 갤러리에서 사진 선택 화면
  Widget _getSelection(BuildContext context) {
    return Container(
      width: context.mediaQuery.size.width * 0.9,
      height: context.mediaQuery.size.width * 0.9,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
      child: IconButton(
        onPressed: () {
          comfyuiViewModel.selectPhoto(isFirstScreen: false);
        },
        icon: Icon(
          Icons.add_photo_alternate_outlined,
          color: Colors.grey.shade400,
          size: 50,
        ),
      ),
    );
  }

  // 사진 선택시 -> 로딩 -> 애니메이션 -> 결과 확인
  Widget _getAnimationPhoto(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      comfyuiViewModel.removing.value = true;
    });

    return Container(
      width: context.mediaQuery.size.width * 0.9,
      height: context.mediaQuery.size.width * 0.9,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
      child: FutureBuilder(
          future: ComfyuiAPI().removePhoto(
            original: comfyuiViewModel.determinedRmovePhoto.value!,
            prompt: comfyuiViewModel.currentPrompt.value,
          ),
          builder: (context, snapshot) {
            // comfyuiViewModel.textController.text = "";
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
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w700),
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
                        fontSize: 13,
                        color: Colors.black,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }

            return ComfyuiResult(
              originalImage: snapshot.data!.original,
              upscaledImage: snapshot.data!.result,
            );
          }),
    );
  }
}
