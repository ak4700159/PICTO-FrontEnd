import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/profile/calendar_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class PictoCalendar extends StatelessWidget {
  PictoCalendar({super.key});

  final calendarViewModel = Get.find<CalendarViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => TableCalendar(
      locale: 'ko_KR',
      firstDay: calendarViewModel.kFirstDay,
      focusedDay: calendarViewModel.focusedDay.value!,
      lastDay: calendarViewModel.kLastDay,
    ));
  }
}
