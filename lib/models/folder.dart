import 'package:get/get.dart';
import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

import '../services/chatting_scheduler_service/chatting_api.dart';
import '../services/photo_store_service/photo_store_api.dart';

class Folder {
  int generatorId;
  int folderId;
  String name;
  String? content;
  int sharedDatetime;

  // 공유 중인 사용자
  List<User> users = [];

  // 공유된 사진
  List<Photo> photos = [];

  // 채팅방 내역
  List<ChatMsg> messages = [];
  List<PictoMarker> markers = <PictoMarker>[];

  Folder({
    required this.folderId,
    required this.name,
    required this.generatorId,
    required this.sharedDatetime,
    required bool allInit,
    this.content,
  }) {
    if (folderId == -1) return;
    if(allInit) {
      initFolder();
    }
  }

  factory Folder.fromJson(Map<String, dynamic> json, bool allInit) {
    return Folder(
      folderId: json["folderId"],
      name: json["folderName"],
      // generatorId: json["userId"],
      generatorId: json["generatorId"] ?? json["userId"],
      sharedDatetime: json["sharedDatetime"],
      content: json["content"],
      allInit: allInit,
    );
  }

  // 폴더 초기화
  void initFolder() async {
    users = await FolderManagerApi().getUsersInFolder(folderId: folderId);
    photos = await FolderManagerApi().getPhotosInFolder(folderId: folderId);
    messages = await ChattingApi().getMessagesByFolderId(folderId: folderId);
    // print("[INFO] #{$folderId}folder photos length : ${photos.length}");
    // 마커로 변환
    for (Photo photo in photos) {
      if (photo.userId == UserManagerApi().ownerId) {
        markers.add(PictoMarker(photo: photo, type: PictoMarkerType.userPhoto));
      } else {
        markers.add(PictoMarker(photo: photo, type: PictoMarkerType.folderPhoto));
      }
    }
    // print("[INFO] #{$folderId}folder markers length : ${markers.length}");
  }

  // 폴더 업데이트
  // !! 기존 데이터에서 새로운 데이터와 비교하여 추가하고 삭제할 부분을 반영 !!
  Future<void> updateFolder() async {
    updateUser();
    updatePhoto();
    updateMarker();
    updateMessage();
  }

  void downloadPhotos() async {
    for (var m in markers) {
      m.imageData ??= await PhotoStoreApi().downloadPhoto(m.photo.photoId);
    }
  }

  void updateUser() async {
    var newUsers = await FolderManagerApi().getUsersInFolder(folderId: folderId);
    var removeUsers = [];
    for (User oldUser in users) {
      // 새로운 데이터 안에 있는지 확인
      bool exist = newUsers.any((u) => u.userId == oldUser.userId);
      if (!exist) removeUsers.add(oldUser);
    }
    for (User newUser in newUsers) {
      bool exist = users.any((u) => u.userId == newUser.userId);
      if (!exist) users.add(newUser);
    }
    for (User removeUser in removeUsers) {
      users.removeWhere((u) => u.userId == removeUser.userId);
    }
  }

  void updateMessage() async {
    var newMessages = await ChattingApi().getMessagesByFolderId(folderId: folderId);
    var addMessages = <ChatMsg>[];
    var removeMessages = <ChatMsg>[];

    // 기존 메시지 중, 새 메시지 목록에 없는 건 제거 대상
    for (ChatMsg oldMsg in messages) {
      if (!newMessages.contains(oldMsg)) {
        removeMessages.add(oldMsg);
      }
    }

    // 새 메시지 중, 기존에 없던 건 추가 대상
    for (ChatMsg newMsg in newMessages) {
      if (!messages.contains(newMsg)) {
        addMessages.add(newMsg);
      }
    }

    // 실제 업데이트
    messages.removeWhere((m) => removeMessages.contains(m));
    messages.addAll(addMessages);
  }

  void updatePhoto() async {
    var newPhotos = await FolderManagerApi().getPhotosInFolder(folderId: folderId);
    var addPhotos = <Photo>[];
    var removePhotos = <Photo>[];

    for (Photo oldPhoto in photos) {
      if (!newPhotos.any((p) => p.photoId == oldPhoto.photoId)) {
        removePhotos.add(oldPhoto);
      }
    }
    for (Photo newPhoto in newPhotos) {
      if (!photos.any((p) => p.photoId == newPhoto.photoId)) {
        addPhotos.add(newPhoto);
      }
    }
    photos.removeWhere((p) => removePhotos.any((r) => r.photoId == p.photoId));
    photos.addAll(addPhotos);
  }

  // 업데이트한 photos를 보고 추가한다.
  void updateMarker() {
    var newMarkers = <PictoMarker>[];
    for (Photo newPhoto in photos) {
      // 기존에 같은 photoId를 가진 마커가 있으면 재사용
      PictoMarker? existing = markers.firstWhereOrNull(
        (m) => m.photo.photoId == newPhoto.photoId,
      );

      if (existing != null) {
        newMarkers.add(existing);
      } else {
        newMarkers.add(
          PictoMarker(
            photo: newPhoto,
            type: newPhoto.userId == UserManagerApi().ownerId
                ? PictoMarkerType.userPhoto
                : PictoMarkerType.folderPhoto,
          ),
        );
      }
    }
    markers = newMarkers;
  }

  User? getUser(int userId) {
    for (var value in users) {
      if (value.userId == userId) {
        return value;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder && runtimeType == other.runtimeType && folderId == other.folderId);

  @override
  int get hashCode => folderId.hashCode;
}
