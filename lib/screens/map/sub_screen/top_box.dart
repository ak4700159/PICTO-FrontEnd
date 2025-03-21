import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TopBox extends StatelessWidget {
  TopBox({super.key, required this.size});
  double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.mediaQuery.size.width,
      height: context.mediaQuery.size.height * size,
    );
  }
}
