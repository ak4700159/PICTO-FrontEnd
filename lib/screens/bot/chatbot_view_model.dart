import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatbotViewModel extends GetxController {
  final TextEditingController controller = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  final ScrollController chatScrollController = ScrollController();

  RxList currentMsgList = [].obs;

  @override
  void onInit() {
    super.onInit();
    ever(currentMsgList, (_) {
      // 현재 메시지가 하단에 있을 때만 스크롤
      if (isAtBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
      }
    });
  }

  @override
  void onClose() {
    inputFocusNode.dispose();
    controller.dispose();
    chatScrollController.dispose();
    super.onClose();
  }

  // 이전 채팅 전부 로딩 -> 로컬 저장

  // 채팅 전달 + 응답 처리

  // 사진 선택

  // 선택한 사진 삭제


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