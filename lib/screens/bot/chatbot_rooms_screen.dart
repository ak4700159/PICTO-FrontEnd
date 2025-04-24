import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/bot/chatbot_room_tile.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';

import '../../config/app_config.dart';

class ChatbotListScreen extends StatelessWidget {
  const ChatbotListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatbotViewModel = Get.find<ChatbotViewModel>();
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text(
            "PICTORY",
            style: TextStyle(
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w800,
              fontSize: 25,
              color: AppConfig.mainColor,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        body: Obx(() => chatbotViewModel.chatbotRooms.isEmpty
            ? _getFirstScreen(context)
            : SizedBox(
                width: context.mediaQuery.size.width,
                // height: context.mediaQuery.size.height * 0.6,
                child: SingleChildScrollView(
                  child: Obx(() => Column(
                        children: _getChatRoomTileList(),
                      )),
                ),
              )),
      ),
      Positioned(
        bottom: context.mediaQuery.size.height * 0.1,
        left: context.mediaQuery.size.width * 0.85,
        child: SizedBox(
          width: context.mediaQuery.size.width * 0.15,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _getBottomRightFloatingButtons(context),
          ),
        ),
      ),
    ]);
  }

  Widget _getFirstScreen(BuildContext context) {
    final chatbotViewModel = Get.find<ChatbotViewModel>();
    return Column(
      children: [
        TopBox(size: 0.2),
        Center(
          child: SizedBox(
            width: context.mediaQuery.size.width * 0.7,
            child: FloatingActionButton(
              backgroundColor: AppConfig.mainColor,
              onPressed: () {
                chatbotViewModel.addChatbotRoom();
              },
              child: Text(
                "새로운 채팅방 생성",
                style: TextStyle(
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getChatRoomTileList() {
    List<Widget> result = [];
    final chatbotViewModel = Get.find<ChatbotViewModel>();
    final grouped = chatbotViewModel.groupChatbotRoomsByMonth();
    grouped.forEach((month, roomList) {
      result.add(ChatbotRoomTile(chatbotList: roomList.first, isTitle: true, date: month));
      for (final room in roomList) {
        result.add(ChatbotRoomTile(chatbotList: room, isTitle: false));
      }
    });
    return result;
  }

  List<Widget> _getBottomRightFloatingButtons(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: context.mediaQuery.size.height * 0.06,
          child: FloatingActionButton(
            onPressed: () {
              final chatbotViewModel = Get.find<ChatbotViewModel>();
              chatbotViewModel.addChatbotRoom();
            },
            backgroundColor: Colors.blueAccent,
            heroTag: "room-create",
            child: Icon(
              Icons.add,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
    ];
  }
}
