import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/folder/sub_screen/chat_photo/folder_chat_screen.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import 'sub_screen/chat_photo/folder_photo_screen.dart';

class FolderFrame extends StatelessWidget {
  const FolderFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final int folderId = Get.arguments["folderId"];
    final folderViewModel = Get.find<FolderViewModel>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              folderViewModel.getFolder(folderId: folderId)!.name,
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConfig.mainColor,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              padding: EdgeInsets.all(0),
              menuPadding: EdgeInsets.all(0),
              color: Colors.white,
              icon: const Icon(Icons.more_vert, color: AppConfig.mainColor),
              onSelected: (value) {
                switch (value) {
                  case "delete":
                    break;
                  case "notify":
                    break;
                  case "info":
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "delete",
                  padding: EdgeInsets.all(4),
                  onTap: () {
                    _showFolderDeleteCheck(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_delete,
                        color: AppConfig.mainColor,
                      ),
                      const Text(
                        " 폴더 삭제",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "send",
                  padding: EdgeInsets.all(4),
                  onTap: () =>
                      Get.toNamed('/folder/invite/send', arguments: {"folderId": folderId}),
                  child: Row(
                    children: [
                      Icon(
                        Icons.send,
                        color: AppConfig.mainColor,
                      ),
                      Text(
                        " 초대 알림 전송",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "info",
                  padding: EdgeInsets.all(4),
                  onTap: () => Get.toNamed('/folder/info',
                      arguments: {"folder": folderViewModel.currentFolder.value}),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: AppConfig.mainColor,
                      ),
                      Text(
                        " 폴더 정보",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w600,
                        ),
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
            indicator: BoxDecoration(
              color: AppConfig.mainColor,
            ),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontFamily: "NotoSansKR",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            tabs: [
              Tab(text: "저장된 사진"),
              Tab(text: "채팅"),
            ],
            onTap: (idx) {},
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
  _showFolderDeleteCheck(BuildContext context) {
    final int folderId = Get.arguments["folderId"];
    final folderViewModel = Get.find<FolderViewModel>();
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
                  "폴더를 삭제하시겠습니까?",
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
                SizedBox(
                  width: width * 0.7,
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
                              "네",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () async {
                              if (folderViewModel.getFolder(folderId: folderId)!.name ==
                                  "default") {
                                Get.back();
                                showErrorPopup("기본 폴더는 삭제할 수 없습니다.");
                                return;
                              }
                              bool isSuccess =
                                  await FolderManagerApi().removeFolder(folderId: folderId);
                              Get.back();
                              Get.back();
                              if (isSuccess) {
                                Get.find<FolderViewModel>().resetFolder(init: false);
                                showPositivePopup("폴더가 삭제되었습니다");
                              } else {
                                showErrorPopup("서버 오류 발생(삭제 실패)");
                              }
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
                              "아니요",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
