import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';

void showProfileModifyDialog(BuildContext context) {
  final profileViewModel = Get.find<ProfileViewModel>();
  double width = context.mediaQuery.size.width;
  double height = context.mediaQuery.size.height;
  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        width: width,
        height: height * 0.4,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 변경 확인 버튼
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "수정 사항 변경하기",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "NotoSansKR",
                    ),
                  ),
                ),
              ],
            ),
            // 한줄 소개 편집
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "한줄 소개",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: "NotoSansKR",
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(4),
                    alignment: Alignment.topLeft,
                    iconSize: 15,
                    onPressed: () {
                      // 수정하기 모드로 변경
                    },
                    icon: Icon(
                      Icons.edit,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    profileViewModel.intro.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      fontFamily: "NotoSansKR",
                    ),
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
