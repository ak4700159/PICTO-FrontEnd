import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';

// 실제 화면에 보여질 위젯
class MarkerWidget extends StatelessWidget {
  MarkerWidget({super.key, this.imageData, required this.type});

  Uint8List? imageData;
  PictoMarkerType type;

  @override
  Widget build(BuildContext context) {
    // 마커 타입에 따라 색상 변화
    Color _borderColor = switch (type) {
      PictoMarkerType.userPhoto => Colors.white,
      PictoMarkerType.folderPhoto => Colors.grey,
      PictoMarkerType.representativePhoto => AppConfig.mainColor,
      PictoMarkerType.aroundPhoto => Colors.blueAccent,
      PictoMarkerType.userPos => Colors.blue,
    };

    // 사용자가 위치 표시만 다르게
    // 사진을 감싸고 있는 Container 모양
    BoxDecoration decoration = type == PictoMarkerType.userPos
        ? BoxDecoration(
            color: _borderColor,
            // border: Border.all(width: 4),
            borderRadius: BorderRadius.circular(100),
            boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
          )
        : BoxDecoration(
            border: Border.all(
              color: _borderColor, // 테두리 색상
              width: 4, // 테두리 두께
            ),
            // Container 위젯의 테두리
            borderRadius: BorderRadius.circular(20), // 전체 둥글게
          );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: type == PictoMarkerType.userPos ? 30 : 100, // 원하는 마커 크기
        height: type == PictoMarkerType.userPos ? 30 : 100,
        decoration: decoration,
        child: ClipRRect(
          // ClipRRect 하위 위젯 테두리 지정
          borderRadius: BorderRadius.circular(18), // 이미지도 같이 둥글게 잘림
          child: imageData != null
              ? Image.memory(
                  imageData!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, object, trace) {
                    return Image.asset(
                      'assets/images/picto_logo.png',
                      fit: BoxFit.cover,
                    );
                  },
                )
              : type == PictoMarkerType.userPos
                  ? null
                  : Center(
                      child: Text(
                        'No image data',
                        style:
                            TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
        ),
      ),
    );
  }
}
