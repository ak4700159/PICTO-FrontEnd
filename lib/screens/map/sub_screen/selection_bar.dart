import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SelectionBar extends StatelessWidget {
  const SelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: context.mediaQuery.size.width,
      height: context.mediaQuery.size.height * 0.15,
      color: Colors.blue,
      child: Column(
        children: [
          Container(
            width: context.mediaQuery.size.width,
            height: context.mediaQuery.size.height * 0.05,
            color: Colors.grey,
          ),
          Text('태그 검색 필터선택')
        ],
      ),
    );
  }
}
