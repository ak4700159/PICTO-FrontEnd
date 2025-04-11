import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';

class Folder {
  int generatorId;
  int folderId;
  String name;
  int sharedDatetime;
  String? content;
  List<User> users = [];
  List<Photo> photos = [];
  List<PictoMarker> markers = [];

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
    for(Photo photo in photos) {
      if(photo.userId == UserManagerApi().ownerId) {
        markers.add(PictoMarker(photo: photo, type: PictoMarkerType.userPhoto));
      } else {
        markers.add(PictoMarker(photo: photo, type: PictoMarkerType.folderPhoto));
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Folder && runtimeType == other.runtimeType && folderId == other.folderId;

  @override
  int get hashCode => folderId.hashCode;
}
