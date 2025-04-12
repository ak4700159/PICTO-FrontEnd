import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/util.dart';

class ChatBubble extends StatelessWidget {
  final ChatMsg msg;

  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    bool isMe = UserManagerApi().ownerId == msg.userId ? true : false;
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start  ,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? AppConfig.mainColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          child: isMe
              ? Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.content,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_pin,
                      color: getColorFromUserId(msg.userId),
                    ),
                    Text(
                      "  ${msg.content}",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
        ),
        Text(
          formatDate(msg.sendDatetime).substring("0000-".length),
          style: TextStyle(fontSize: 10, color: Colors.grey),
        )
      ],
    );
  }
}
