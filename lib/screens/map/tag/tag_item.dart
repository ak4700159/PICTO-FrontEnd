import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TagItem extends StatelessWidget {
  TagItem({super.key, required this.tagName, required this.remove});

  String tagName;
  VoidCallback remove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: context.mediaQuery.size.height * 0.06,
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Colors.black, // 테두리 색상
          //   width: 1, // 테두리 두께
          // ),
          color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
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
