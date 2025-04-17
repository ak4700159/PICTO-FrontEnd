import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/models/chatbot_room.dart';

class ChatbotViewModel extends GetxController {
  final TextEditingController controller = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  final ScrollController chatScrollController = ScrollController();
  RxList currentMessages = [].obs;
  Rxn<ChatbotRoom> currentRoom = Rxn();
  RxList<ChatbotRoom> chatbotRooms = <ChatbotRoom>[].obs;
  late Box box;

  @override
  void onInit() async {
    super.onInit();
    ever(currentMessages, (_) {
      // 현재 메시지가 하단에 있을 때만 스크롤
      if (isAtBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
      }
    });
    box = await Hive.openBox('chatbot');
    List<ChatbotRoom> data = box.values
        .whereType<ChatbotRoom>() // ChatbotList 타입만 필터링
        .toList();
    chatbotRooms.value = data;
  }

  @override
  void onClose() {
    inputFocusNode.dispose();
    controller.dispose();
    chatScrollController.dispose();
    super.onClose();
    box.close();
  }

  // 채팅 전달 + 응답 처리

  // 사진 선택

  // 선택한 사진 삭제

  // 채팅방 선택
  void selectChatRoom(int createdDatetime) {
    for(var room in chatbotRooms) {
      if(room.createdDatetime == createdDatetime){
        currentMessages.clear();
        currentMessages.addAll(room.messages);
        currentRoom.value = room;
        return;
      }
    }
  }

  // 채팅방 추가
  void addChatbotRoom() {
    final newRoom = ChatbotRoom(createdDatetime: DateTime.now().millisecondsSinceEpoch);
    box.put(newRoom.createdDatetime.toString(), newRoom);
    chatbotRooms.add(newRoom);
  }

  // 채팅방 삭제
  void removeChatbotRoom(int createdDatetime) {}

  // 최하단으로 스크롤 이동
  void scrollToBottom() {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 현재 스크롤이 하단에 잇는지 확인 -> 당장은 의미 X 제대로 동작하지 않음
  bool get isAtBottom {
    if (!chatScrollController.hasClients) return false;
    final max = chatScrollController.position.maxScrollExtent;
    final current = chatScrollController.offset;
    return (max - current).abs() < 50; // 여유값 50px
  }
}
