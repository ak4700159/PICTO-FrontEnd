import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

class PhotoViewModel extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  // 가로 세로 비율에 따라 가로 세로 모드 전환
  Future<BoxFit> determineFit(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final width = image.width;
    final height = image.height;

    if (width > height) {
      return BoxFit.fitWidth;
    } else {
      return BoxFit.cover;
    }
  }
}