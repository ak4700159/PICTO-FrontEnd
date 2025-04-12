import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';

import '../../config/app_config.dart';
import '../../models/folder.dart';
import '../../services/user_manager_service/user_api.dart';
import '../profile/profile_view_model.dart';

class FolderListScreen extends StatelessWidget {
  const FolderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Get.find<ProfileViewModel>();
    final folderViewModel = Get.find<FolderViewModel>();
    folderViewModel.initFolder();
    return Scaffold(
      appBar: AppBar(
        // shape: BeveledRectangleBorder(side: BorderSide(width: 0.5)),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${profileViewModel.accountName.value}의 폴더 목록",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                _showFolderEventList(context);
              },
              icon: Icon(
                Icons.menu,
                color: AppConfig.mainColor,
              )),
          // 드롭박스 버튼 추가
          // 폴더 생성 , 삭제 , 폴더 초대 확인(수락 및 거절)
        ],
      ),
      body: Obx(() => GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: folderViewModel.folders.keys.length,
            itemBuilder: (context, index) {
              return _getFolderWidget(folderViewModel.folders.keys.toList()[index]);
            },
          )),
    );
  }

  // 폴더 이벤트 다이얼로그
  void _showFolderEventList(BuildContext context) {
    List<String> items = ["폴더 생성", "초대 알림 확인"];
    // final width = context.mediaQuery.size.width * 0.4;
    // final height = context.mediaQuery.size.height * 0.8;
    Get.dialog(
      AlertDialog(
          // insetPadding: EdgeInsets.all(2),
          backgroundColor: Colors.white,
          scrollable: true,
          title: Row(
            children: [
              Icon(
                Icons.folder_open,
                color: AppConfig.mainColor,
                weight: 10,
              ),
              Text(
                "  기능",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ],
          ),
          content: Container(
            height: context.mediaQuery.size.height * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: switch (idx) {
                      0 => () {
                          Get.back();
                          Get.toNamed('/folder/create');
                        },
                      1 => () {
                        Get.back();
                        Get.toNamed('/folder/invite');
                      },
                      2 => () {
                        Get.back();

                      },
                      _ => () {}
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          // border: Border.all(width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ]),
                      child: Center(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _getFolderIcon(idx),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                items[idx],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: items.length,
            ),
          )),
    );
  }

  // 폴더 메뉴 아이콘
  Widget _getFolderIcon(int idx) {
    return switch (idx) {
      0 => Icon(
          Icons.create_new_folder_rounded,
          color: AppConfig.mainColor,
        ),
      1 => Icon(
          Icons.email,
          color: AppConfig.mainColor,
        ),
      2 => Icon(
          Icons.folder_shared,
          color: AppConfig.mainColor,
        ),
      _ => Icon(Icons.hourglass_empty),
    };
  }

  // 폴더 위젯
  Widget _getFolderWidget(Folder folder) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () async {
              // 폴더 사진 화면 이동
              final folderViewModel = Get.find<FolderViewModel>();
              folderViewModel.changeFolder(folderId: folder.folderId);
              folderViewModel.changeSocket();
              print("[INFO] target folder Id : ${folder.folderId}");
              Get.toNamed('/folder', arguments: {
                "folderId": folder.folderId,
              });
            },
            icon: Icon(
              Icons.folder,
              color: folder.generatorId == UserManagerApi().ownerId
                  ? AppConfig.mainColor
                  : Colors.white,
              weight: 1,
              size: 60,
            ),
          ),
          Text(
            folder.name,
            style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
