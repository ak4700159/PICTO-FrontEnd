import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_socket.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../services/chatting_scheduler_service/chatting_api.dart';

class FolderViewModel extends GetxController {
  // 각 폴더 안의 메시지
  RxMap<Folder, List<ChatMsg>> folders = <Folder, List<ChatMsg>>{}.obs;
  Rxn<Folder> currentFolder = Rxn<Folder>();
  Rxn<ChattingSocket> currentSocket = Rxn<ChattingSocket>();

  //  폴더 초기화
  void initFolder() async {
    List<Folder> search = await FolderManagerApi().getFoldersByOwnerId();
    final existingKeys = folders.keys.toList();
    final newFolderIds = search.map((f) => f.folderId).toSet();

    for (var oldFolder in existingKeys) {
      if (!newFolderIds.contains(oldFolder.folderId)) {
        folders.remove(oldFolder);
      }
    }
    for (Folder newFolder in search) {
      // any 함수는 콜백함수에서 한번이라도 ture를 반환하면 함수에서 true를 반환한다.
      final exists = folders.keys.any((f) => f.folderId == newFolder.folderId);
      // exists = false 는 기존에 존재하지 않았던 폴더를 의미한다. => 추가
      if (!exists) {
        folders[newFolder] = await ChattingApi().getMessagesByFolderId(newFolder.folderId);
      }
    }
  }

  // 폴더 화면 변화
  void changeFolder({required int folderId}) {
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

  // 폴더 삭제
  void removeFolder({required int folderId}) async {
    if (await FolderManagerApi().removeFolder(folderId: folderId)) {
      folders.removeWhere((key, value) => key.folderId == folderId);
    }
  }

  // 폴더 생성
  void createFolder({required String folderName, required String content}) async {
    Folder? newFolder =
        await FolderManagerApi().createFolder(folderName: folderName, content: content);
  }

  // 현재 연결된 소켓에 채팅 전송
  void sendChatMsg({required String content, required String accountName}) async {
    int userId = UserManagerApi().ownerId as int;
    int sendDatetime = DateTime.now().millisecondsSinceEpoch;
    currentSocket.value?.sendChatMsg(ChatMsg(
      content: content,
      accountName: accountName,
      sendDatetime: sendDatetime,
      userId: userId,
    ));
  }

  //폴더 조회
  Folder? getFolder({required int folderId}) {
    for(Folder folder in folders.keys) {
      if(folder.folderId == folderId) return folder;
    }
    return null;
  }
}
