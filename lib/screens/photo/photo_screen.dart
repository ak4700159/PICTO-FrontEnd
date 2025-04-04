import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';

import '../../models/photo.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key});

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.toLocal().toString().substring(0, "0000-00-00 00:00".length);
  }

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
              errorBuilder: (context, object, trace) =>
              const Center(child: Text("No", style: TextStyle(color: Colors.red, fontSize: 30),)),
            ),
          ),
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
                    Icon(Icons.tag_sharp, color: Colors.white70, size: 15,),
                    Text('  ${photo.tag}',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 15,),
                    Text('  ${photo.location}',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.white70, size: 15,),
                    Text('  ${_formatDate(photo.updateDatetime ?? 0)}',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
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
              Text('${photo.likes}',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
