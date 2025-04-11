import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/utils/popup.dart';

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
            icon: const Icon(Icons.more_vert, color: AppConfig.mainColor),
            onSelected: (value) {
              switch (value) {
                case "delete":
                  break;
                case "notify":
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "delete",
                onTap: _showFolderDeleteCheck,
                child: const Text(
                  "폴더 삭제",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem(
                value: "send",
                onTap: _showFolderInvitationSend,
                child: Text(
                  "초대 알림 전송",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
            FolderPhotoScreen(folderId: folderId),
            FolderChatScreen(folderId: folderId),
          ],
        ),
      ),
    );
  }

  _showFolderDeleteCheck() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.delete),
            Text(
              "폴더 삭제",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text("폴더를 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () async {
              bool isSuccess = await FolderManagerApi().removeFolder(folderId: folderId);
              Get.back();
              if (isSuccess) {
                showPositivePopup("폴더가 삭제되었습니다");
                Get.offNamed('/map');
              } else {
                showErrorPopup("서버 오류 발생(삭제 실패)");
              }
            },
            child: Text("네"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("아니요"),
          ),
        ],
      ),
    );
  }

  // 고민중...
  _showFolderInvitationSend() {
    Get.dialog(AlertDialog(
      content: Column(

      ),
    ));
  }
}
