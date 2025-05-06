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
  @HiveField(4)
  ChatbotStatus status;

  ChatbotMsg({required this.sendDatetime, required this.content, required this.isMe, required this.images, required this.status});
}

@HiveType(typeId: 3)
enum ChatbotStatus{
  // 메시지 전송 중
  @HiveField(0)
  sending,
  // 내가 보낸 메시지
  // --픽토리 대답-- //
  @HiveField(1)
  isMe,
  // 비교 응답
  @HiveField(2)
  compare,
  // 분석 응답
  @HiveField(3)
  analysis,
  // 추천 응답
  @HiveField(4)
  recommend,
  @HiveField(5)
  intro
}
