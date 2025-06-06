import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/selection_bar_view_model.dart';
import 'package:picto_frontend/widgets/picto_text_logo.dart';

class SelectionBar extends StatelessWidget {
  const SelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.08,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PictoTextLogo(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.3,
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Obx(() => _getDropDownButton("period", context)),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.04,
              width: MediaQuery.sizeOf(context).height * 0.04,
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
                  child: Center(
                    child: Text(
                      sort,
                      style: TextStyle(
                        fontFamily: "NotoSansKR",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
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
          height: MediaQuery.sizeOf(context).height * 0.05,
          decoration: BoxDecoration(
            // border: Border.all(width: 1),
            color: AppConfig.backgroundColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          padding: EdgeInsets.all(0),
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
        Get.toNamed('/tag');
      },
      // shape: BeveledRectangleBorder(side: BorderSide(width: 1)),
      backgroundColor: AppConfig.backgroundColor,
      child: Icon(
        Icons.tag,
      ),
    );
  }
}
