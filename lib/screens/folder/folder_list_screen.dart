import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';

import '../../config/app_config.dart';
import '../../models/folder.dart';
import '../../services/user_manager_service/user_api.dart';
import '../profile/profile_view_model.dart';

class FolderListScreen extends StatelessWidget {
  FolderListScreen({super.key});

  final profileViewModel = Get.find<ProfileViewModel>();
  final folderViewModel = Get.find<FolderViewModel>();

  @override
  Widget build(BuildContext context) {
    // if (!folderViewModel.isUpdate.value) {
    // folderViewModel.resetFolder();
    //   folderViewModel.isUpdate.value = true;
    // }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 1,
        backgroundColor: Colors.white,
        // 제목
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            padding: EdgeInsets.all(4),
            // decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
            child: Obx(() => Text(
              "${profileViewModel.accountName.value}의 폴더",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            )),
          ),
        ),
        automaticallyImplyLeading: false,
        // 메뉴 버튼
        actions: [
          PopupMenuButton<String>(
            padding: EdgeInsets.all(0),
            menuPadding: EdgeInsets.all(0),
            color: Colors.white,
            icon: const Icon(Icons.more_vert, color: AppConfig.mainColor),
            onSelected: (value) {
              switch (value) {
                case "create":
                  break;
                case "invite":
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.all(4),
                value: "create",
                onTap: () {
                  Get.back();
                  Get.toNamed('/folder/create');
                },
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder, color: AppConfig.mainColor),
                    const Text(
                      "  폴더 생성",
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
                value: "invite",
                padding: EdgeInsets.all(4),
                onTap: () {
                  Get.back();
                  Get.toNamed('/folder/invite');
                },
                child: Row(
                  children: [
                    Icon(Icons.mail_lock, color: AppConfig.mainColor),
                    Text(
                      "  초대 알림 확인",
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
      ),
      body: Obx(() => _getFolderList(context)),
    );
  }

  // 폴더 위젯
  Widget _getFolderWidget(Folder folder) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              // 폴더 사진 화면 이동
              final folderViewModel = Get.find<FolderViewModel>();
              folderViewModel.changeFolder(folderId: folder.folderId);
              Get.toNamed('/folder', arguments: {
                "folderId": folder.folderId,
              });
            },
            icon: Icon(
              _getFolderIcon(folder.generatorId, folder.name),
              color: _getFolderColor(folder.generatorId, folder.name),
              weight: 1,
              size: 60,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: Text(
              folder.name,
              style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFolderIcon(int generatorId, String folderName) {
    if (folderName == "default") {
      return Icons.person;
    } else if (UserManagerApi().ownerId == generatorId) {
      return Icons.folder;
    }
    return Icons.folder;
  }

  Color _getFolderColor(int generatorId, String folderName) {
    if (folderName == "default") {
      return Colors.black;
    } else if (generatorId == UserManagerApi().ownerId) {
      return AppConfig.mainColor;
    }
    return Colors.blue;
  }

  Widget _getFolderList(BuildContext context) {
    Map<String, List<Folder>> notOrderedFolders = folderViewModel.getPartitionedFolders();
    List<Folder> myFolders = notOrderedFolders["my"]!;
    List<Folder> sharedFolders = notOrderedFolders["shared"]!;
    double height = context.mediaQuery.size.height;
    double width = context.mediaQuery.size.width;

    return SingleChildScrollView(
      child: RefreshIndicator(
        displacement: 20,
        backgroundColor: Colors.white,
        color: AppConfig.mainColor,
        onRefresh: () async {
          await folderViewModel.resetFolder(init: false);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.4,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: myFolders.length,
                itemBuilder: (context, index) {
                  // List<Folder> folders = folderViewModel.folders.values.toList();
                  myFolders.sort((a, b) => a.sharedDatetime.compareTo(b.sharedDatetime));
                  return _getFolderWidget(myFolders[index]);
                },
              ),
            ),
            // SizedBox(
            //   height: height * 0.05,
            // ),
            Container(
              padding: EdgeInsets.all(20),
              height: 3.0,
              width: width * 0.8,
              color: Colors.grey.shade200,
            ),
            SizedBox(
              height: height * 0.4,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: sharedFolders.length,
                itemBuilder: (context, index) {
                  // List<Folder> folders = folderViewModel.folders.values.toList();
                  sharedFolders.sort((a, b) => a.sharedDatetime.compareTo(b.sharedDatetime));
                  return _getFolderWidget(sharedFolders[index]);
                },
              ),
            ),
            SizedBox(
              height: height * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}
