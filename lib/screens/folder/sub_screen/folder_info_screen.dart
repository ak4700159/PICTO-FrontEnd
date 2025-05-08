import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/utils/functions.dart';
import '../../../config/app_config.dart';
import '../../../models/folder.dart';
import '../../../models/user.dart';

class FolderInfoScreen extends StatelessWidget {
  const FolderInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Folder folder = Get.arguments["folder"];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              color: AppConfig.mainColor,
              size: 30,
            ),
            Text(
              " ${folder.name} 폴더 정보",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: "NotoSansKR",
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 위쪽 여백
            TopBox(size: 0.02),
            // 폴더 내용 헤드
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.content_paste_outlined,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    " 폴더 내용",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "NotoSansKR",
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // 폴더 내용
            Row(
              // mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: context.mediaQuery.size.width,
                  height: context.mediaQuery.size.height * 0.2,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 8, // 흐림 정도
                        spreadRadius: 1, // 그림자 확산 정도
                        offset: Offset(2, 5), // 그림자 위치 조정
                      )
                    ],
                    color: Colors.white,
                  ),
                  child: Text(
                    folder.content ?? "폴더 내용이 없습니다.",
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600, // Bold
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            TopBox(size: 0.05),
            // 공유 인원 헤드
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    " 공유 인원(${folder.users.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "NotoSansKR",
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // 공유 인원
            Container(
              width: context.mediaQuery.size.width,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8, // 흐림 정도
                    spreadRadius: 1, // 그림자 확산 정도
                    offset: Offset(2, 5), // 그림자 위치 조정
                  )
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getSharedPerson(context),
              ),
            ),
            TopBox(size: 0.05),
            // 기타정보
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: AppConfig.mainColor,
                  ),
                  Text(
                    " 기타 정보",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "NotoSansKR",
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: context.mediaQuery.size.width,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8, // 흐림 정도
                    spreadRadius: 1, // 그림자 확산 정도
                    offset: Offset(2, 5), // 그림자 위치 조정
                  )
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '생성일 : ${formatDate(folder.sharedDatetime)}',
                    style: TextStyle(fontFamily: 'NotoSansKR', fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  Text(
                    '생성자 : ${folder.getUser(folder.generatorId)!.name}',
                    style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w600, // Bold
                        fontSize: 12),
                  ),
                  Text(
                    '사진수 : ${folder.photos.length}장',
                    style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w600, // Bold
                        fontSize: 12),
                  ),
                  Text(
                    '채팅수 : ${folder.messages.length}개',
                    style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w600, // Bold
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getSharedPerson(BuildContext context) {
    Folder folder = Get.arguments["folder"];
    return folder.users
        .map(
          (u) => Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                // 사용자 프로필
                _getUserProfile(context: context, user: u),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  [계정명]  ${u.name}",
                      style: TextStyle(
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w600, // Bold
                          fontSize: 12),
                    ),
                    Text(
                      "  [이메일]  ${u.email}",
                      style: TextStyle(
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w600, // Bold
                          fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _getUserProfile({required User user, required BuildContext context}) {
    if (user.userProfileId == null || user.userProfileData == null) {
      return Icon(
        Icons.person,
        color: getColorFromUserId(user.userId!),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.memory(
        user.userProfileData!,
        fit: BoxFit.cover,
        height: context.mediaQuery.size.width * 0.08,
        width: context.mediaQuery.size.width * 0.08,
      ),
    );
  }
}
