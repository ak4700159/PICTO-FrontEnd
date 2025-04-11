import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/services/folder_manager_service/folder_api.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';

import '../../../config/app_config.dart';
import '../../../models/folder.dart';
import '../../../utils/get_widget.dart';
import '../../../utils/validator.dart';

class FolderCreateScreen extends StatelessWidget {
  FolderCreateScreen({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? folderName;
    String? folderContent;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(
              Icons.folder_open,
              color: AppConfig.mainColor,
              weight: 10,
            ),
            Text(
              "  폴더 생성",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ],
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TopBox(size: 0.05),
                PictoLogo(
                  scale: 1.5,
                  fontSize: 0,
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: context.mediaQuery.size.width * 0.9,
                  child: TextFormField(
                    validator: folderValidator,
                    onSaved: (val) => folderName = val,
                    decoration: getCustomInputDecoration2(label: "폴더 제목"),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: context.mediaQuery.size.width * 0.9,
                  child: TextFormField(
                    validator: folderValidator,
                    onSaved: (val) => folderContent = val,
                    maxLines: 10,
                    decoration: getCustomInputDecoration2(label: "폴더 내용"),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: context.mediaQuery.size.width * 0.9,
                  child: FloatingActionButton(
                    backgroundColor: AppConfig.mainColor,
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        formKey.currentState?.save();
                      }
                      Folder? newFolder = await FolderManagerApi().createFolder(folderName: folderName!, content: folderContent!);
                      Get.back();
                    },
                    child: Text(
                      "폴더 생성하기",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
