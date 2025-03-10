import 'package:get/get.dart';

class UserConfig extends GetxController{
  UserSetting setting = UserSetting();
  Filter filter = Filter();
  List<Title> titles = [];
  List<int> blocks = [];
  List<int> marks = [];

}

class UserSetting{
  bool lightMode = true;
  bool autoRotation = true;
  bool aroundAlert = false;
  bool popularAlert = false;
}

class Filter{
  List<Tag> tags = [];
  String sort = "좋아요순";
  String period = "한달";
}

class Title{

}

class Tag{
  Tag({required this.tagName});
  String tagName;
}