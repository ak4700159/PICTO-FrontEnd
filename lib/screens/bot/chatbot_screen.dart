import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
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
                children: chatbotViewModel.currentMessages.map((m) => ChatbotBubble(msg: m)).toList(),
              );
            }),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  spreadRadius: 0,
                  blurRadius: 5.0,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // 사진이 있는 경우
                  MultiImagePickerView(controller: chatbotViewModel.imagePickerController,),
                  // 택스트폼 + 추가
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 30,),
                        onPressed: () {
                          // 사진 추가 최대 2장
                        },
                      ),
                      Expanded(
                        child: TextField(
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 500), () {
                              chatbotViewModel.scrollToBottom();
                            });
                          },
                          controller: chatbotViewModel.textEditorController,
                          decoration: InputDecoration(
                            hintText: "메시지를 입력하세요...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      // 추가 버튼은 안넣어도 될듯? submit 콜백 함수 활용
                      // IconButton(
                      //   icon: const Icon(Icons.send, color: Colors.black, size: 30),
                      //   onPressed: () {
                      //     // 챗봇 형식 정해야됨
                      //     if (chatbotViewModel.controller.text.isNotEmpty) {
                      //       // 채팅 추가
                      //       final newMsg = ChatbotMsg(
                      //           sendDatetime: DateTime.now().millisecondsSinceEpoch,
                      //           content: chatbotViewModel.controller.text,
                      //           isMe: true,
                      //           imagePath: []);
                      //       chatbotViewModel.sendMsg(newMsg);
                      //       chatbotViewModel.controller.clear();
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
