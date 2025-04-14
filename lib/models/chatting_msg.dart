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
      sendDatetime:
          json['sendDatetime'] < 10000000000 ? json['sendDatetime'] * 1000 : json['sendDatetime'],
      accountName: json['accountName'],
      content: json['content'],
    );
  }

  factory ChatMsg.fromFrame(StompFrame frame) {
    final data = jsonDecode(frame.body!);
    return ChatMsg(
      userId: data["userId"],
      sendDatetime:
          data['sendDatetime'] < 10000000000 ? data['sendDatetime'] * 1000 : data['sendDatetime'],
      accountName: data['accountName'],
      content: data['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "senderId": userId,
      "sendDatetime": sendDatetime,
      "accountName": accountName,
      "content": content,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMsg &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          sendDatetime == other.sendDatetime &&
          content == other.content);

  @override
  int get hashCode => "$userId/$sendDatetime/$content".hashCode;
}
