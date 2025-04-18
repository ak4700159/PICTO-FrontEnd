import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/models/chatbot_room.dart';
import 'package:picto_frontend/screens/bot/chatbot_bubble.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';
import 'package:picto_frontend/screens/main_frame_view_model.dart';

import '../../config/app_config.dart';
import '../../services/user_manager_service/user_api.dart';
import '../profile/profile_view_model.dart';

class ChatbotScreen extends StatelessWidget {
  ChatbotScreen({super.key});

  final profileViewModel = Get.find<ProfileViewModel>();
  final chatbotViewModel = Get.find<ChatbotViewModel>();

  // ChatbotRoom chatbotRoom = Get.arguments["list"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Chat Bot",
          style: TextStyle(
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w800,
            fontSize: 25,
            color: AppConfig.mainColor,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // offset == 0이면 초기 상태로 간주
                if (chatbotViewModel.chatScrollController.hasClients &&
                    chatbotViewModel.chatScrollController.offset == 0) {
                  chatbotViewModel.scrollToBottom();
                }
              });
              return ListView(
                controller: chatbotViewModel.chatScrollController,
                reverse: false,
                padding: const EdgeInsets.all(10),
                children:
                    chatbotViewModel.currentMessages.map((m) => ChatbotBubble(msg: m)).toList(),
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
                        chatbotViewModel.scrollToBottom();
                      });
                    },
                    controller: chatbotViewModel.controller,
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
                    // 챗봇 형식 정해야됨
                    if (chatbotViewModel.controller.text.isNotEmpty) {
                      // 채팅 추가
                      final newMsg = ChatbotMsg(
                          sendDatetime: DateTime.now().millisecondsSinceEpoch,
                          content: chatbotViewModel.controller.text,
                          isMe: true,
                          imagePath: []);
                      chatbotViewModel.sendMsg(newMsg);
                      chatbotViewModel.controller.clear();
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
}
