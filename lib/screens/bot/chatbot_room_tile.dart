import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatbot_room.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';
import 'package:picto_frontend/utils/util.dart';

class ChatbotRoomTile extends StatelessWidget {
  const ChatbotRoomTile({required this.chatbotList, super.key});

  final ChatbotRoom chatbotList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
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
            // Icon(
            //   Icons.contact_page,
            //   color: getColorFromUserId(chatbotList.createdDatetime),
            // ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  chatbotList.listName ?? "${formatDate(chatbotList.messages.first.sendDatetime).substring("0000-".length, "0000-00-00".length)}",
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
                child: IconButton(
                    onPressed: () {
                      final chatbotViewModel = Get.find<ChatbotViewModel>();
                      chatbotViewModel.selectChatRoom(chatbotList.createdDatetime);
                      Get.toNamed('/chatbot');
                    },
                    icon: Icon(
                      Icons.meeting_room_outlined,
                      color: AppConfig.mainColor,
                      size: 30,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
