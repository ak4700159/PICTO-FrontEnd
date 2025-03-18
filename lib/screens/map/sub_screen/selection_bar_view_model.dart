import 'package:get/get.dart';
import 'package:debounce_throttle/debounce_throttle.dart';

import '../../../config/app_config.dart';

class SelectionBarViewModel extends GetxController {
  late Debouncer userDebouncer;
  final sorts = ["조회수순", "좋아요순"];
  final periods = ["하루", "일주일", "한달", "일년", "전체"];

  RxString? currentSelectedSort = "".obs;
  RxString? currentSelectedPeriod = "".obs;
  
  @override
  void onInit() {
    // 사용자 정보를 바탕으로 필터 기본값 설정
    userDebouncer = Debouncer(
      const Duration(seconds: AppConfig.throttleSec),
      // 초기값
      initialValue: null,
      //함수 실행할때 넣는 값이 똑같으면 실행하지 않을거냐?(false: 함수를 실행 할때마다 throttle 걸리게)
      checkEquality: false,
    );
    // TODO: implement onInit
    super.onInit();
  }

  void changeSort(sort) {
    currentSelectedSort?.value = sort ?? "좋아요순";
    // api 호출
  }

  void changePeriod(period) {
    currentSelectedPeriod?.value = period ?? "하루";
    // api 호출
  }

  void convertFromJson(Map json){
    currentSelectedPeriod?.value = json["period"];
    currentSelectedSort?.value = json["sort"];
  }
}