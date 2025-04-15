import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/tag/tag_selection_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/screens/map/tag/tag_item.dart';

class TagSelectionScreen extends StatelessWidget {
  const TagSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagSelectionViewModel = Get.find<TagSelectionViewModel>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.tag,
              color: AppConfig.mainColor,
            ),
            Text("태그 선택", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Obx(() => Column(
            children: [
              SizedBox(
                height: 40,
                child: IconButton(
                  onPressed: () {
                    tagSelectionViewModel.updateMap();
                    Get.back();
                  },
                  icon: !tagSelectionViewModel.isChanged.value
                      ? Icon(
                    Icons.not_interested,
                    color: Colors.grey,
                    size: 35,
                  )
                      : Icon(
                    Icons.add_box_outlined,
                    color: Colors.green,
                    size: 35,
                  ),
                  color: Colors.white,
                ),
              ),
              !tagSelectionViewModel.isChanged.value
                  ? Text(
                "변경사항 없음",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              )
                  : Text(
                "변경사항 저장",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          )),
          SizedBox(
            width: context.mediaQuery.size.width * 0.05,
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TopBox(size: 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: context.mediaQuery.size.width * 0.9,
                  child: _getTagTextFromField(context),
                ),
              ],
            ),
            TopBox(size: 0.01),
            Text(
              "선택한 태그 목록",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: context.mediaQuery.size.width,
              height: context.mediaQuery.size.height * 0.5,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      children: [
                        TopBox(size: 0.2),
                        Image.asset(
                          "assets/images/picto_logo.png",
                          colorBlendMode: BlendMode.modulate,
                          opacity: const AlwaysStoppedAnimation(0.5),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => _getTagList(context))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTagList(BuildContext context) {
    final tagSelectionViewModel = Get.find<TagSelectionViewModel>();
    return Wrap(
      children: tagSelectionViewModel.selectedTags
          .map(
            (tag) => TagItem(
              tagName: tag,
              remove: () {
                tagSelectionViewModel.removeTag(tag);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _getTagTextFromField(BuildContext context) {
    final tagSelectionViewModel = Get.find<TagSelectionViewModel>();
    return Form(
      key: tagSelectionViewModel.formKey,
      child: TextFormField(
        controller: tagSelectionViewModel.textController,
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          errorMaxLines: 2,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelText: "태그 입력",
          hintText: "10글자 이하 태그명을 입력해주세요",
        ),
        validator: (String? input) {
          if (input?.isEmpty ?? true) {
            return "1글자 이상의 태그명을 입력해주세요";
          } else if (input!.length > 10) {
            return "10글자 이하의 태그명을 입력해주세요.";
          } else if (tagSelectionViewModel.selectedTags.contains(input)) {
            return "이미 존재하는 태그명입니다.";
          }
          return null;
        },
        onSaved: (String? input) {
          tagSelectionViewModel.addTag(input!);
        },
        onFieldSubmitted: (String? input) {
          tagSelectionViewModel.submitTag();
          tagSelectionViewModel.textController.text = "";
        },
      ),
    );
  }
}
