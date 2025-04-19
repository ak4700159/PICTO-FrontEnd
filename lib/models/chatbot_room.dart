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

  ChatbotRoom({required this.createdDatetime}) {
    messages.add(
      ChatbotMsg(sendDatetime: createdDatetime, content: """
안녕하세요!🖐 AI픽토리🤖입니다. 무엇을 도와드릴까요?
픽토리는 다음과 같은 기능을 제공합니다:

1. 사진 평가 - 사진의 구도, 색감, 분위기 등을 분석해드립니다
2. 사진 비교 - 두 사진을 비교하여 장단점을 분석해드립니다
3. 사진 검색 - 다양한 기준으로 사진을 검색할 수 있습니다
4. 촬영 관련 질문 - 사진 촬영에 관한 질문에 답변해드립니다
""", isMe: false, images: [],),);
  }
}