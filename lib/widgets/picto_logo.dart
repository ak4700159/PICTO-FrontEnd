import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PictoLogo extends StatelessWidget {
  PictoLogo({super.key, required this.scale, required this.fontSize});

  double scale = 1;
  double fontSize = 30;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Image.asset(
            'assets/images/picto_logo.png',
            fit: BoxFit.cover,
            scale: scale,
          ),
        ),
        SizedBox(
          height: context.mediaQuery.size.height * 0.03,
        ),
        Text(
          "PICTO",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        )
      ],
    );
  }
}
