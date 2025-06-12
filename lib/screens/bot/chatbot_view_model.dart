import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/models/chatbot_room.dart';
import 'package:picto_frontend/services/photo_manager_service/photo_manager_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../models/photo.dart';
import '../../models/photo_data.dart';
import '../../models/user.dart';
import '../../services/chatbot_manager_service/chatbot_api.dart';
import '../../services/chatbot_manager_service/prompt_response.dart';
import '../../utils/functions.dart';
import '../../utils/picker.dart';

class ChatbotViewModel extends GetxController {
  final textEditorController = TextEditingController();
  final inputFocusNode = FocusNode();
  final chatScrollController = ScrollController();
  final imagePickerController = MultiImagePickerController(
      maxImages: 2,
      // pickImages 함수 실행 시 해당 콜백 함수 작동
      picker: (int pickCount, Object? params) async {
        return await pickImagesUsingImagePicker(pickCount);
      });

  RxList<ImageFile> currentSelectedImages = <ImageFile>[].obs;
  RxList<ChatbotMsg> currentMessages = <ChatbotMsg>[].obs;
  Rxn<ChatbotRoom> currentRoom = Rxn();

  // Rxn<ChatbotMsg> sendingChatbotMsg = Rxn();
  RxList<ChatbotRoom> chatbotRooms = <ChatbotRoom>[].obs;
  RxList<bool> currentCheckbox = <bool>[].obs;
  RxBool isSending = false.obs;
  RxBool isUp = false.obs;
  RxBool isDelete = false.obs;
  RxDouble opacity = 1.0.obs;
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

    // 오늘 기준으로 1년 이내 랜덤 날짜 생성
    final now = DateTime.now();
    final random = Random();

    for (int i = 0; i < 10; i++) {
      final randomDaysAgo = random.nextInt(60); // 0~364일 전
      final created = now.subtract(Duration(days: randomDaysAgo));
      final createdMillis = created.millisecondsSinceEpoch;
      final dummyRoom = ChatbotRoom(createdDatetime: createdMillis);
      data.add(dummyRoom);
    }

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
  void sendMsg(ChatbotMsg myMsg) async {
    List<PhotoData> images = [];
    isSending.value = true;

    // 현재 선택된 사진을 이미지에 포함
    if (currentSelectedImages.isNotEmpty) {
      for (ImageFile file in currentSelectedImages) {
        images.add(PhotoData(data: await File(file.path!).readAsBytes()));
      }
    }
    // 전송될 예정이기에 선택된 사진들을 지우고 사진 선택창을 내린다
    imagePickerController.images = [];
    currentSelectedImages.clear();
    isUp.value = false;

    // 전송될 채팅에 이미지 추가
    myMsg.images = images;
    currentMessages.add(myMsg);
    currentRoom.value?.messages.add(myMsg);

    // 챗봇 메시지 전송
    final chatbotMsg = ChatbotMsg(
      sendDatetime: DateTime.now().millisecondsSinceEpoch,
      content: "",
      isMe: false,
      images: [],
      status: ChatbotStatus.sending,
    );
    // 현재 채팅방에 메시지 등록
    currentMessages.add(chatbotMsg);
    // Chatbot API 호출
    PromptResponse? response =
        await ChatbotAPI().sendPrompt(myMsg.content, images.map((data) => data.data).toList());
    if (response == null) {
      isSending.value = false;
      return;
    }

    // 챗봇 상태 변경
    currentMessages.removeLast();
    chatbotMsg
      ..images = response.photos
      ..content = response.response
      ..status = _getStatusInResponse(response.response);
    chatbotMsg.content = chatbotMsg.content.substring("00\n".length);
    currentMessages.add(chatbotMsg);
    currentRoom.value?.messages.add(chatbotMsg);
    box.put(currentRoom.value?.createdDatetime.toString(), currentRoom.value);
    isSending.value = false;
  }

  ChatbotStatus _getStatusInResponse(String result) {
    if (result.contains("분석")) {
      return ChatbotStatus.analysis;
    } else if (result.contains("비교")) {
      return ChatbotStatus.compare;
    } else if (result.contains("검색")) {
      return ChatbotStatus.recommend;
    } else if (result.contains("기타")) {
      return ChatbotStatus.intro;
    }
    return ChatbotStatus.intro;
  }

  // 채팅방 선택
  void selectChatRoom(int createdDatetime) {
    for (var room in chatbotRooms) {
      if (room.createdDatetime == createdDatetime) {
        currentMessages.clear();
        currentSelectedImages.clear();
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

  void toggleIsDelete() {
    isDelete.value = !isDelete.value;
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

  // 월별로 그룹핑
  Map<String, List<ChatbotRoom>> groupChatbotRoomsByMonth() {
    Map<String, List<ChatbotRoom>> grouped = {};

    for (var room in chatbotRooms) {
      DateTime created = DateTime.fromMillisecondsSinceEpoch(room.createdDatetime);
      String monthKey = '${created.year}년 ${created.month.toString().padLeft(2, '0')}월';
      grouped.putIfAbsent(monthKey, () => []);
      grouped[monthKey]!.add(room);
    }

    // 🔽 날짜 기준 내림차순으로 키 정렬
    var sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a)); // 최신 순
    LinkedHashMap<String, List<ChatbotRoom>> sortedMap = LinkedHashMap.fromIterable(
      sortedKeys,
      key: (k) => k,
      value: (k) => grouped[k]!,
    );
    return sortedMap;
  }

  // 검색한 사진 선택
  Future<void> selectOtherPhoto(int photoId, Uint8List data) async {
    Photo? photo = await PhotoManagerApi().getPhoto(photoId: photoId);
    // 사진 검색 실패 시
    if (photo == null) return;
    final fit = await determineFit(data);
    User? user = await UserManagerApi().getUserByUserId(userId: photo.userId!);
    Get.toNamed('/photo', arguments: {
      "photo": photo,
      "data": data,
      "fit": fit,
      "user": user,
    });
  }

  Future<void> selectMyPhoto(Uint8List data) async {
    final fit = await determineFit(data);
    Get.toNamed('/comfyui/photo', arguments: {
      "data": data,
      "fit": fit,
    });
  }
}
