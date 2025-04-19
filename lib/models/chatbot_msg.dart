import 'package:hive/hive.dart';
import 'package:picto_frontend/models/photo_data.dart';


part "chatbot_msg.g.dart";

@HiveType(typeId: 1)
class ChatbotMsg {
  @HiveField(0)
  int sendDatetime;
  @HiveField(1)
  String content;
  @HiveField(2)
  bool isMe;
  @HiveField(3)
  List<PhotoData> images = [];
  ChatbotMsg({required this.sendDatetime, required this.content, required this.isMe, required this.images});
}
