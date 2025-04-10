import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/chatting_scheduler_service/chatting_api.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';

class Folder {
  int generatorId;
  int folderId;
  String name;
  int sharedDatetime;
  String? content;
  List<User> users = [];
  List<Photo> photos = [];

  Folder({
    required this.folderId,
    required this.name,
    required this.generatorId,
    required this.sharedDatetime,
  }) {
    if(folderId == -1) return;
    initFolder();
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
        folderId: json["folderId"],
        name: json["folderName"],
        generatorId: json["userId"],
        sharedDatetime: json["sharedDatetime"],
    );
  }

  void initFolder() async {
    users = await FolderManagerApi().getUsersInFolder(folderId: folderId);
    photos = await FolderManagerApi().getPhotosInFolder(folderId: folderId);
  }

  void setFolderInfo(String content, List<User> users) {
    content = content;
    users = users;
  }
}
