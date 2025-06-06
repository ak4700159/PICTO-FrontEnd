import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/calendar/picto_calendar.dart';

import '../../config/app_config.dart';
import 'calendar_event_tile.dart';
import 'calendar_view_model.dart';

class CalendarScreen extends StatelessWidget {
  CalendarScreen({super.key});

  final calendarViewModel = Get.find<CalendarViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              color: AppConfig.mainColor,
              size: 30,
            ),
            Text(
              "  PICTO 캘린더",
              style: TextStyle(
                fontFamily: "NotoSansKR",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.025,
            ),
            // 캘린더
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(100)
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 1,
                        color: Colors.grey.shade100,
                        blurRadius: 3,
                        offset: Offset(0, 8)),
                  ]),
              child: PictoCalendar(),
            ),
            // 캘린더 선택 날짜에 따른 리스트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "선택한 날짜의 사진 목록",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            _getCalendarEventList(),
            // 위로 올릴 수 있도록
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
            )
          ],
        ),
      ),
    );
  }

  Widget _getCalendarEventList() {
    return Obx(() => Column(
      mainAxisAlignment: MainAxisAlignment.center,
          children: calendarViewModel.selectedEvents
              .map((event) => CalendarEventTile(event: event))
              .toList(),
        ));
  }
}
