import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/utils/functions.dart';

import '../../models/photo.dart';
import '../../models/user.dart';
import '../../services/user_manager_service/user_api.dart';
import 'calendar_event.dart';

class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({super.key, required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            // strokeAlign: BorderSide.strokeAlignCenter,
            width: 2,
            color: Colors.grey.shade400,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 사용자 프로필
          _getPhotoTile(context: context, photoId: event.photoId, data: event.data),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "  장소 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: AppConfig.mainColor,
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
              Text(
                "  공유시간 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: AppConfig.mainColor,
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
              Text(
                "  공유자 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: AppConfig.mainColor,
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
              Text(
                "  저장된 폴더 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: AppConfig.mainColor,
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                " ${event.location}",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontWeight: FontWeight.w600, // Bold
                    fontSize: 12),
              ),
              Text(
                " ${formatDateKorean(event.uploadTime)}",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontWeight: FontWeight.w600, // Bold
                    fontSize: 12),
              ),
              Text(
                " ${event.accountName}",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontWeight: FontWeight.w600, // Bold
                    fontSize: 12),
              ),
              Text(
                " ${event.folderNames}",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    fontWeight: FontWeight.w600, // Bold
                    fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getPhotoTile(
      {required int photoId, required Uint8List? data, required BuildContext context}) {
    if (data == null) {
      return FutureBuilder(
        future: PhotoStoreApi().downloadPhoto(photoId: photoId, scale: 0.08),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.sizeOf(context).width * 0.2,
              width: MediaQuery.sizeOf(context).width * 0.2,
              child: Center(
                child: SizedBox(
                    height: MediaQuery.sizeOf(context).width * 0.05,
                    width: MediaQuery.sizeOf(context).width * 0.05,
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    )),
              ),
            );
          }

          if (snapshot.hasError) {
            return Image.asset(
              "/assets/images/picto_logo.png",
              fit: BoxFit.cover,
            );
          }

          return GestureDetector(
            onTap: () async {
              final folderViewModel = Get.find<FolderViewModel>();
              User? user = await UserManagerApi().getUserByUserId(userId: (event.ownerId));
              BoxFit fit = await determineFit(snapshot.data!);
              Photo? photo = folderViewModel.getPhoto(photoId: event.photoId);
              if (photo == null) return;
              Get.toNamed("/photo", arguments: {
                "user": user!,
                "photo": photo,
                "data": data,
                "fit": fit,
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                height: MediaQuery.sizeOf(context).width * 0.2,
                width: MediaQuery.sizeOf(context).width * 0.2,
                errorBuilder: (context, object, trace) {
                  return Image.asset(
                    "assets/images/picto_logo.png",
                    fit: BoxFit.cover,
                    height: MediaQuery.sizeOf(context).width * 0.2,
                    width: MediaQuery.sizeOf(context).width * 0.2,
                  );
                },
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () async {
        final folderViewModel = Get.find<FolderViewModel>();
        User? user = await UserManagerApi().getUserByUserId(userId: (event.ownerId));
        BoxFit fit = await determineFit(data);
        Photo? photo = folderViewModel.getPhoto(photoId: event.photoId);
        if (photo == null) return;
        Get.toNamed("/photo", arguments: {
          "user": user!,
          "photo": photo,
          "data": data,
          "fit": fit,
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.memory(
          data,
          fit: BoxFit.cover,
          height: MediaQuery.sizeOf(context).width * 0.2,
          width: MediaQuery.sizeOf(context).width * 0.2,
          errorBuilder: (context, object, trace) {
            return Image.asset(
              "assets/images/picto_logo.png",
              fit: BoxFit.cover,
              height: MediaQuery.sizeOf(context).width * 0.2,
              width: MediaQuery.sizeOf(context).width * 0.2,
            );
          },
        ),
      ),
    );
  }
}
