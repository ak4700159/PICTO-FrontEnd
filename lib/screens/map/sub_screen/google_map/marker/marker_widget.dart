import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker/picto_marker.dart';

// 실제 화면에 보여질 위젯
class MarkerWidget extends StatelessWidget {
  MarkerWidget({super.key, this.imageData, required this.type});
  Uint8List? imageData;
  PictoMarkerType type;

  @override
  Widget build(BuildContext context) {
    // 마커 타입에 따라 색상 변화
    Color _borderColor = switch(type) {
      PictoMarkerType.userPhoto => Colors.white,
      PictoMarkerType.folderPhoto => Colors.grey,
      PictoMarkerType.representativePhoto => AppConfig.mainColor,
      PictoMarkerType.aroundPhoto => Colors.blueAccent,
      PictoMarkerType.userPos => Colors.blue,
    };

    // 사용자가 위치 표시만 다르게
    BoxDecoration _decoration = type == PictoMarkerType.userPos ? BoxDecoration(
      color: _borderColor,
      border: Border.all(width: 2),
      borderRadius: BorderRadius.circular(100),
      // boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
    ) : BoxDecoration(
      color: _borderColor,
      border: Border.all(width: 1, color: _borderColor),
      borderRadius: BorderRadius.circular(50),
      boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
    );

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: _decoration,
      child: ClipRRect(
        child: imageData != null
            ? Image.memory(
                imageData ?? Uint8List.fromList([0]),
                cacheWidth: 180,
              )
            : Image.asset(
                'assets/images/picto_logo.png',
                // 비율에 맞게 미리 이미지 resize
                cacheWidth: 150,
              ),
      ),
    );
  }
}
