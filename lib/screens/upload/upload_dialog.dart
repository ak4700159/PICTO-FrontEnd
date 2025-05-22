import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/upload/upload_view_model.dart';

import '../../config/app_config.dart';

void showSharePopup(BuildContext context) {
  final uploadViewModel = Get.find<UploadViewModel>();
  double width = context.mediaQuery.size.width;
  double height = context.mediaQuery.size.height;
  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Container(
        width: width * 0.9,
        height: height * 0.18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "PICTO에 사진을 공유하시겠습니까?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Obx(
                    () => uploadViewModel.isLoading.value
                    ? SizedBox(
                      height: width * 0.05,
                      width: width * 0.05,
                      child: Center(
                                        child: CircularProgressIndicator(color: AppConfig.mainColor, strokeWidth: 3),
                                      ),
                    )
                    : SizedBox(
                  width: width * 0.8,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: AppConfig.mainColor,
                            ),
                            child: const Text(
                              "공유하고 저장",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () {
                              uploadViewModel.savePhoto(isShared: true);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              "공유하지 않고 저장",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () {
                              uploadViewModel.savePhoto(isShared: false);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showValidateFailMsg(BuildContext context, String error) {

}


