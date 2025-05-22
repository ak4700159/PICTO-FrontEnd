import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:get/get.dart';

class TagItem extends StatelessWidget {
  TagItem({super.key, required this.tagName, required this.remove});
  List<Color> colors = [
    Color.fromRGBO(216, 189, 255, 1),
    Color.fromRGBO(216, 198, 255, 1),
    Color.fromRGBO(176, 235, 164, 1),
    Color.fromRGBO(249, 227, 191, 1),
    Color.fromRGBO(250, 179, 179, 1),
    Color.fromRGBO(179, 208, 250, 1),
    Color.fromRGBO(255, 202, 231, 1),
  ];
  final String tagName;
  final VoidCallback remove;

  // 고정된 색상 생성을 위해 Options에 tagName 기반 seed 값을 활용
  Color getStableColorFromTag(String tag) {
    // tagName의 해시값을 기반으로 seed를 고정 (음수 방지를 위해 절댓값)
    // final int seed = tagName.hashCode.abs();
    //
    // final Options options = Options(
    //   luminosity: Luminosity.light,
    //   format: Format.rgb,
    //   seed: seed,
    // );
    //
    // return RandomColor.getColorObject(options);
    final index = tag.hashCode.abs() % colors.length;
    return colors[index];
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: context.mediaQuery.size.height * 0.06,
        decoration: BoxDecoration(
          color: getStableColorFromTag(tagName),
          borderRadius: BorderRadius.circular(10), // 전체 둥글게
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                tagName,
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: remove,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
