import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatMsg {
  final String accountName;
  final String content;
  final int sendDatetime;
  final int userId;

  ChatMsg({
    required this.content,
    required this.accountName,
    required this.sendDatetime,
    required this.userId,
  });

  factory ChatMsg.fromJson(Map<String, dynamic> json) {
    return ChatMsg(
      userId: json['userId'],
      sendDatetime: json['sendDatetime'],
      accountName: json['accountName'],
      content: json['content'],
    );
  }

  factory ChatMsg.fromFrame(StompFrame frame) {
    final data = jsonDecode(frame.body!);
    return ChatMsg(
      userId: data["userId"],
      sendDatetime: data['sendDatetime'],
      accountName: data['accountName'],
      content: data['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "sendDatetime": sendDatetime,
      "accountName": accountName,
      "content": content,
    };
  }
}
