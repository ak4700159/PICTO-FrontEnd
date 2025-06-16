import 'package:get/get.dart';

class TestViewModel extends GetxController {
  Rxn<TestObject> testObject = Rxn<TestObject>(); // 초기화 필수
  RxString data = "".obs;
  static TestViewModel get to => Get.find(); // TestViewModel.to 로 접근

  @override
  void onInit() {
    super.onInit();
    testObject.value = TestObject();
  }

  void updateTestObject({required String update}) {
    testObject.value?.data = update;
    print("[INFO] ${testObject.value?.data ?? "대입 실패"}");
    testObject.refresh(); // 해당 구문이 없으면 업데이트 되지 않는다.
  }

  void updateTestSubObject({required String update}) {
    testObject.value?.subObject.subData = update;
    testObject.refresh(); // 해당 구문이 없으면 업데이트 되지 않는다.
  }

  void updateString({required String update}) {
    data.value = update;
  }
}


class TestObject {
  String data = "world";
  TestSubObject subObject = TestSubObject();
}

class TestSubObject {
  String subData = "hello";
}