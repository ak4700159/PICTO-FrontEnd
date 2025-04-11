import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';

import 'sub_screen/folder_chat_screen.dart';
import 'sub_screen/folder_photo_screen.dart';

class FolderFrame extends StatelessWidget {
  FolderFrame({super.key});

  final int folderId = Get.arguments["folderId"];

  @override
  Widget build(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              folderViewModel.getFolder(folderId: folderId)!.name,
              style: TextStyle(color: AppConfig.mainColor),
            ),
          ),
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.purple),
            onSelected: (value) {
              switch (value) {
                case "delete":
                  break;
                case "notify":
                  break;
                case "send":
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "create", child: Text("폴더 생성")),
              const PopupMenuItem(value: "delete", child: Text("폴더 삭제")),
              const PopupMenuItem(value: "send", child: Text("초대 알림 전송")),
            ],
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.grey,
            labelPadding: EdgeInsets.all(8),
            indicatorPadding: EdgeInsets.all(8),
            indicator: BoxDecoration(
              color: AppConfig.mainColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "저장된 사진"),
              Tab(text: "채팅"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FolderPhotoScreen(
              folderId: folderId,
            ),
            FolderChatScreen(folderId: folderId),
          ],
        ),
      ),
    );
  }
}
