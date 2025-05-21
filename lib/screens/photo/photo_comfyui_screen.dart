import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // NEW
import 'package:picto_frontend/utils/popup.dart';

class PhotoComfyuiScreen extends StatelessWidget {
  PhotoComfyuiScreen({super.key});

  final Uint8List data = Get.arguments["data"];
  final BoxFit fit = Get.arguments["fit"];

  @override
  Widget build(BuildContext context) {
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
                    showPositivePopup("최근 항목에 사진이 저장되었습니다!");
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
