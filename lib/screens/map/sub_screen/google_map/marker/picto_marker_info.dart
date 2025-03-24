import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../config/app_config.dart';


// 아직 미완성 -> 자료 조사중
class PictoMarkerInfo extends StatelessWidget {
  PictoMarkerInfo({super.key, required this.type});
  int type;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    Color borderColor = switch(type) {
      1 => Colors.red,
      2 => Colors.blue,
      3 => AppConfig.mainColor,
      _ => Colors.grey
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
          // 사진 정보 -> 자세히 보기 버튼 구현하기
          //Text(data)
        ],
      ),
    );
  }
}
