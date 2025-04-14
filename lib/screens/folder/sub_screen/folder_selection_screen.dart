import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/folder/sub_screen/folder_selection_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/utils/util.dart';

import '../../../config/app_config.dart';
import '../../../models/folder.dart';

class FolderSelectionScreen extends StatelessWidget {
  const FolderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<FolderSelectionViewModel>();
    viewModel.setSelectionMode();
    return Scaffold(
      appBar: AppBar(
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
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold,
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
            height: context.mediaQuery.size.height * 0.5,
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
                      color: Colors.white,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
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
    // final folderSelectionViewModel = Get.find<FolderSelectionViewModel>();
    final folderList =
        folderViewModel.folders.values.map((folder) => _getFolderTile(folder, context)).toList();
    return folderList;
  }

  Widget _getFolderTile(Folder folder, BuildContext context) {
    var selectedPhotoId = Get.arguments["photoId"];
    folder.users.forEach((u) {
      print("[INFO[ ${u.userId} // ${folder.generatorId}");
    });
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
      child: Obx(() =>
          folderViewModel.folders[folder.folderId]!.photos.any((p) => p.photoId == selectedPhotoId)
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
                        ),
                        Text(
                          "[생성 시점] ${formatDate(folder.sharedDatetime)}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
                        ),
                        Text(
                          "[생성자 이메일] ${folder.users.firstWhere((u) => u.userId == folder.generatorId).email}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "[계정명] ${folder.users.firstWhere((u) => u.userId == folder.generatorId).accountName}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto"),
                    ),
                  ],
                )),
    );
  }
}
