import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import '../../../models/folder.dart';
import '../../../services/photo_store_service/photo_store_api.dart';
import '../../photo/photo_view_model.dart';

class FolderPhotoScreen extends StatelessWidget {
  const FolderPhotoScreen({super.key, required this.folderId});

  final int folderId;

  @override
  Widget build(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    Folder? folder = folderViewModel.getFolder(folderId: folderId);
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: folder?.markers.length ?? 0,
      itemBuilder: (context, index) {
        return folder?.markers.toList()[index].imageData == null
            ? FutureBuilder(
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null || snapshot.data == false) {
                    return SpinKitSpinningCircle(
                      itemBuilder: (context, index) {
                        return Center(
                          child: Image.asset('assets/images/pictory_color.png'),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Image.asset(
                      'assets/images/picto_logo.png',
                      fit: BoxFit.cover,
                    );
                  } else {
                    Uint8List? data = snapshot.data;
                    folder.markers.toList()[index].imageData = data;
                    return _getPhotoTile(folder.markers.toList()[index]);
                  }
                },
                future: PhotoStoreHandler().downloadPhoto(folder!.photos[index].photoId),
              )
            : _getPhotoTile(folder!.markers.toList()[index]);
      },
    );
  }

  _getPhotoTile(PictoMarker marker) {
    return GestureDetector(
      onTap: () async {
        PhotoViewModel photoViewModel = Get.find<PhotoViewModel>();
        BoxFit fit = await photoViewModel.determineFit(marker.imageData!);
        Get.toNamed("/photo", arguments: {
          "photo": marker.photo,
          "data": marker.imageData,
          "fit": fit,
        });
      },
      child: Container(
        width: 100, // 원하는 마커 크기
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black, // 테두리 색상
            width: 2, // 테두리 두께
          ),
          // Container 위젯의 테두리
          borderRadius: BorderRadius.circular(16), // 전체 둥글게
        ),
        child: ClipRRect(
          // ClipRRect 하위 위젯 테두리 지정
          borderRadius: BorderRadius.circular(12), // 이미지도 같이 둥글게 잘림
          child: Image.memory(
            marker.imageData!,
            fit: BoxFit.cover,
            errorBuilder: (context, object, trace) {
              return Image.asset(
                'assets/images/picto_logo.png',
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }
}
