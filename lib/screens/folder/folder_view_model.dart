import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/screens/profile/calendar_event.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_socket.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import '../../models/user.dart';
import '../../services/photo_store_service/photo_store_api.dart';
import '../../utils/functions.dart';
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
    // showBlockingLoading(Duration(seconds: 1));

    // 제거
    final existFolderKeys = folders.keys;
    for (int oldKey in existFolderKeys) {
      if (!search.any((f) => f.folderId == oldKey)) {
        folders.remove(oldKey);
      }
    }

    // 기존에 있었던 폴더는 업데이트. 없었으면 추가
    for (Folder newFolder in search) {
      if (folders.keys.contains(newFolder.folderId)) {
        folders[newFolder.folderId]?.updateFolder();
      } else {
        folders[newFolder.folderId] = newFolder;
      }
    }
  }

  // 폴더 다운로드 : 폴더 아이콘을 선택해서 변화할 때만 작동
  Future<void> downloadFolder() async {
    final firstTasks = <Future<void>>[];
    final tasks = <Future<void>>[];

    final nullMarkers = currentMarkers.where((m) => m.imageData == null).toList();
    int total = nullMarkers.length;
    int completed = 0;

    // 폴더 안의 사용자 프로필 다운로드
    final nullUsers = currentFolder.value!.users.where((u) => u.userProfileData == null).toList();
    // print("[INFO] null users : ${nullUsers.map((u) => u.userId).toList()}");
    for (var user in nullUsers) {
      final capturedUser = user; // 🔑 클로저 캡처 방지
      firstTasks.add(() async {
        // print("[DEBUG] downloading profile for userId: ${capturedUser.userId}");
        capturedUser.userProfileId =
            await UserManagerApi().getUserProfilePhoto(userId: capturedUser.userId!);
        if (capturedUser.userProfileId != null) {
          capturedUser.userProfileData = await PhotoStoreApi().downloadPhoto(
            photoId: capturedUser.userProfileId!,
            scale: 0.08,
          );
          currentFolder.value!.users[currentFolder.value!.users.indexOf(capturedUser)] =
              capturedUser;
        }
      }());
    }
    await Future.wait(firstTasks);

    // 폴더 안 사진 다운로드
    for (var marker in nullMarkers) {
      tasks.add(() async {
        Uint8List? data = await PhotoStoreApi().downloadPhoto(
          photoId: marker.photo.photoId,
          scale: 0.3,
        );
        marker.imageData = data;
        currentMarkers[currentMarkers.indexOf(marker)] = marker;
        completed++;
        progress.value = completed / total;
      }());
    }
    await Future.wait(tasks);

    // 로딩 완료
    loadingComplete.value = true;
  }

  // 폴더 화면 변화
  void changeFolder({required int folderId}) async {
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
    // await showBlockingLoading(Duration(seconds: 1));
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
        currentMsgList.add(ChatMsg.fromJson(data));
      },
    );
    currentSocket.value?.connectWebSocket();
    currentMsgList.clear();
    currentMsgList.value = folders[currentFolder.value?.folderId]!.messages;
  }

  // 폴더 화면에서 벗어날 경우
  void disconnectSocket() {
    currentSocket.value?.disconnectWebSocket();
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

  // 폴더 이름 통해서 폴더 사진 조회
  Future<List<PictoMarker>> getPictoMarkersByName({required String folderName}) async {
    Folder folder = folders.values.firstWhere((f) => f.name == "default");
    await folder.updateFolder();
    await folder.downloadPhotos(0.1);
    return folder.markers;
  }

  // 폴더 안에 사진 있는지
  bool isPhotoInFolder({required int folderId, required int photoId}) {
    final photoKeys = folders[folderId]?.photos.map((p) => p.photoId).toList();
    if (photoKeys!.contains(photoId)) {
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

  // 날짜 별로 그룹화하는 함수
  Map<String, List<ChatMsg>> groupMessagesByDay() {
    Map<String, List<ChatMsg>> grouped = {};
    for (var msg in currentMsgList) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(msg.sendDatetime);
      String weekdayKor = getKoreanWeekday(date.weekday);
      String dayKey =
          '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일 $weekdayKor';
      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = [];
      }
      grouped[dayKey]!.add(msg);
    }

    // 키값(날짜)을 오름차순 정렬한 LinkedHashMap 생성
    final sortedKeys = grouped.keys.toList()..sort(); // 문자열 정렬은 날짜 포맷에 대해 안정적
    final sortedMap = LinkedHashMap<String, List<ChatMsg>>.fromIterable(
      sortedKeys,
      key: (k) => k,
      value: (k) => grouped[k]!,
    );
    return sortedMap;
  }

  Uint8List? getOtherProfilePhoto({required int userId}) {
    User find = currentFolder.value!.users.firstWhere((u) => u.userId == userId);
    return find.userProfileData;
  }

  // 폴더 안의 모든 사진들을 바탕으로 CalendarEvent 만들어서 반환
  Future<List<CalendarEvent>> convertCalendarEvent() async {
    List<CalendarEvent> result = [];
    // 폴더 전체 업데이트(정보만!)
    final tasks = <Future<void>>[];
    for (Folder folder in folders.values) {
      tasks.add(() async {
        await folder.updateFolder();
      }());
    }
    await Future.wait(tasks);

    // 폴더 순회하며 CalendarEvent 생성
    for (Folder folder in folders.values) {
      for (var photo in folder.photos) {
        final existingEventIndex = result.indexWhere((e) => e.photoId == photo.photoId);

        if (existingEventIndex != -1) {
          // 이미 존재하는 이벤트 → 폴더 이름만 추가
          result[existingEventIndex].folderNames.add(folder.name);
        } else {
          // 새로운 이벤트 생성
          result.add(
            CalendarEvent(
              photoId: photo.photoId,
              folderId: folder.folderId,
              folderNames: [folder.name],
              ownerId: photo.userId!,
              accountName: folder.getUser(photo.userId!)?.accountName ?? "unknown",
              uploadTime: photo.updateDatetime!,
              location: photo.location,
            ),
          );
        }
      }
    }
    return result;
  }
}
