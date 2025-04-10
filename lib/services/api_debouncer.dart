import 'package:debounce_throttle/debounce_throttle.dart';

class ApiDebouncer {
  Debouncer debouncer = Debouncer(Duration(seconds: 1), initialValue: null);

  void setDebouncer(Function api) {
    debouncer.values.listen((value) => api);
  }
}