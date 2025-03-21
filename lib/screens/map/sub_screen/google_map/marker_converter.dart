import 'package:get/get.dart';

// 컨버터의 주요역할
// 1. Photo -> PictoMarker -> GoogleMarker
// 2. 중복 확인(previous vs before)
// 3. api 호출?
class MarkerConverter{
  MarkerConverter._();
  static final MarkerConverter _converter = MarkerConverter._();
  factory MarkerConverter() {
    return _converter;
  }

  // photo manager api 호출 후 Photo json 입력
  // PhotoId를 통해 사진 데이터 다운로드(photo store api 호출)
  // PictoMarker 변환 -> 이전 Set과 비교하여 겹치는 사진이 있는지 확인(자료형이 집합이여서 고려 x)
  // Google Marker로 변환
}