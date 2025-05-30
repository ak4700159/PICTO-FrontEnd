import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/tag/tag_selection_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/screens/map/tag/tag_item.dart';

class TagSelectionScreen extends StatelessWidget {
  TagSelectionScreen({Key? key}) : super(key: key);
  final tagSelectionViewModel = Get.find<TagSelectionViewModel>();

  @override
  Widget build(BuildContext context) {
    final tagSelectionViewModel = Get.find<TagSelectionViewModel>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
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
                                Icons.check,
                                color: AppConfig.mainColor,
                                size: 35,
                                // fill: 5,
                              ),
                        color: Colors.white,
                      ),
                    ),
                    // !tagSelectionViewModel.isChanged.value
                    //     ? Text(
                    //         "변경사항 없음",
                    //         style: TextStyle(
                    //           fontFamily: "NotoSansKR",
                    //           fontSize: 11,
                    //           fontWeight: FontWeight.w500,
                    //           color: Colors.black,
                    //         ),
                    //       )
                    //     : Text(
                    //         "변경사항 저장",
                    //         style: TextStyle(
                    //           fontFamily: "NotoSansKR",
                    //           fontSize: 11,
                    //           fontWeight: FontWeight.w500,
                    //           color: Colors.green,
                    //         ),
                    //       ),
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
              TopBox(size: 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "태그 선택  ",
                    style: TextStyle(
                      fontFamily: "NotoSansKR",
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.search_rounded,
                    color: AppConfig.mainColor,
                  ),
                ],
              ),
              TopBox(size: 0.03),
              Container(
                height: context.mediaQuery.size.height * 0.105,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _getTagTextFromField(context),
                    ),
                    Expanded(
                      flex: 1,
                      child: _sendButton(context),
                    ),
                  ],
                ),
              ),
              TopBox(size: 0.005),
              Text(
                "선택한 태그 목록",
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                width: context.mediaQuery.size.width,
                height: context.mediaQuery.size.height * 0.5,
                decoration: BoxDecoration(
                  // color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
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
      ),
    );
  }

  Widget _getTagList(BuildContext context) {
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
    return Form(
      key: tagSelectionViewModel.formKey,
      child: Container(
        margin: EdgeInsets.all(8),
        height: context.height * 0.1,
        child: TextFormField(
          controller: tagSelectionViewModel.textController,
          style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade300,
            hintText: "태그 입력",
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              gapPadding: 0,
              borderRadius: BorderRadius.circular(20),
            ),
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
            // tagSelectionViewModel.submitTag();
            // tagSelectionViewModel.textController.text = "";
          },
        ),
      ),
    );
  }

  Widget _sendButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.only(top: 10),
      icon: const Icon(Icons.send, color: Colors.grey, size: 25),
      onPressed: () {
        tagSelectionViewModel.submitTag();
        tagSelectionViewModel.textController.text = "";
      },
    );
  }
}
