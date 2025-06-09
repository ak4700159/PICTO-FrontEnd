import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';

// 실제 화면에 보여질 위젯
class AnimatedMarkerWidget extends StatelessWidget {
  final Uint8List? imageData;
  final PictoMarkerType type;

  const AnimatedMarkerWidget({super.key, this.imageData, required this.type});

  @override
  Widget build(BuildContext context) {
    Color borderColor = switch (type) {
      PictoMarkerType.userPhoto => AppConfig.mainColor,
      PictoMarkerType.folderPhoto => AppConfig.mainColor,
      PictoMarkerType.representativePhoto => Colors.white,
      PictoMarkerType.aroundPhoto => Colors.blueAccent,
      PictoMarkerType.userPos => Colors.blue,
    };

    BoxDecoration decoration = type == PictoMarkerType.userPos
        ? BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
          )
        : BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(20),
          );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: type == PictoMarkerType.userPos ? 30 : 130,
              height: type == PictoMarkerType.userPos ? 30 : 130,
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
          ),
        );
      },
    );
  }
}
