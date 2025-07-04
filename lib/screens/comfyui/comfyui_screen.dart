import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/comfyui/comfyui_view_model.dart';
import 'package:picto_frontend/screens/comfyui/remove_screen.dart';
import 'package:picto_frontend/screens/comfyui/upscaling_screen.dart';

import '../folder/folder_view_model.dart';

class ComfyuiScreen extends StatefulWidget {
  ComfyuiScreen({super.key});

  @override
  State<ComfyuiScreen> createState() => _ComfyuiScreenState();
}

class _ComfyuiScreenState extends State<ComfyuiScreen> with SingleTickerProviderStateMixin{
  final comfyuiViewModel = Get.find<ComfyuiViewModel>();
  final tabBars = [
    Tab(text: "업스케일링"),
    Tab(text: "불필요한 영역 제거"),
  ];
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(
      length: tabBars.length,
      vsync: this,
    );
    _tabController.addListener(() {
      comfyuiViewModel.reset();
      print('my index is${_tabController.index}');
    });
  }

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
                fontSize: 20,
                color: AppConfig.mainColor,
              ),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.grey,
              indicator: BoxDecoration(
                color: AppConfig.mainColor,
              ),
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              tabs: tabBars,
            )),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            UpscalingScreen(),
            RemoveScreen(),
          ],
        ),
      ),
    );
  }
}