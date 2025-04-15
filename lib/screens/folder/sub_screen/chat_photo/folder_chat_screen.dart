import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../../../config/app_config.dart';
import 'folder_chat_bubble.dart';

class FolderChatScreen extends StatelessWidget {
  FolderChatScreen({super.key, required this.folderId});

  final int folderId;
  final TextEditingController _controller = TextEditingController();
  final profileViewModel = Get.find<ProfileViewModel>();
  final folderViewModel = Get.find<FolderViewModel>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // offset == 0이면 초기 상태로 간주
              if (folderViewModel.chatScrollController.hasClients &&
                  folderViewModel.chatScrollController.offset == 0) {
                folderViewModel.scrollToBottom();
              }
            });
            return ListView(
              controller: folderViewModel.chatScrollController,
              reverse: false,
              padding: const EdgeInsets.all(10),
              children: folderViewModel.currentMsgList.map((m) => ChatBubble(msg: m)).toList(),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onTap: () {
                    Future.delayed(Duration(milliseconds: 500), () {
                      folderViewModel.scrollToBottom();
                    });
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "메시지를 입력하세요...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppConfig.mainColor),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    final newMsg = ChatMsg(
                      content: _controller.text,
                      sendDatetime: DateTime.now().millisecondsSinceEpoch,
                      userId: UserManagerApi().ownerId!,
                      accountName: profileViewModel.accountName.value,
                    );
                    if (folderViewModel.currentSocket.value!.connected) {
                      // folderViewModel.folders[folderId]?.messages.add(newMsg);
                      folderViewModel.currentMsgList.add(newMsg);
                    }
                    folderViewModel.currentSocket.value?.sendChatMsg(newMsg);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
