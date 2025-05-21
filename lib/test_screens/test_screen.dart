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
    Get.put<TestViewModel>(TestViewModel());
    final testViewModel = TestViewModel.to;
    return Scaffold(
      body: Column(
        children: [
          Obx(() => Text(testViewModel.testObject.value?.data ?? "value error")),
          TextFormField(
            controller: textController,
            onSaved: (val) {
              testViewModel.updateTestObject(update: val ?? "");
            },
          ),

          Obx(() => Text(testViewModel.testObject.value?.subObject.subData ?? "value error")),
          TextFormField(
            controller: textController,
            onSaved: (val) {
              testViewModel.updateTestSubObject(update: val ?? "");
            },
          ),
        ],
      ),
    );
  }
}
