import 'package:flutter/material.dart';

import 'sub_screen/folder_chat_screen.dart';
import 'sub_screen/folder_photo_screen.dart';

class FolderFrame extends StatelessWidget {
  const FolderFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PICTO"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "공유된 사진"),
              Tab(text: "채팅"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FolderPhotoScreen(),
            FolderChatScreen(),
          ],
        ),
      ),
    );
  }
}