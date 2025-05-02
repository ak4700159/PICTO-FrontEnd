import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatbot_room.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';
import 'package:picto_frontend/utils/functions.dart';

class ChatbotRoomTile extends StatelessWidget {
  ChatbotRoomTile({required this.chatbotList, required this.isTitle, super.key, this.date});
  final bool isTitle;
  final String? date;
  final ChatbotRoom chatbotList;
  final chatbotViewModel = Get.find<ChatbotViewModel>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: isTitle ? _getTitle(context) : _getTile(),
    );
  }

  Widget _getTile() {
    return GestureDetector(
      onLongPress: () {
        chatbotViewModel.toggleIsDelete();
        chatbotViewModel.opacity.value = 0.3;
        Future.delayed(Duration(milliseconds: 400), () {
          chatbotViewModel.opacity.value = 1.0;
        });
      },
      child: Obx(() => AnimatedOpacity(
            duration: Duration(milliseconds: 400),
            opacity: chatbotViewModel.opacity.value,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4, // 흐림 정도
                    spreadRadius: 1, // 그림자 확산 정도
                    offset: Offset(2, 5), // 그림자 위치 조정
                  )
                ],
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        chatbotList.listName ??
                            formatDate(chatbotList.messages.first.sendDatetime)
                                .substring("0000-".length, "0000-00-00".length),
                        style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Text(
                      chatbotList.messages.isEmpty ? "  아직 채팅 내용이 없습니다" : chatbotList.messages.last.content,
                      style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w200, fontSize: 12),
                      maxLines: 3,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Obx(() => chatbotViewModel.isDelete.value
                          ? IconButton(
                              onPressed: () {
                                chatbotViewModel.removeChatbotRoom(chatbotList.createdDatetime);
                                // 클릭시 삭제
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 30,
                                color: Colors.red,
                              ))
                          : IconButton(
                              onPressed: () {
                                final chatbotViewModel = Get.find<ChatbotViewModel>();
                                chatbotViewModel.selectChatRoom(chatbotList.createdDatetime);
                                Get.toNamed('/chatbot');
                              },
                              icon: Icon(
                                Icons.meeting_room_outlined,
                                color: AppConfig.mainColor,
                                size: 30,
                              ))),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _getTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 12),
          width: context.mediaQuery.size.width * 0.95,
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                width: 2,
                color: Colors.grey,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                color: AppConfig.mainColor,
                size: 25,
              ),
              Text(
                "   $date 채팅",
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
