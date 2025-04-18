import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/screens/bot/chatbot_bubble.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';

import '../../config/app_config.dart';
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
                addAutomaticKeepAlives: false,
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
              child: Obx(() => Column(
                    children: [
                      // 사진이 있는 경우
                      if (chatbotViewModel.isUp.value)
                        SizedBox(
                          height: context.mediaQuery.size.height * 0.18,
                          child: MultiImagePickerView(
                            controller: chatbotViewModel.imagePickerController,
                            builder: (BuildContext context, ImageFile imageFile) {
                              // here returning DefaultDraggableItemWidget. You can also return your custom widget as well.
                              return DefaultDraggableItemWidget(
                                imageFile: imageFile,
                                boxDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                                closeButtonAlignment: Alignment.topLeft,
                                fit: BoxFit.cover,
                                closeButtonIcon: const Icon(Icons.delete_rounded, color: Colors.red),
                                closeButtonBoxDecoration: null,
                                showCloseButton: true,
                                closeButtonMargin: const EdgeInsets.all(3),
                                closeButtonPadding: const EdgeInsets.all(3),
                              );
                            },
                            // 아무 사진도 선택되지 않았을 때 사진
                            initialWidget: DefaultInitialWidget(
                              height: context.mediaQuery.size.height * 0.15,
                              width: context.mediaQuery.size.width * 0.9,
                              centerWidget: Icon(Icons.image_search_outlined),
                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                              margin: EdgeInsets.zero,
                            ),
                            // 최대 사진까지 추가 버튼
                            addMoreButton: DefaultAddMoreWidget(
                              icon: Icon(
                                Icons.image_search_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              backgroundColor: AppConfig.mainColor,
                            ), // Use any Widget or DefaultAddMoreWidget. Use null to hide add more button.
                          ),
                        ),
                      // 입력 필드 영역
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              chatbotViewModel.isUp.value ? Icons.arrow_circle_down : Icons.arrow_circle_up,
                              color: Colors.black,
                              size: 25,
                            ),
                            onPressed: () {
                              chatbotViewModel.toggleIsUp();
                            },
                          ),
                          Expanded(
                            child: SizedBox(
                              height: context.mediaQuery.size.height * 0.06,
                              child: TextField(
                                maxLines: 10,
                                onTap: () {
                                  Future.delayed(Duration(milliseconds: 500), () {
                                    chatbotViewModel.scrollToBottom();
                                  });
                                },
                                controller: chatbotViewModel.textEditorController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade300,
                                  // hintText: "메시지를 입력하세요.",
                                  border: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 추가 버튼은 안넣어도 될듯? submit 콜백 함수 활용
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.black, size: 25),
                            onPressed: () {
                              // 챗봇 형식 정해야됨
                              if (chatbotViewModel.textEditorController.text.isNotEmpty) {
                                // 채팅 추가 일단 오케이
                                final newMsg = ChatbotMsg(
                                    sendDatetime: DateTime.now().millisecondsSinceEpoch,
                                    content: chatbotViewModel.textEditorController.text,
                                    isMe: true,
                                    imagePath: []);
                                chatbotViewModel.sendMsg(newMsg);
                                chatbotViewModel.textEditorController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
