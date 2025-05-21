import 'package:get/get.dart';

class TestViewModel extends GetxController {
  Rxn<TestObject> testObject = Rxn<TestObject>();
  static TestViewModel get to => Get.find();

  void updateTestObject({required String update}) {
    testObject.value?.data = update;
  }

  void updateTestSubObject({required String update}) {
    testObject.value?.subObject.subData = update;
  }
}


class TestObject {
  String data = "world";
  TestSubObject subObject = TestSubObject();
}

class TestSubObject {
  String subData = "hello";
}