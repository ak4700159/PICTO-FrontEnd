import 'package:google_maps_flutter/google_maps_flutter.dart';

String? emailValidator(String? value) {
  if (value?.isEmpty ?? true) {
    return '이메일을 입력해주세요.';
  } else {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value!)) {
      return '잘못된 이메일 형식입니다.';
    }
  }
  return null;
}

String? passwdValidator(String? value) {
  if (value?.isEmpty ?? true) {
    return '비밀번호를 입력해주세요.';
  }

  // 사용자들에게 어려운 패턴을 강제
  // else {
  //   String pattern =
  //       r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
  //   RegExp regExp = RegExp(pattern);
  //   if (!regExp.hasMatch(value!)) {
  //     return '특수문자, 영문, 숫자 포함 8자 이상 15자 이내로 입력해주세요.';
  //   }
  // }
  return null;
}

String? passwdCheckValidator(String? value) {
  if (value?.isEmpty ?? true) {
    return '비밀번호를 입력해주세요.';
  }

  // 사용자들에게 어려운 패턴을 강제
  // else {
  //   String pattern =
  //       r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
  //   RegExp regExp = RegExp(pattern);
  //   if (!regExp.hasMatch(value!)) {
  //     return '특수문자, 영문, 숫자 포함 8자 이상 15자 이내로 입력해주세요.';
  //   }
  // }
  return null;
}

String? folderValidator(String? value) {
  if(value?.isEmpty ?? true) {
    return '폴더이름을 입력해주세요.';
  }
  if(value!.length > 10){
    return "10자 이하로 입력해주세요";
  }
  return null;
}

String? nameValidator(String? value) {
  if(value?.isEmpty ?? true) {
    return '이름을 입력해주세요.';
  }
  if(value!.length > 10){
    return "10자 이하로 입력해주세요";
  }
  return null;
}

String? accountValidator(String? value) {
  if(value?.isEmpty ?? true) {
    return 'PICTO에서 사용할 별명을 입력해주세요.';
  }
  if(value!.length > 10){
    return "10자 이하로 입력해주세요";
  }
  return null;
}

// 화면에 내 위치가 잡혀있는지 아닌지 검사
bool _isPointInsideBounds(LatLng point, LatLngBounds bounds) {
  return bounds.southwest.latitude <= point.latitude &&
      bounds.northeast.latitude >= point.latitude &&
      bounds.southwest.longitude <= point.longitude &&
      bounds.northeast.longitude >= point.longitude;
}
