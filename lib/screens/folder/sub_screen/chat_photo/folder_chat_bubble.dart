import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/functions.dart';

// 날짜 버블인지 확인할 것
class ChatBubble extends StatelessWidget {
  final ChatMsg msg;

  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    bool isMe = UserManagerApi().ownerId == msg.userId ? true : false;
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // 채팅 내역
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Icon(
                Icons.person_pin,
                color: getColorFromUserId(msg.userId),
                size: 30,
              ),
            if (isMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  formatDate(msg.sendDatetime).substring("0000-00-00".length),
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "Roboto"),
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppConfig.mainColor : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topRight: isMe ? Radius.circular(8) : Radius.circular(15),
                  topLeft: isMe ? Radius.circular(15) : Radius.circular(8),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white : AppConfig.mainColor,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (!isMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  formatDate(msg.sendDatetime).substring("0000-00-00".length),
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "Roboto"),
                ),
              )
          ],
        ),
      ],
    );
  }
}
