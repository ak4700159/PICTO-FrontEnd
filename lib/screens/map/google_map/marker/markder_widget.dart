import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';

// 실제 화면에 보여질 위젯
class MarkerWidget extends StatelessWidget {
  final Uint8List? imageData;
  final PictoMarkerType type;

  const MarkerWidget({super.key, this.imageData, required this.type});

  @override
  Widget build(BuildContext context) {
    Color _borderColor = switch (type) {
      PictoMarkerType.userPhoto => Colors.white,
      PictoMarkerType.folderPhoto => Colors.grey,
      PictoMarkerType.representativePhoto => AppConfig.mainColor,
      PictoMarkerType.aroundPhoto => Colors.blueAccent,
      PictoMarkerType.userPos => Colors.blue,
    };

    BoxDecoration decoration = type == PictoMarkerType.userPos
        ? BoxDecoration(
      color: _borderColor,
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)
      ],
    )
        : BoxDecoration(
      border: Border.all(color: _borderColor, width: 4),
      borderRadius: BorderRadius.circular(20),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: type == PictoMarkerType.userPos ? 30 : 100,
        height: type == PictoMarkerType.userPos ? 30 : 100,
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
              style: TextStyle(
                fontSize: 30,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}