import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/test_screens/test_view_model.dart';

class TestScreen extends StatelessWidget {
  TestScreen({super.key});

  final firstEditor = TextEditingController();
  final secondEditor = TextEditingController();
  final thirdEditor = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put<TestViewModel>(TestViewModel());
    final testViewModel = TestViewModel.to;
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            Container(
              margin: EdgeInsets.all(8),
              height: height * 0.2,
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(color: Colors.grey),
              ),
              child: Obx(
                () => Center(
                    child: Text(
                        "testObject.value?.data = \n${testViewModel.testObject.value?.data ?? "value error"}")),
              ),
            ),
            SizedBox(
              width: width * 0.8,
              child: TextFormField(
                controller: firstEditor,
                onFieldSubmitted: (val) {
                  testViewModel.updateTestObject(update: val);
                  firstEditor.clear();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              height: height * 0.2,
              decoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(color: Colors.grey),
              ),
              child: Obx(
                () => Center(
                    child: Text(
                        "testObject.value?.subObject.subData = \n${testViewModel.testObject.value?.subObject.subData ?? "value error"}")),
              ),
            ),
            SizedBox(
              width: width * 0.8,
              child: TextFormField(
                controller: secondEditor,
                onFieldSubmitted: (val) {
                  testViewModel.updateTestSubObject(update: val ?? "");
                  secondEditor.clear();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              height: height * 0.2,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(
                    color: Colors.grey,
                  )),
              child: Obx(
                () => Center(
                    child: Text(
                        "data.value = \n${testViewModel.testObject.value?.subObject.subData ?? "value error"}")),
              ),
            ),
            SizedBox(
              width: width * 0.8,
              child: TextFormField(
                controller: thirdEditor,
                onFieldSubmitted: (val) {
                  testViewModel.updateString(update: val);
                  thirdEditor.clear();
                },
              ),
            ),
            SizedBox(
              height: height * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
