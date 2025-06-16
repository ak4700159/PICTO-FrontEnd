import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_view_model.dart';

class PictoCalendar extends StatelessWidget {
  PictoCalendar({super.key});

  final calendarViewModel = Get.find<CalendarViewModel>();
  final folderViewModel = Get.find<FolderViewModel>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: folderViewModel.convertCalendarEvent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    height: MediaQuery.sizeOf(context).width * 0.2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppConfig.mainColor,
                          strokeWidth: 1.3,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "캘린더 로딩 중",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: "NotoSansKR",
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width * 0.2,
                  )
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "서버 오류 ${snapshot.error.toString()} / ${snapshot.stackTrace}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "NotoSansKR",
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          // 데이터 초기화
          calendarViewModel.buildCalendarEventMap(snapshot.data!);
          return Obx(() => TableCalendar(
                locale: 'ko_KR',
                firstDay: calendarViewModel.kFirstDay,
                focusedDay: calendarViewModel.focusedDay.value!,
                lastDay: calendarViewModel.kLastDay,
                daysOfWeekHeight: 30,
                headerStyle: _getCalendarHeaderStyle(),
                // 선택 마커가 결정되기 전 동일한 마커인지 검증
                selectedDayPredicate: (day) => isSameDay(calendarViewModel.selectedDay.value, day),
                rangeStartDay: calendarViewModel.rangeStart.value,
                rangeEndDay: calendarViewModel.rangeEnd.value,
                calendarFormat: calendarViewModel.calendarFormat,
                rangeSelectionMode: calendarViewModel.rangeSelectionMode.value!,
                eventLoader: calendarViewModel.getEventsForDay,
                // 캘린더 스타일
                calendarStyle: _getCalendarStyle(),
                // 캘린더 내부 빌더 설정
                calendarBuilders: _getCalendarBuilders(),
                // 휴일 표시
                // holidayPredicate: (day) {
                //   // Every 20th day of the month will be treated as a holiday
                //   return day.day == 20;
                // },
                onDaySelected: calendarViewModel.onDaySelected,
                onRangeSelected: calendarViewModel.onRangeSelected,
                // onCalendarCreated: (controller) => _pageController = controller,
              ));
        });
  }

  HeaderStyle _getCalendarHeaderStyle() {
    return HeaderStyle(
      headerPadding: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.grey.shade100,
      ),
      titleCentered: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontFamily: "NotoSansKR",
        fontWeight: FontWeight.w700,
        color: AppConfig.mainColor,
      ),
      formatButtonVisible: false,
    );
  }

  CalendarStyle _getCalendarStyle() {
    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: AppConfig.mainColor,
        shape: BoxShape.circle,
      ),
      rangeStartDecoration: BoxDecoration(
        color: AppConfig.mainColor,
        shape: BoxShape.circle,
      ),
      rangeEndDecoration: BoxDecoration(
        color: AppConfig.mainColor,
        shape: BoxShape.circle,
      ),
      rangeHighlightColor: Color.fromRGBO(238, 227, 253, 0.8),
      // withinRangeDecoration: const BoxDecoration(
      //   color: AppConfig.mainColor,
      // ),
      tableBorder: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.shade200,
        ),
        verticalInside: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      cellMargin: const EdgeInsets.all(13.0),
      markerDecoration: BoxDecoration(color: AppConfig.mainColor),
    );
  }

  CalendarBuilders _getCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, day, events) {
        Color color = Colors.grey;
        FontWeight fontWeight = FontWeight.w300;
        if (events.isNotEmpty) {
          color = Colors.black;
          fontWeight = FontWeight.w500;
        }

        if (events.length > 5) {
          color = Colors.red;
          fontWeight = FontWeight.w600;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey, width: 0.5)),
              child: Text("${events.length}",
                  style: TextStyle(
                    color: color,
                    fontWeight: fontWeight,
                    fontFamily: "NotoSansKR",
                    fontSize: 9,
                  )),
            ),
          ],
        );
      },
      dowBuilder: (context, day) {
        switch (day.weekday) {
          case 1:
            return Center(
              child: Text(
                '월',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500),
              ),
            );
          case 2:
            return Center(
              child: Text(
                '화',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500),
              ),
            );
          case 3:
            return Center(
              child: Text(
                '수',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500),
              ),
            );
          case 4:
            return Center(
              child: Text(
                '목',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500),
              ),
            );
          case 5:
            return Center(
              child: Text(
                '금',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500),
              ),
            );
          case 6:
            return Center(
              child: Text(
                '토',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500, color: Colors.blue),
              ),
            );
          case 7:
            return Center(
              child: Text(
                '일',
                style: TextStyle(fontFamily: "NotoSansKR", fontWeight: FontWeight.w500, color: Colors.red),
              ),
            );
        }
      },
      defaultBuilder: (context, day, focusedDay) {
        if (calendarViewModel.getEventsForDay(day).isEmpty) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontFamily: "NotoSansKR",
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        return Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.bold,
              color: Colors.black, // 일반 날짜 색상
            ),
          ),
        );
      },
    );
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
