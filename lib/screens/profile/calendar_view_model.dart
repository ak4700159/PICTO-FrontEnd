import 'dart:collection';

import 'package:get/get.dart';
import 'package:picto_frontend/screens/profile/calendar_event.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewModel extends GetxController {
  Rxn<LinkedHashMap> events = Rxn();
  RxList<CalendarEvent> selectedEvents = <CalendarEvent>[].obs;
  final kToday = DateTime.now();
  final kFirstDay = DateTime(2020, 1, 1);
  final kLastDay = DateTime(2030, 1, 1);

  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  Rxn<DateTime> focusedDay = Rxn();
  Rxn<DateTime?> selectedDay = Rxn();
  Rxn<DateTime?> rangeStart = Rxn();
  Rxn<DateTime?> rangeEnd = Rxn();


  @override
  void onInit() {
    focusedDay.value = DateTime.now();
    // TODO: implement onInit
    super.onInit();
  }

  // 해싱값
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }
}