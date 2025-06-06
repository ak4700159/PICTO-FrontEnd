import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/get_widget.dart';

import '../../models/photo.dart';
import '../../models/user.dart';
import '../../utils/functions.dart';
import '../../widgets/like_button.dart';

// 1. 마커 클러스터 화면에서 선택
// 2. 폴더 사진에서 선택
class PhotoScreen extends StatelessWidget {
  PhotoScreen({super.key});

  final Photo photo = Get.arguments["photo"];
  final BoxFit fit = Get.arguments["fit"];
  final User user = Get.arguments["user"];

  @override
  Widget build(BuildContext context) {
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
                  return InteractiveViewer(
                    // scaleEnabled : false,
                    minScale: 0.1,
                    maxScale: 3.6,
                    // constrained: false,
                    child: Image.memory(
                      snapshot.data!,
                      fit:  BoxFit.contain,
                    ),
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
                          // 이거 캘린더에도 데이터 반영되게끔 수정 필요
                          // showPositivePopup("삭제에 성공했습니다!");
                          folderViewModel.currentFolder.value!.photos.removeWhere((p) => p.photoId == photo.photoId);
                          folderViewModel.currentFolder.value!.markers
                              .removeWhere((m) => m.photo.photoId == photo.photoId);
                          folderViewModel.currentMarkers.removeWhere((m) => m.photo.photoId == photo.photoId);
                          await folderViewModel.resetFolder(init: false);
                          // await calendarViewModel.buildCalendarEventMap(await folderViewModel.convertCalendarEvent());
                          Get.back();
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_delete,
                            color: AppConfig.mainColor,
                          ),
                          const Text(
                            " 사진 삭제",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: "NotoSansKR",
                              fontSize: 12,
                            ),
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
                          Icon(
                            Icons.drive_file_move,
                            color: AppConfig.mainColor,
                          ),
                          Text(
                            " 사진 이동",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: "NotoSansKR",
                              fontSize: 12,
                            ),
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
                  Icons.adb,
                  size: 30,
                )),
          // 하단 정보 오버레이
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _getInfoWidget(photo, context),
          ),
        ],
      ),
    );
  }

  Widget _getInfoWidget(Photo photo, BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
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
          Expanded(
            flex: 1,
            child: getUserProfile(user: user, context: context, size: 0.1, scale: 0.06),
            // child: CircleAvatar(
            //   radius: 20,
            //   backgroundColor: Colors.white,
            //   // 아이콘 다른 사용자
            //   child: Icon(Icons.person, color: Colors.grey[800]),
            // ),
          ),
          // 텍스트 정보
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text('@cats_save_the_world',
                //     style: TextStyle(color: Colors.white, fontSize: 14)),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.tag_sharp,
                        color: Colors.white70,
                        size: 15,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        '  ${photo.tag}',
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white70,
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 15,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        photo.userId == UserManagerApi().ownerId
                            ? '  ${photo.location}'
                            : '  ${photo.location.split(' ').take(3).join(' ')}',
                        style: TextStyle(
                          overflow: TextOverflow.visible,
                          color: Colors.white70,
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.date_range,
                        color: Colors.white70,
                        size: 15,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        '  ${formatDateKorean(photo.updateDatetime ?? 0)}',
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white70,
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 좋아요 하트
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LikeButton(
                  photoId: photo.photoId,
                  likes: photo.likes,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
