import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TopBox extends StatelessWidget {
  const TopBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.mediaQuery.size.width,
      height: context.mediaQuery.size.height * 0.05,
    );
  }
}
