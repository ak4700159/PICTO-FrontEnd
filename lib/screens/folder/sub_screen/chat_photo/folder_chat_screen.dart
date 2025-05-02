import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Column(
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
              Map<String, List<ChatMsg>> groupedChatMessages = folderViewModel.groupMessagesByDay();
              List<Widget> result = [];
              groupedChatMessages.forEach((String date, List<ChatMsg> messages) {
                result.add(_getDayTitleWidget(date, context));
                for (ChatMsg msg in messages) {
                  result.add(ChatBubble(msg: msg));
                }
              });
              return ListView(
                controller: folderViewModel.chatScrollController,
                reverse: false,
                padding: const EdgeInsets.all(10),
                // 이거 일자별로 그룹핑하는 함수 필요
                children: result,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      Future.delayed(Duration(milliseconds: 500), () {
                        folderViewModel.scrollToBottom();
                      });
                    },
                    controller: _controller,
                    minLines: 1,
                    maxLines: 10,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(9),
                      isDense: true,
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "메시지 입력",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        gapPadding: 0,
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
      ),
    );
  }

  Widget _getDayTitleWidget(String date, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(8),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontFamily: "NotoSansKR",
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
