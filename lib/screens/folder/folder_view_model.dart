import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_socket.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';

import '../../services/chatting_scheduler_service/chatting_api.dart';

class FolderViewModel extends GetxController {
  // 각 폴더 안의 메시지
  final RxMap<Folder, List<ChatMsg>> folders = <Folder, List<ChatMsg>>{}.obs;
  final FolderManagerApi folderManagerApi = FolderManagerApi();
  final ChattingApi chattingApi = ChattingApi();
  Rxn<Folder> currentFolder = Rxn<Folder>();
  Rxn<ChattingSocket> currentSocket = Rxn<ChattingSocket>();

  //  사용자 기준 폴더 초기화
  void initFolder() async {
    List<Folder> search = await folderManagerApi.getFoldersByOwnerId();
    for (Folder folder in search) {
      folders[folder] = await ChattingApi().getMessagesByFolderId(folder.folderId);
    }
  }

  // 폴더 화면 변화
  void changeFolder(int folderId) {
    for (Folder folder in folders.keys) {
      if (folder.folderId == folderId) {
        currentFolder.value = folder;
      }
    }
  }

  // 현재 선택된 폴더에 소켓 연결
  void changeSocket() {
    if (currentSocket.value == null) return;
    currentSocket.value?.disconnectWebSocket();
    currentSocket.value = ChattingSocket(
      folderId: currentFolder.value!.folderId,
      receive: (frame) {
        folders[currentFolder.value]?.add(ChatMsg.fromFrame(frame));
      },
    );
  }

// 폴더 초대 전송


// 폴더 초대 내역 확인

// 폴더 초대 확인
}
