import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/util.dart';

class ChatbotBubble extends StatelessWidget {
  final ChatbotMsg msg;

  const ChatbotBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // 채팅 내역
        Container(
          // width: context.mediaQuery.size.width * 0.7,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: msg.isMe ? AppConfig.mainColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          child: msg.isMe
              ? Row(
                  mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.content,
                      style: TextStyle(
                          color: Colors.white, fontFamily: "Roboto", fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/pictory_color.png',
                          scale: 5,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "  ${msg.content}",
                        style: TextStyle(
                            color: Colors.black, fontFamily: "Roboto", fontWeight: FontWeight.bold),
                        overflow: TextOverflow.visible,
                        maxLines: 10,
                      ),
                    ),
                  ],
                ),
        ),
        // 채팅 날짜
        Text(
          formatDate(msg.sendDatetime).substring("0000-".length),
          style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "Roboto"),
        )
      ],
    );
  }
}
