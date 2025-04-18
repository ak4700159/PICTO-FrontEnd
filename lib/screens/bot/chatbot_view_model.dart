import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/models/chatbot_room.dart';
import 'package:picto_frontend/services/chatbot_manager_api/chatbot_api.dart';

import '../../utils/picker.dart';

class ChatbotViewModel extends GetxController {
  final textEditorController = TextEditingController();
  final inputFocusNode = FocusNode();
  final chatScrollController = ScrollController();
  final imagePickerController =  MultiImagePickerController(
      maxImages: 2,
      // pickImages 함수 실행 시 해당 콜백 함수 작동
      picker: (int pickCount, Object? params) async {
        return await pickImagesUsingImagePicker(pickCount);
      });

  RxList<ImageFile> currentSelectedImages = <ImageFile>[].obs;
  RxList<ChatbotMsg> currentMessages = <ChatbotMsg>[].obs;
  Rxn<ChatbotRoom> currentRoom = Rxn();
  RxList<ChatbotRoom> chatbotRooms = <ChatbotRoom>[].obs;
  RxBool isSending = false.obs;
  RxBool isUp = false.obs;
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
    textEditorController.dispose();
    chatScrollController.dispose();
    super.onClose();
    box.close();
  }

  // 채팅 전달 + 응답 처리
  void sendMsg(ChatbotMsg newMsg) async {
    currentMessages.add(newMsg);
    currentRoom.value?.messages.add(newMsg);
    box.put(newMsg.sendDatetime.toString(), newMsg);

    isSending.value = true;
    // 이것만 구현 -> 선택된 이미지가 있는지 확인!!
    // newMsg.imagePath;
    String response = await ChatbotAPI().sendPrompt(newMsg.content, []);
    final chatbotMsg = ChatbotMsg(
        sendDatetime: DateTime.now().millisecondsSinceEpoch,
        content: response,
        isMe: false,
        imagePath: []);
    currentMessages.add(chatbotMsg);
    currentRoom.value?.messages.add(chatbotMsg);
    box.put(chatbotMsg.sendDatetime.toString(), chatbotMsg);
  }


  // 갤러리에서 사진 선택
  Future<void> pickPhotos() async {
    imagePickerController.pickImages();
    currentSelectedImages.clear();
    currentSelectedImages.addAll(imagePickerController.images);
  }

  // 선택한 사진 삭제


  // 채팅방 선택
  void selectChatRoom(int createdDatetime) {
    for (var room in chatbotRooms) {
      if (room.createdDatetime == createdDatetime) {
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
  void removeChatbotRoom(int createdDatetime) {
    chatbotRooms.removeWhere((room) => room.createdDatetime == createdDatetime);
    box.delete(createdDatetime.toString());
  }

  void toggleIsUp() {
    isUp.value = !isUp.value;
  }

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
