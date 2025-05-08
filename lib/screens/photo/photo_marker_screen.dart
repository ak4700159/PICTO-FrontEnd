import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../models/photo.dart';
import '../../utils/functions.dart';

// 1. 마커 클러스터 화면에서 선택
// 2. 폴더 사진에서 선택
class PhotoMarkerScreen extends StatelessWidget {
  const PhotoMarkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Photo photo = Get.arguments["photo"];
    Uint8List data = Get.arguments["data"];
    BoxFit fit = Get.arguments["fit"];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 사진
          Positioned.fill(
            child: FutureBuilder(
                future: PhotoStoreApi().downloadPhoto(photoId: photo.photoId, scale: 1),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null || snapshot.hasError) {
                    return Image.asset(
                      '/assets/images/picto_logo.png',
                      fit: BoxFit.cover,
                    );
                  }
                  return Image.memory(
                    snapshot.data!,
                    fit: fit,
                  );
                }),
          ),
          if (photo.userId == UserManagerApi().ownerId)
            Positioned(
                top: 20,
                right: 20,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppConfig.mainColor,
                    size: 25,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case "delete":
                        break;
                      case "move":
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "delete",
                      onTap: () async {
                        final folderViewModel = Get.find<FolderViewModel>();
                        bool isSuccess = await PhotoStoreApi().deletePhoto(photo.photoId);
                        if (isSuccess) {
                          // showPositivePopup("삭제에 성공했습니다!");
                          folderViewModel.currentFolder.value!.photos.removeWhere((p) => p.photoId == photo.photoId);
                          folderViewModel.currentFolder.value!.markers
                              .removeWhere((m) => m.photo.photoId == photo.photoId);
                          folderViewModel.currentMarkers.removeWhere((m) => m.photo.photoId == photo.photoId);
                          await folderViewModel.resetFolder();
                          Get.back();
                          // Get.back()
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.folder_delete),
                          const Text(
                            " 사진 삭제",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "move",
                      onTap: () => Get.toNamed('/folder/select', arguments: {
                        "photoId": photo.photoId,
                      }),
                      child: Row(
                        children: [
                          Icon(Icons.drive_file_move),
                          Text(
                            " 사진 이동",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
          else
            Positioned(
                top: 30,
                right: 20,
                child: Icon(
                  Icons.devices_other,
                  size: 30,
                )),
          // 하단 정보 오버레이
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _getInfoWidget(photo),
          ),
        ],
      ),
    );
  }

  Widget _getInfoWidget(Photo photo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 유저 아이콘 (placeholder)
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            // 아이콘 다른 사용자
            child: Icon(Icons.person, color: Colors.grey[800]),
          ),
          const SizedBox(width: 12),
          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text('@cats_save_the_world',
                //     style: TextStyle(color: Colors.white, fontSize: 14)),
                Row(
                  children: [
                    Icon(
                      Icons.tag_sharp,
                      color: Colors.white70,
                      size: 15,
                    ),
                    Text(
                      '  ${photo.tag}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: "NotoSansKR",
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 15,
                    ),
                    Text(
                      '  ${photo.location}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: "NotoSansKR",
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Colors.white70,
                      size: 15,
                    ),
                    Text(
                      '  ${formatDateKorean(photo.updateDatetime ?? 0)}',
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 좋아요 하트
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: AppConfig.mainColor),
              const SizedBox(height: 4),
              Text('${photo.likes}', style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
