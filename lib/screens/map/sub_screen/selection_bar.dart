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
      child: Column(
        children: [
          Container(
            width: context.mediaQuery.size.width,
            height: context.mediaQuery.size.height * 0.05,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                PictoTextLogo(),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Obx(() => _getPeriodDropDownButton()),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Obx(() => _getSortDropDownButton()),
                ),
                SizedBox(
                  height: context.mediaQuery.size.height * 0.04,
                  width: context.mediaQuery.size.height * 0.04,
                  child: FloatingActionButton(
                    onPressed: () {
                      // 어떻게 구현할지 고민중
                      // Get.toNamed('/');
                    },
                    child: Icon(
                      Icons.tag,
                    ),
                    shape: CircleBorder(side: BorderSide(width: 0)),
                    backgroundColor: AppConfig.mainColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 태그는 별도 설정창으로 이동
  // 필터 선택 : [좋아요순/조회수순] + [하루/일주일/한달/일년/전체] // 시작일은 지정 X
  DecoratedBox _getSortDropDownButton() {
    final selectionViewModel = Get.find<SelectionBarViewModel>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppConfig.mainColor, // background color of dropdown button
        borderRadius: BorderRadius.circular(50), // border raiuds of dropdown button
      ),
      child: DropdownButton(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        items: selectionViewModel.sorts
            .map((sort) => DropdownMenuItem(
                  value: sort,
                  child: Text(sort, style: TextStyle(fontSize: 15, color: AppConfig.backgroundColor),),
                ))
            .toList(),
        onChanged: selectionViewModel.changeSort,
        value: selectionViewModel.currentSelectedSort?.value,
        dropdownColor: AppConfig.mainColor,

      ),
    );
  }

  DropdownButton _getPeriodDropDownButton() {
    final selectionViewModel = Get.find<SelectionBarViewModel>();
    return DropdownButton(
      items: selectionViewModel.periods
          .map((period) => DropdownMenuItem(
                value: period,
                child: Text(period),
              ))
          .toList(),
      onChanged: selectionViewModel.changePeriod,
      value: selectionViewModel.currentSelectedPeriod?.value,
    );
  }
}
