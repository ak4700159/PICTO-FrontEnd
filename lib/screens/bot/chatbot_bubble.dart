import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
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
        msg.isMe
            ? Row(
                mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 사진 있으면 사진 처리
                  Container(
                    margin: EdgeInsets.all(4),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color:Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(color: AppConfig.mainColor, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 사진 있으면 사진 처리
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration:
                                BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(100)),
                            child: Image.asset(
                              'assets/images/pictory_color.png',
                              scale: 5,
                            ),
                          ),
                          Text(
                            "PICTORY",
                            style: TextStyle(
                                color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: msg.isMe ? Colors.grey : AppConfig.mainColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(color: Colors.white, fontFamily: "NotoSansKR", fontWeight: FontWeight.w500),
                            overflow: TextOverflow.visible,
                            maxLines: 10,
                          ),
                        ),
                        // 채팅 날짜
                        Text(
                          formatDate(msg.sendDatetime).substring("0000-".length),
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "NotoSansKR"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
