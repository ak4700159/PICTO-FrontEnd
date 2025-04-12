import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_socket.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../../services/chatting_scheduler_service/chatting_api.dart';
import '../../utils/popup.dart';

class FolderViewModel extends GetxController {
  // 각 폴더 안의 메시지
  RxMap<Folder, List<ChatMsg>> folders = <Folder, List<ChatMsg>>{}.obs;
  Rxn<Folder> currentFolder = Rxn<Folder>();
  RxList<PictoMarker> currentMarkers = <PictoMarker>[].obs;
  Rxn<ChattingSocket> currentSocket = Rxn<ChattingSocket>();
  RxList<ChatMsg> currentMsgList = <ChatMsg>[].obs;
  ScrollController chatScrollController = ScrollController();

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

  //  폴더 초기화
  Future<void> initFolder() async {
    List<Folder> search = await FolderManagerApi().getFoldersByOwnerId();
    await showBlockingLoading(Duration(seconds: 1));
    final existingKeys = folders.keys.toList();
    final newFolderIds = search.map((f) => f.folderId).toSet();
    for (var oldFolder in existingKeys) {
      if (!newFolderIds.contains(oldFolder.folderId)) {
        folders.remove(oldFolder);
      }
    }
    for (Folder newFolder in search) {
      final exists = folders.keys.any((f) => f.folderId == newFolder.folderId);
      final pre = getFolder(folderId: newFolder.folderId);

      // 새 폴더 추가
      if (!exists) {
        folders[newFolder] = await ChattingApi().getMessagesByFolderId(newFolder.folderId);
      }
      // 기존 폴더 → 사진만 업데이트
      else if (pre != null) {
        // 새로 추가된 사진만 추출
        // print("[INFO] {pre} photos: ${pre.photos.length}/ markers: ${pre.markers.length}");
        // print("[INFO] {new} photos: ${newFolder.photos.length}/ markers: ${newFolder.markers.length}");
        final oldPhotoIds = pre.photos.map((p) => p.photoId).toSet();
        final newPhotos = newFolder.photos.where((p) => !oldPhotoIds.contains(p.photoId)).toList();

        if (newPhotos.isNotEmpty) {
          pre.photos.addAll(newPhotos);
          // print("[INFO] ${newPhotos.length} new photos added to folder ${pre.folderId}");
        }

        // markers도 갱신하고 싶다면 여기에 추가 (선택)
        final oldMarkerIds = pre.markers.map((m) => m.photo.photoId).toSet();
        final newMarkers =
            newFolder.markers.where((m) => !oldMarkerIds.contains(m.photo.photoId)).toList();
        if (newMarkers.isNotEmpty) {
          pre.markers.addAll(newMarkers);
        }
      }
    }
  }

  // 폴더 화면 변화
  void changeFolder({required int folderId, required int generatorId}) {
    // print("[INFO] exchange folderId : $folderId / generatorId : $generatorId");
    for (Folder folder in folders.keys) {
      if (folder.folderId == folderId) {
        // print("[INFO] exchange <-> ${folder.markers.length}");
        currentFolder.value = folder;
        currentMarkers.clear();
        currentMarkers.addAll(folder.markers);
      }
    }
    // print("[INFO] current markers len : ${currentMarkers.length}");
    changeSocket();
  }

  // 현재 선택된 폴더에 소켓 연결
  void changeSocket() {
    // if (currentSocket.value == null) return;
    currentSocket.value?.disconnectWebSocket();
    print("[INFO] chatting socket change try...");
    currentSocket.value = ChattingSocket(
      folderId: currentFolder.value!.folderId,
      receive: (frame) {
        final data = jsonDecode(frame.body ?? "");
        if (data["userId"] == UserManagerApi().ownerId) return;
        folders[currentFolder.value]?.add(ChatMsg.fromJson(data));
        currentMsgList.add(ChatMsg.fromJson(data));
      },
    );
    currentSocket.value?.connectWebSocket();
    currentMsgList.clear();
    currentMsgList.addAll(folders[currentFolder.value]!);
    print("[INFO] chatting socket change completed...?");
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
    for (Folder folder in folders.keys) {
      if (folder.folderId == folderId) return folder;
    }
    return null;
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
