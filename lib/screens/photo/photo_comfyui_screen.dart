import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // NEW
import 'package:picto_frontend/utils/popup.dart';

class PhotoComfyuiScreen extends StatelessWidget {
  PhotoComfyuiScreen({super.key});

  final Uint8List data = Get.arguments["data"];
  // final BoxFit fit = Get.arguments["fit"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 사진
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.1,
              maxScale: 3.6,
              child: Image.memory(
                data,
                fit: BoxFit.contain,
                errorBuilder: (context, object, trace) => const Center(
                  child: Text(
                    "사진 다운로드 오류",
                    style: TextStyle(color: Colors.red, fontSize: 30),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final result = await ImageGallerySaverPlus.saveImage(
                      data,
                      quality: 100,
                      name: "flutter_image_${DateTime.now().millisecondsSinceEpoch}",
                    );
                    showMsgPopup(msg: "최근 항목에 사진이 저장되었습니다!", space: 0.4);
                  },
                  icon: Icon(
                    Icons.download,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
