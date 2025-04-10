import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Text(folderViewModel.getFolder(folderId: folderId)!.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: "갤러리"),
              Tab(text: "채팅"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FolderPhotoScreen(folderId: folderId,),
            FolderChatScreen(folderId: folderId),
          ],
        ),
      ),
    );
  }
}