import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';

class ComfyuiScreen extends StatelessWidget {
  const ComfyuiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "ComfyUI",
          style: TextStyle(
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w800,
            fontSize: 25,
            color: AppConfig.mainColor,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
