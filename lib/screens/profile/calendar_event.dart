// 달력 구현 필요한 데이터?
// 1. 어떤 폴더들에 공유되어 있는지(폴더정보 -> 폴더명 정도만?)
// 2. 업로드 장소
// 3. 공유 시간(시간만 00시 00분)
// 4. 공유자

import 'dart:typed_data';

class CalendarEvent {
  final int uploadTime;
  final List<String> folderNames;
  final int photoId;
  final int folderId;
  final int ownerId;
  final String accountName;
  final String location;
  final Uint8List? data;

  CalendarEvent({
    required this.photoId,
    required this.folderId,
    required this.ownerId,
    required this.uploadTime,
    required this.location,
    required this.folderNames,
    required this.accountName,
    this.data,
  });

  @override
  String toString() => "owner : $ownerId / photo : $photoId / folder : $folderId";
}

