import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';

class PictoTextLogo extends StatelessWidget {
  const PictoTextLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'PICTO',
      style: TextStyle(
        fontFamily: "Roboto",
        fontSize: 28,
        color: AppConfig.mainColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
