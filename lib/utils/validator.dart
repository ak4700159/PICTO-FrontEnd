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
