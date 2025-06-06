import 'dart:collection';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/calendar/picto_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_event.dart';

class CalendarViewModel extends GetxController {
  // 캘린더에 필요한 전체 데이터셋
  // 여기서 중요한 건 사진 데이터를 바로 다운로드 하지말것?
  Rxn<LinkedHashMap> events = Rxn<LinkedHashMap<DateTime, List<CalendarEvent>>>();

  // 선택된
  RxList<CalendarEvent> selectedEvents = <CalendarEvent>[].obs;
  final kToday = DateTime.now();
  final kFirstDay = DateTime(2001, 1, 1);
  final kLastDay = DateTime(2030, 1, 1);

  CalendarFormat calendarFormat = CalendarFormat.month;
  Rxn<RangeSelectionMode> rangeSelectionMode =
      Rxn(); // Can be toggled on/off by longpressing a date
  Rxn<DateTime> focusedDay = Rxn();
  Rxn<DateTime?> selectedDay = Rxn();
  RxSet<DateTime> selectedDays = RxSet(LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  ));
  Rxn<DateTime?> rangeStart = Rxn();
  Rxn<DateTime?> rangeEnd = Rxn();

  @override
  void onInit() {
    super.onInit();
    focusedDay.value = DateTime.now();
    events.value = LinkedHashMap<DateTime, List<CalendarEvent>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    // final now = DateTime.now();
    // final rand = Random();
    // for (int i = 0; i < 200; i++) {
    //   final offset = rand.nextInt(61) - 30; // -30 ~ +30
    //   final date = DateTime(now.year, now.month, now.day + offset);
    //
    //   // 동일 날짜에 여러 이벤트를 넣기 위해 리스트 병합
    //   events.value!.putIfAbsent(date, () => <CalendarEvent>[]);
    //   events.value![date]!.add(CalendarEvent(
    //     photoId: i,
    //     folderId: rand.nextInt(5),
    //     folderNames: ["Folder ${rand.nextInt(5)}"],
    //     ownerId: rand.nextInt(100),
    //     accountName: "user$i",
    //     uploadTime: DateTime.now().millisecondsSinceEpoch,
    //     location: "위치 ${rand.nextInt(10)}",
    //   ));
    // }
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
  }

  bool get canClearSelection =>
      selectedDays.isNotEmpty || rangeStart.value != null || rangeEnd.value != null;

  // 해당 일자의 사진 조회
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return events.value?[day] ?? [];
  }

  // 기간 동안의 사진 조회
  List<CalendarEvent> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ...getEventsForDay(d),
    ];
  }

  // 시작날짜 ~ 종료날짜 -> 일 단위로 검색해 사진 조회
  List<CalendarEvent> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  // 특정 날만 선택(캘린더 이벤트)
  void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
    print("select day");
    if (isSameDay(selectedDay.value, newSelectedDay)) {
      // 이미 선택된 날짜를 다시 누르면 해제
      // selectedDay.value = null;
      // selectedEvents.value = [];
    } else {
      selectedDay.value = newSelectedDay;
      selectedEvents.value = getEventsForDay(newSelectedDay);
    }
    focusedDay.value = newFocusedDay;
    rangeStart.value = null;
    rangeEnd.value = null;
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
  }

  // 범위로 날짜 선택(캘린더 이벤트)
  void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedNewDay) {
    print("select range");
    focusedDay.value = focusedNewDay;
    rangeStart.value = start;
    rangeEnd.value = end;
    selectedDays.clear();
    if(rangeSelectionMode.value == RangeSelectionMode.toggledOn) {
      rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    } else {
      rangeSelectionMode.value = RangeSelectionMode.toggledOn;
    }

    if (start != null && end != null) {
      selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      selectedEvents.value = getEventsForDay(start);
    } else if (end != null) {
      selectedEvents.value = getEventsForDay(end);
    }
  }

  // 달력 데이터 초기화
  Future<void> buildCalendarEventMap(List<CalendarEvent> notOrderedEvents) async {
    final grouped = LinkedHashMap<DateTime, List<CalendarEvent>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    for (final event in notOrderedEvents) {
      final date = DateTime(
        DateTime.fromMillisecondsSinceEpoch(event.uploadTime).year,
        DateTime.fromMillisecondsSinceEpoch(event.uploadTime).month,
        DateTime.fromMillisecondsSinceEpoch(event.uploadTime).day,
      );

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(event);
    }
    events.value = grouped;
  }
}
