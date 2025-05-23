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

// 검색해서 나온 사진 터치 시 나오는 화면
class PhotoChatbotScreen extends StatelessWidget {
  const PhotoChatbotScreen({super.key});

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
            child: Image.memory(
              data,
              fit: fit,
              errorBuilder: (context, object, trace) => const Center(
                  child: Text(
                "[ERROR]",
                style: TextStyle(color: Colors.red, fontSize: 30),
              )),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _getButton(),
          ),
          // 하단 정보 오버레이
          Positioned(bottom: 0, left: 0, right: 0, child: _getInfoWidget(photo, context)),
        ],
      ),
    );
  }

  // 버튼
  Widget _getButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        children: [
          // IconButton(
          //     onPressed: () {
          //       // 갤러리에 다운로드
          //     },
          //     icon: Icon(
          //       Icons.download,
          //       size: 25,
          //       color: Colors.white,
          //     )),
        ],
      ),
    );
  }

  Widget _getInfoWidget(Photo photo, BuildContext context) {
    return Container(
      width: context.mediaQuery.size.width,
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
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              // 아이콘 다른 사용자
              child: Icon(Icons.person, color: Colors.grey[800]),
            ),
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
                        '  ${photo.location.split(' ').take(3).join(' ')}',
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
                Icon(Icons.favorite, color: AppConfig.mainColor),
                const SizedBox(height: 4),
                Text('${photo.likes}', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
