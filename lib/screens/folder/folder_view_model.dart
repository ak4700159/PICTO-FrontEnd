import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_socket.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import '../../services/photo_store_service/photo_store_api.dart';
import '../../utils/popup.dart';

class FolderViewModel extends GetxController {
  // 각 폴더 안의 메시지
  // RxMap<Folder, List<ChatMsg>> folders = <Folder, List<ChatMsg>>{}.obs;
  RxMap<int, Folder> folders = <int, Folder>{}.obs;
  Rxn<Folder> currentFolder = Rxn<Folder>();
  RxList<PictoMarker> currentMarkers = <PictoMarker>[].obs;
  Rxn<ChattingSocket> currentSocket = Rxn<ChattingSocket>();
  RxList<ChatMsg> currentMsgList = <ChatMsg>[].obs;
  RxBool isUpdate = false.obs;
  ScrollController chatScrollController = ScrollController();
  RxDouble progress = 0.0.obs;
  RxBool loadingComplete = false.obs;

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

  //  폴더 초기화 -> 새로운 폴더는 추가, 중복되는 폴더는 업데이트
  Future<void> resetFolder() async {
    List<Folder> search = await FolderManagerApi().getFoldersByOwnerId();
    await showBlockingLoading(Duration(seconds: 1));

    // 제거
    final existFolderKeys = folders.keys;
    for(int oldKey in existFolderKeys) {
      if(!search.any((f) => f.folderId == oldKey)) {
        folders.remove(oldKey);
      }
    }

    // 기존에 있었던 폴더는 업데이트. 없었으면 추가
    for(Folder newFolder in search) {
      if(folders.keys.contains(newFolder.folderId)) {
        folders[newFolder.folderId]?.updateFolder();
      } else {
        folders[newFolder.folderId] = newFolder;
      }
    }
  }

  Future<void> downloadFolder() async {
    int completed = 0;
    int total = currentMarkers.length;
    for (int i = 0; i < currentMarkers.length; i++)  {
      if (currentMarkers[i].imageData == null) {
        Uint8List? data = await PhotoStoreApi().downloadPhoto(currentMarkers[i].photo.photoId);
        currentMarkers[i].imageData = data;
        currentMarkers[i] = currentMarkers[i]; // 중요! 다시 assign
      }
      completed++;
      progress.value = completed / total;
    }
    loadingComplete.value = true;
  }

  // 폴더 화면 변화
  void changeFolder({required int folderId}) {
    folders[folderId]?.updateFolder();
    progress.value = 0.0;
    loadingComplete.value = false;
    for (int key in folders.keys) {
      if (key == folderId) {
        currentFolder.value = folders[folderId];
        currentMarkers.clear();
        currentMarkers.addAll(folders[folderId]!.markers);
      }
    }
    downloadFolder();
    changeSocket();
  }

  // 현재 선택된 폴더에 소켓 연결
  void changeSocket() {
    currentSocket.value?.disconnectWebSocket();
    // print("[INFO] chatting socket change try...");
    currentSocket.value = ChattingSocket(
      folderId: currentFolder.value!.folderId,
      receive: (frame) {
        final data = jsonDecode(frame.body ?? "");
        if (data["userId"] == UserManagerApi().ownerId) return;
        // folders[currentFolder.value?.folderId]?.messages.add(ChatMsg.fromJson(data));
        currentMsgList.add(ChatMsg.fromJson(data));
      },
    );
    currentSocket.value?.connectWebSocket();
    currentMsgList.clear();
    currentMsgList.value = folders[currentFolder.value?.folderId]!.messages;
    // print("[INFO] chatting socket change completed...?");
  }

  // 폴더 삭제
  void removeFolder({required int folderId}) async {
    if (await FolderManagerApi().removeFolder(folderId: folderId)) {
      folders.remove(folderId);
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
    return folders[folderId];
  }

  // 폴더 안에 사진 있는지
  bool isPhotoInFolder({required int folderId, required int photoId}) {
    final photoKeys = folders[folderId]?.photos.map((p) => p.photoId).toList();
    if(photoKeys!.contains(photoId)) {
      return true;
    }
    return false;
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
