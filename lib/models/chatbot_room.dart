import 'package:hive/hive.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';

part "chatbot_room.g.dart";

@HiveType(typeId: 0)
class ChatbotRoom {
  @HiveField(0)
  List<ChatbotMsg> messages = [];
  @HiveField(1)
  int createdDatetime;
  @HiveField(2)
  String? listName;
  ChatbotRoom({required this.createdDatetime});
}