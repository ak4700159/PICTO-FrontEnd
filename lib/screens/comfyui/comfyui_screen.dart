import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/comfyui/comfyui_view_model.dart';
import 'package:picto_frontend/screens/comfyui/remove_screen.dart';
import 'package:picto_frontend/screens/comfyui/upscaling_screen.dart';

import '../folder/folder_view_model.dart';

class ComfyuiScreen extends StatelessWidget {
  ComfyuiScreen({super.key});
  final comfyuiViewModel = Get.find<ComfyuiViewModel>();

  @override
  Widget build(BuildContext context) {
    final folderViewModel = Get.find<FolderViewModel>();
    folderViewModel.isUpdate.value = false;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.grey,
              labelPadding: EdgeInsets.all(8),
              indicatorPadding: EdgeInsets.all(8),
              indicator: BoxDecoration(
                color: AppConfig.mainColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              tabs: [
                Tab(text: "업스케일링"),
                Tab(text: "불필요한 영역 제거"),
              ],
              onTap: (idx) {

              },
            )
        ),
        body: TabBarView(
          children: [
            UpscalingScreen(),
            RemoveScreen(),
          ],
        ),
      ),
    );
  }
}
