import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../config/app_config.dart';

void showProfileModifyDialog(BuildContext context) {
  final profileViewModel = Get.find<ProfileViewModel>();
  final accountEditController = TextEditingController();
  final introEditController = TextEditingController();
  double width = MediaQuery.sizeOf(context).width;
  double height = MediaQuery.sizeOf(context).height;
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        width: width * 0.9,
        height: height * 0.5,
        child: Column(
          children: [
            TextField(
              controller: accountEditController,
              style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(217, 217, 217, 0.19),
                errorMaxLines: 2,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                hintStyle: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                labelStyle: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                labelText: "별칭 수정",
                hintText: "",
              ),
              onChanged: (String? val) {
                profileViewModel.newAccount = val ?? "";
              },
            ),
            SizedBox(height: height * 0.03,),
            TextField(
              controller: introEditController,
              maxLines: 8,
              style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600, ),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(217, 217, 217, 0.19),
                errorMaxLines: 2,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                hintStyle: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                labelStyle: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                labelText: "한줄 소개 수정",
                hintText: "",
              ),
              onChanged: (String? val) {
                profileViewModel.newIntro = val ?? "";
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: height * 0.08,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: FloatingActionButton(
                      heroTag: "adapt",
                      onPressed: () {
                                UserManagerApi().modifyUserInfo();
                      },
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      backgroundColor: AppConfig.mainColor,
                      child: Text(
                        "적용",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: height * 0.08,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: FloatingActionButton(
                      heroTag: "back",
                      onPressed: () {
                        Get.back();
                      },
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      backgroundColor: Colors.red,
                      child: Text(
                        "취소",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
