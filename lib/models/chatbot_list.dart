import 'package:hive/hive.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';

part "chatbot_list.g.dart";

@HiveType(typeId: 0)
class ChatbotList {
  @HiveField(0)
  List<ChatbotMsg> messages = [];
  @HiveField(1)
  int createdDatetime;
  @HiveField(2)
  String? listName;
  ChatbotList({required this.createdDatetime});
}