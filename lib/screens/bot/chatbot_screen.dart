import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "Chat Bot",
            style: TextStyle(
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: AppConfig.mainColor,
            ),
          ),
          actions: [
            // if (chatbotViewModel.isDelete.value)
            //   IconButton(
            //     onPressed: () {
            //       // 챗봇 삭제?
            //     },
            //     icon: Icon(
            //       Icons.delete,
            //       color: Colors.red,
            //     ),
            //   )
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 대화 리스트
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
            // 텍스트 필드 + 사진 선택
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
                child: Obx(
                  () => chatbotViewModel.isSending.value
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(
                          children: [
                            // 사진 선택창
                            if (chatbotViewModel.isUp.value)
                              SizedBox(
                                height: context.mediaQuery.size.height * 0.18,
                                child: MultiImagePickerView(
                                  controller: chatbotViewModel.imagePickerController,
                                  builder: (BuildContext context, ImageFile imageFile) {
                                    final chatbotViewModel = Get.find<ChatbotViewModel>();
                                    chatbotViewModel.currentSelectedImages.clear();
                                    chatbotViewModel.currentSelectedImages
                                        .addAll(chatbotViewModel.imagePickerController.images);
                                    // print("[INFO] select ${chatbotViewModel.currentSelectedImages.length}");
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
                                    // height: context.mediaQuery.size.height * 0.05,
                                    child: TextField(
                                      minLines: 1,
                                      maxLines: 5,
                                      // 제한 없음 → 자동 줄바꿈에 따라 확장됨
                                      keyboardType: TextInputType.multiline,
                                      onTap: () {
                                        // 딜레이를 얼마나 주냐에 따라 내려가는 정도가 달라짐
                                        Future.delayed(Duration(milliseconds: 800), () {
                                          chatbotViewModel.scrollToBottom();
                                        });
                                      },
                                      controller: chatbotViewModel.textEditorController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(9),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.grey.shade300,
                                        // hintText: "메시지를 입력하세요.",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
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
                                        images: [],
                                        status: ChatbotStatus.isMe,
                                      );
                                      chatbotViewModel.sendMsg(newMsg);
                                      chatbotViewModel.textEditorController.clear();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
