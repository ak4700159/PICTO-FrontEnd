// 달력 구현 필요한 데이터?
// 1. 어떤 폴더들에 공유되어 있는지(폴더정보 -> 폴더명 정도만?)
// 2. 업로드 장소
// 3. 공유 시간(시간만 00시 00분)
// 4. 공유자

class CalendarEvent{

}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}