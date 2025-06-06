import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/test_screens/test_view_model.dart';

class TestScreen extends StatelessWidget {
  TestScreen({super.key});

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    Get.put<TestViewModel>(TestViewModel());
    final testViewModel = TestViewModel.to;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.2,),
            Container(
              height: height * 0.2,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey)),
              child: Obx(
                () => Center(child: Text(testViewModel.testObject.value?.data ?? "value error")),
              ),
            ),
            TextFormField(
              controller: textController,
              onSaved: (val) {
                testViewModel.updateTestObject(update: val ?? "");
                textController.clear();
              },
            ),
            Container(
              height: height * 0.2,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey)),
              child: Obx(
                () => Center(child: Text(testViewModel.testObject.value?.subObject.subData ?? "value error")),
              ),
            ),
            TextFormField(
              controller: textController,
              onSaved: (val) {
                testViewModel.updateTestSubObject(update: val ?? "");
              },
            ),
          ],
        ),
      ),
    );
  }
}
