import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/sub_screen/selection_bar_view_model.dart';
import 'package:picto_frontend/widgets/picto_text_logo.dart';

class SelectionBar extends StatelessWidget {
  const SelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: context.mediaQuery.size.width,
      height: context.mediaQuery.size.height * 0.15,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PictoTextLogo(),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Obx(() => _getDropDownButton("sort", context)),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Obx(() => _getDropDownButton("period", context)),
            ),
            SizedBox(
              height: context.mediaQuery.size.height * 0.04,
              width: context.mediaQuery.size.height * 0.04,
              child: _getTagFloatingButton(),
            ),
          ],
        ),
      ),
    );
  }

  // 태그는 별도 설정창으로 이동
  // 필터 선택 : [좋아요순/조회수순] + [하루/일주일/한달/일년/전체] // 시작일은 지정 X
  DropdownButtonHideUnderline _getDropDownButton(String field, BuildContext context) {
    final selectionViewModel = Get.find<SelectionBarViewModel>();
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        // 메뉴 아이템 생성
        items: (field == "sort" ? selectionViewModel.sorts : selectionViewModel.periods)
            .map((sort) => DropdownMenuItem(
                  value: sort,
                  child: Text(sort, style: TextStyle(fontSize: 15, color: Colors.black)),
                ))
            .toList(),
        // 클릭 시 이벤트
        onChanged: field == "sort" ? selectionViewModel.changeSort : selectionViewModel.changePeriod,
        // 버튼값
        value: field == "sort"
            ? selectionViewModel.currentSelectedSort?.value
            : selectionViewModel.currentSelectedPeriod?.value,
        // 버튼 스타일
        buttonStyleData: ButtonStyleData(
          height: context.mediaQuery.size.height * 0.05,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            color: AppConfig.backgroundColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            color: AppConfig.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
          ),
        ),
        iconStyleData: IconStyleData(iconSize: 0.0),
        alignment: AlignmentDirectional.center,
      ),
    );
  }

  FloatingActionButton _getTagFloatingButton() {
    return FloatingActionButton(
      heroTag: "tag",
      onPressed: () {
        // 어떻게 구현할지 고민중 // 팝업 형식?
        // Get.toNamed('/');
      },
      shape: BeveledRectangleBorder(side: BorderSide(width: 1)),
      backgroundColor: AppConfig.backgroundColor,
      child: Icon(
        Icons.tag,
      ),
    );
  }
}
