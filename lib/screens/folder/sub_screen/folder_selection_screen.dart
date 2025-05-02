import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/folder/sub_screen/folder_selection_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/utils/functions.dart';

import '../../../config/app_config.dart';
import '../../../models/folder.dart';

class FolderSelectionScreen extends StatelessWidget {
  FolderSelectionScreen({super.key});

  final selectedPhotoId = Get.arguments["photoId"];

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<FolderSelectionViewModel>();
    viewModel.setSelectionMode();
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.folder_copy,
              color: AppConfig.mainColor,
            ),
            Text(
              "  폴더 선택 후 복사",
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // 컬럼 안에 컬럼이 있는 이유는 그러게
          TopBox(size: 0.05),
          SizedBox(
            height: context.mediaQuery.size.height * 0.65,
            child: SingleChildScrollView(
              child: Column(
                children: _getFolderList(context),
              ),
            ),
          ),
          TopBox(size: 0.05),
          SizedBox(
            width: context.mediaQuery.size.width * 0.8,
            child: FloatingActionButton(
              onPressed: () {
                viewModel.copyPhoto(photoId: Get.arguments["photoId"]);
              },
              backgroundColor: AppConfig.mainColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.drive_file_move,
                    color: Colors.white,
                  ),
                  Text(
                    "   복사",
                    style: TextStyle(
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getFolderList(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    final folders = folderViewModel.folders.values.toList();

    // 1. 정렬 기준에 따라 정렬
    folders.sort((a, b) {
      // "default" 폴더는 항상 최상단
      if (a.name == "default") return -1;
      if (b.name == "default") return 1;

      // 이미 사진이 존재하는 폴더는 상위로
      bool aHasPhoto = folderViewModel.isPhotoInFolder(folderId: a.folderId, photoId: selectedPhotoId);
      bool bHasPhoto = folderViewModel.isPhotoInFolder(folderId: b.folderId, photoId: selectedPhotoId);

      if (aHasPhoto && !bHasPhoto) return -1;
      if (!aHasPhoto && bHasPhoto) return 1;

      // 그 외는 이름 기준 오름차순
      return a.name.compareTo(b.name);
    });

    return folders.map((folder) => _getFolderTile(folder, context)).toList();
  }

  Widget _getFolderTile(Folder folder, BuildContext context) {
    final folderSelectionViewModel = Get.find<FolderSelectionViewModel>();
    final folderViewModel = Get.find<FolderViewModel>();
    return Container(
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
      child: Obx(() => !folderViewModel.isPhotoInFolder(folderId: folder.folderId, photoId: selectedPhotoId)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      // 폴더 정보 화면으로 이동
                      Get.toNamed('/folder/info', arguments: {
                        "folder": folder,
                      });
                    },
                    icon: Icon(
                      Icons.info,
                      color: AppConfig.mainColor,
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "[폴더명] ${folder.name}",
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "[생성 시점] ${formatDate(folder.sharedDatetime)}",
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "[생성자 이메일] ${folder.getUser(folder.generatorId)?.email}",
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "[생성자 계정명] ${folder.getUser(folder.generatorId)?.accountName}",
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Checkbox(
                  value: folderSelectionViewModel.selectedList[folder.folderId],
                  onChanged: (val) {
                    folderSelectionViewModel.selectedList[folder.folderId] = val!;
                  },
                ),
              ],
            )
          : Row(
              children: [
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(Icons.folder_open),
                //   color: AppConfig.mainColor,
                // ),
                Text(
                  " ${folder.name} 에는 사진이 존재합니다.",
                  style: TextStyle(
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            )),
    );
  }
}
