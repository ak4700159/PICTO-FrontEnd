import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:picto_frontend/screens/profile/calendar/calendar_view_model.dart';
import 'package:picto_frontend/services/photo_store_service/photo_store_api.dart';
import 'package:picto_frontend/utils/functions.dart';

import 'calendar_event.dart';

class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({super.key, required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey,
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
                    color: Color.fromRGBO(61, 87, 255, 1),
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
              Text(
                "  공유시간 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: Color.fromRGBO(61, 87, 255, 1),
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
              Text(
                "  공유자 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: Color.fromRGBO(61, 87, 255, 1),
                    fontWeight: FontWeight.w800, // Bold
                    fontSize: 12),
              ),
              Text(
                "  저장된 폴더 ",
                style: TextStyle(
                    fontFamily: 'NotoSansKR',
                    color: Color.fromRGBO(61, 87, 255, 1),
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
                height: context.mediaQuery.size.width * 0.2,
                width: context.mediaQuery.size.width * 0.2,
                child: Center(
                  child: SizedBox(
                      height: context.mediaQuery.size.width * 0.05,
                      width: context.mediaQuery.size.width * 0.05,
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

            return ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                height: context.mediaQuery.size.width * 0.2,
                width: context.mediaQuery.size.width * 0.2,
                errorBuilder: (context, object, trace) {
                  return Image.asset(
                    "assets/images/picto_logo.png",
                    fit: BoxFit.cover,
                    height: context.mediaQuery.size.width * 0.2,
                    width: context.mediaQuery.size.width * 0.2,
                  );
                },
              ),
            );
          });
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.memory(
        data,
        fit: BoxFit.cover,
        height: context.mediaQuery.size.width * 0.2,
        width: context.mediaQuery.size.width * 0.2,
        errorBuilder: (context, object, trace) {
          return Image.asset(
            "assets/images/picto_logo.png",
            fit: BoxFit.cover,
            height: context.mediaQuery.size.width * 0.2,
            width: context.mediaQuery.size.width * 0.2,
          );
        },
      ),
    );
  }
}
