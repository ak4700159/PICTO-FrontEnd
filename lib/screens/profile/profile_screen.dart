import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
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
            SizedBox(height: context.mediaQuery.size.height * 0.05,),
            // 사용자 프로필
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: context.mediaQuery.size.width * 0.5,
                      height: context.mediaQuery.size.width * 0.5,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: _getProfileWidget(),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        onPressed: () {
                          // 프로필 사진 수정 및 선택  화면
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: context.mediaQuery.size.height * 0.1,),
            // 캘린더
            Container(
              color: Colors.grey.shade300,
              child: Text("캘린더 위치"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getProfileWidget() {
    if (profileViewModel.profilePhotoId == null) {
      return Icon(
        Icons.person,
        size: 100,
        color: Colors.grey.shade300,
      );
    }
    return FutureBuilder(
        future: PhotoStoreApi().downloadPhoto(photoId:profileViewModel.profilePhotoId!, scale: 0.8),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Icon(
              Icons.error,
              size: 100,
              color: Colors.red,
            );
          }
          return Image.memory(snapshot.data!);
        });
  }
}
