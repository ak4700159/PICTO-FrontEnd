import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/functions.dart';

// 날짜 버블인지 확인할 것
class ChatBubble extends StatelessWidget {
  final ChatMsg msg;
  final folderViewModel = Get.find<FolderViewModel>();

  ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    bool isMe = UserManagerApi().ownerId == msg.userId ? true : false;
    return isMe ? _getMyChat(msg) : _getOtherChat(msg, context);
  }

  Widget _getMyChat(ChatMsg msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            formatDate(msg.sendDatetime).substring("0000-00-00".length),
            style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "NotoSansKR"),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConfig.mainColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            msg.content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getOtherChat(ChatMsg msg, BuildContext context) {
    Uint8List? profile = folderViewModel.getOtherProfilePhoto(userId: msg.userId);
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              // 사용자 프로픨
              profile != null
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.memory(
                          profile,
                          fit: BoxFit.cover,
                          height: context.mediaQuery.size.width * 0.1,
                          width: context.mediaQuery.size.width * 0.1,
                        ),
                      ),
                  )
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.person_pin,
                        color: getColorFromUserId(msg.userId),
                        size: 35,
                      ),
                    ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.accountName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w300,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                      fontSize: 12, color: Colors.white, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  formatDate(msg.sendDatetime).substring("0000-00-00".length),
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "NotoSansKR"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
