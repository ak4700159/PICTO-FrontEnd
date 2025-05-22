import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(
                Icons.folder_rounded,
                color: AppConfig.mainColor,
                size: 30,
              ),
              Text(
                "  폴더 생성",
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.mainColor,
                ),
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
                      style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                      validator: folderValidator,
                      onSaved: (val) => folderName = val,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromRGBO(217, 217, 217, 0.19),
                        errorMaxLines: 2,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        hintStyle: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        labelStyle: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                        labelText: "폴더 제목",
                        hintText: "",
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    width: context.mediaQuery.size.width * 0.9,
                    child: TextFormField(
                      style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                      validator: folderValidator,
                      onSaved: (val) => folderContent = val,
                      maxLines: 10,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromRGBO(217, 217, 217, 0.19),
                        errorMaxLines: 2,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        hintStyle: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        labelStyle: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                        labelText: "폴더 내용",
                        hintText: "",
                      ),
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
                        Folder? newFolder =
                            await FolderManagerApi().createFolder(folderName: folderName!, content: folderContent!);
                        if (newFolder != null) {
                          Get.find<FolderViewModel>().resetFolder();
                        }
                        Get.back();
                        Get.back();
                      },
                      child: Text(
                        "폴더 생성하기",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
