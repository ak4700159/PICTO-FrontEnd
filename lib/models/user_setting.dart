class UserInfo{
  UserInfo._();
  static final UserInfo _userInfo = UserInfo._();
  factory UserInfo() {
    return _userInfo;
  }

  List<String> selectedTag = [];
  List<int> titleList = [];


  bool light = false;
  bool autoRotation = false;
  bool aroundAlert = false;
  bool popularAlert = false;

  void fromTagJson() {

  }

  void fromTitleJson() {

  }

  void fromSettingJson() {

  }

}