import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/screens/map/google_map/marker/picto_marker.dart';
import '../../../../../config/app_config.dart';
import '../../../../../models/photo.dart';

// 아직 미완성 -> 자료 조사중
class PictoMarkerInfo extends StatelessWidget {
  PictoMarkerInfo({super.key, required this.type, required this.photo});

  Photo photo;
  PictoMarkerType type;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    Color borderColor = switch (type) {
      PictoMarkerType.userPhoto => Colors.red,
      PictoMarkerType.folderPhoto => Colors.blue,
      PictoMarkerType.aroundPhoto => AppConfig.mainColor,
      PictoMarkerType.representativePhoto => Colors.grey,
      _ => Colors.white,
    };

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
      ),
      child: Row(
        children: [
          FloatingActionButton(onPressed: () {}, heroTag: photo.photoId.toString(), child: Text("상세 보기"),),
          // 사진 정보 -> 자세히 보기 버튼 구현하기
          //Text(data)
        ],
      ),
    );
  }
}
