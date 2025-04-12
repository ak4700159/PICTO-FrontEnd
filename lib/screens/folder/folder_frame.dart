import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/folder/sub_screen/chat_photo/folder_chat_screen.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import 'sub_screen/chat_photo/folder_photo_screen.dart';

class FolderFrame extends StatelessWidget {
  FolderFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final int folderId = Get.arguments["folderId"];
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
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              icon: const Icon(Icons.more_vert, color: AppConfig.mainColor),
              onSelected: (value) {
                switch (value) {
                  case "delete":
                    break;
                  case "notify":
                    break;
                  case "share" :
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "delete",
                  onTap: _showFolderDeleteCheck,
                  child: Row(
                    children: [
                      Icon(Icons.folder_delete),
                      const Text(
                        " 폴더 삭제",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "send",
                  onTap: () => Get.toNamed('/folder/invite/send', arguments: {"folderId": folderId}),
                  child: Row(
                    children: [
                      Icon(Icons.send),
                      Text(
                        " 초대 알림 전송",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "share",
                  // onTap: () => Get.toNamed('/folder/invite/send', arguments: {"folderId": folderId}),
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      Text(
                        " 폴더 공유 정보",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
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
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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

  // 폴더 삭제 팝업
  _showFolderDeleteCheck() {
    final int folderId = Get.arguments["folderId"];
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
        content: Text(
          "폴더를 삭제하시겠습니까?",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final folderViewModel = Get.find<FolderViewModel>();
              if (folderViewModel.getFolder(folderId: folderId)!.name == "default") {
                Get.back();
                showErrorPopup("기본 폴더는 삭제할 수 없습니다.");
                return;
              }

              bool isSuccess = await FolderManagerApi().removeFolder(folderId: folderId);
              Get.back();
              Get.back();
              if (isSuccess) {
                Get.find<FolderViewModel>().initFolder();
                showPositivePopup("폴더가 삭제되었습니다");
              } else {
                showErrorPopup("서버 오류 발생(삭제 실패)");
              }
            },
            child: Text(
              "네",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              "아니요",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
