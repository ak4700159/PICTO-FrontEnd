import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final profileViewModel = Get.find<ProfileViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 수정하기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, right: 8),
                  child: TextButton(
                    onPressed: () {
                      // 수정 팝업 생성
                    },
                    child: Text(
                      "수정하기",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.green,
                        fontFamily: "NotoSansKR",
                      ),
                    ),
                  ),
                )
              ],
            ),
            // 사용자 계정 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        profileViewModel.accountName.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                        ),
                      ),
                    ),
                    Text(
                      profileViewModel.email.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        fontFamily: "NotoSansKR",
                      ),
                    ),
                  ],
                )
              ],
            ),
            // 사용자 프로필
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      child: Center(),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
