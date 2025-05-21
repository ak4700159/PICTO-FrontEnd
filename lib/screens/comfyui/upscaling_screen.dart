import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/comfyui/comfyui_result.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/services/comfyui_manager_service/comfyui_api.dart';

import '../../config/app_config.dart';
import 'comfyui_view_model.dart';

class UpscalingScreen extends StatelessWidget {
  UpscalingScreen({super.key});

  final comfyuiViewModel = Get.find<ComfyuiViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TopBox(size: 0.1),
                if (comfyuiViewModel.currentUpscalingSelectedPhoto.value != null)
                  _getAnimationPhoto(context)
                else
                  _getSelection(context),
                if (comfyuiViewModel.currentUpscalingSelectedPhoto.value != null)
                  IconButton(
                    onPressed: () {
                      comfyuiViewModel.reset();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
              ],
            ),
          ],
        ));
  }

  // 갤러리에서 사진 선택 화면
  Widget _getSelection(BuildContext context) {
    return Container(
      width: context.mediaQuery.size.width * 0.8,
      height: context.mediaQuery.size.width * 0.8,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
      child: IconButton(
          onPressed: () {
            comfyuiViewModel.selectPhoto(isFirstScreen: true);
          },
          icon: Icon(
            Icons.add_photo_alternate_outlined,
            color: Colors.grey.shade400,
            size: 50,
          )),
    );
  }

  // 사진 선택시 -> 로딩 -> 애니메이션 -> 결과 확인
  Widget _getAnimationPhoto(BuildContext context) {
    return Container(
      width: context.mediaQuery.size.width * 0.8,
      height: context.mediaQuery.size.width * 0.8,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade300),
      child: FutureBuilder(
          future: ComfyuiAPI()
              .upscalingPhoto(original: comfyuiViewModel.currentUpscalingSelectedPhoto.value!),
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
                          fontSize: 13,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700),
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
