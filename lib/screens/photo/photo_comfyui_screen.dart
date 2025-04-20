import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              )),
            ),
          ),
          Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        // share_plus 패키지 활용해 소설 미디어에 공유
                      },
                      icon: Icon(
                        Icons.share,
                        size: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        // 갤러리에 다운로드
                      },
                      icon: Icon(
                        Icons.download,
                        size: 25,
                      )),
                ],
              )),
        ],
      ),
    );
  }
}
