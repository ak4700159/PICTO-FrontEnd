import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_chat_screen.dart';

class FolderViewModel extends GetxController {
  final RxList<String> folderNames = ["PICTO", "가족여행", "크리스마스"].obs;
  final RxList<ChatBubble> messages = <ChatBubble>[].obs;

  // 전체 메시지 로드

  // 메시지 전송

  // 메시지 수신

  // 폴더 초대 전송

  // 폴더 초대 내역 확인

  // 폴더 초대 확인

}