import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import '../../../config/app_config.dart';
import '../../../models/folder.dart';

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
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TopBox(size: 0.05),
          Row(
            children: [
              Icon(
                Icons.content_paste_outlined,
                color: AppConfig.mainColor,
              ),
              Text(
                " 폴더 내용",
                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
              ),
            ],
          ),
          Row(
            children: [
              Container(
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
                child: Text(folder.content ?? "폴더 내용이 없습니다.", style: TextStyle(fontFamily: "Roboto"),),
              ),
            ],
          ),
          TopBox(size: 0.05),
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppConfig.mainColor,
              ),
              Text(
                " 공유 인원",
                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
              ),
            ],
          ),
          Container(),
        ],
      ),
    );
  }
}
