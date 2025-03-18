import 'package:get/get.dart';

class SelectionBarViewModel extends GetxController {
  final sorts = ["조회수순", "좋아요순", "미선택"];
  final periods = ["하루", "일주일", "한달", "일년", "전체", "미선택"];

  RxString? currentSelectedSort = "미선택".obs;
  RxString? currentSelectedPeriod = "미선택".obs;
  
  @override
  void onInit() {
    // 사용자 정보를 바탕으로 필터 기본값 설정


    // TODO: implement onInit
    super.onInit();
  }

  void changeSort(sort) {
    currentSelectedSort?.value = sort ?? "미선택";
  }

  void changePeriod(period) {
    currentSelectedPeriod?.value = period ?? "미선택";
  }

}