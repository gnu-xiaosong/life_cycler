import 'package:app_template/states/TaskState.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:expandable_cardview/expandable_cardview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:folding_cell/folding_cell/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../database/LocalStorage.dart';
import '../module/WorkStationModel.dart';
import '../widget/buildFieldInfo.dart';
import 'TodosListCard.dart';

class FoldingCellTaskCard extends StatelessWidget {
  final _foldingCellKey = GlobalKey<SimpleFoldingCellState>();
  late Task task;
  WorkStationModel workStationModel = WorkStationModel();

  FoldingCellTaskCard(this.task);
  @override
  Widget build(BuildContext context) {
    return BrnShadowCard(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        circular: 15,
        blurRadius: 7,
        // shadowColor: Colors.white30,
        child: ExpandablePanel(
          header: Text(task.name.tr()),
          collapsed: Text(
            task.description.toString(),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          expanded: gridLayout(task),
          // builder: (BuildContext context, Widget, _) {
          //   return gridLayout(task);
          // },
        ));
  }

  Widget _buildFrontWidget(Task task) {
    return Container(
      color: Color(0xFFffcd3c),
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.0),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              task.name ?? '任务'.tr(),
              style: GoogleFonts.aldrich(
                color: Color(0xFF2e282a),
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: TextButton(
              onPressed: () => _foldingCellKey?.currentState?.toggleFold(),
              child: Text(
                "OPEN",
                style: TextStyle(color: Colors.black),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(80, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerWidget(Task task) {
    return Container(
      color: Color(0xFFecf2f9),
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              task.name.toString().tr(),
              style: GoogleFonts.aldrich(
                color: Color(0xFF2e282a),
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: gridLayout(task),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: TextButton(
              onPressed: () => _foldingCellKey?.currentState?.toggleFold(),
              child: Text(
                "Close",
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(80, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // inner布局
  Widget gridLayout(Task task) {
    return Consumer<TaskState>(builder: (context, taskState, child) {
      return StaggeredGrid.count(
        crossAxisCount: 9,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 3,
            mainAxisCellCount: 1,
            child: buildFieldInfo(
                'priority'.tr(),
                BrnTagCustom(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  border: Border.all(width: 1, color: Colors.redAccent),
                  tagBorderRadius: const BorderRadius.all(Radius.circular(6)),
                  backgroundColor: Colors.transparent,
                  textPadding: EdgeInsets.all(2),
                  tagText: task.priority.toString().tr(),
                  textColor: task.priority == "Low"
                      ? Colors.blue
                      : (task.priority == "Medium" ? Colors.green : Colors.red),
                )),
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 1,
              child: buildFieldInfo(
                  'status'.tr(),
                  BrnTagCustom.buildBorderTag(
                    tagText: task.status.toString().tr(),
                    textColor: task.status == "pending"
                        ? Colors.blue
                        : (task.status == "in progress"
                            ? Colors.redAccent
                            : Colors.green),
                    borderColor: Colors.red,
                    borderWidth: 1,
                    fontSize: 10,
                    textPadding: EdgeInsets.all(2),
                  ))),
          StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 1,
              child: buildFieldInfo(
                  'category'.tr(),
                  BrnTagCustom(
                    tagText: task.category?.tr() ?? "N/A",
                    backgroundColor: Colors.cyanAccent,
                    tagBorderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(5)),
                  ))),
          StaggeredGridTile.count(
            crossAxisCellCount: 3,
            mainAxisCellCount: 1,
            child: buildFieldInfo(
                'label'.tr(),
                Row(
                  children: [
                    for (String item in (task.label ?? "").split(",").toList())
                      BrnTagCustom(
                        tagText: item.isEmpty ? "N/A" : item.tr(),
                        backgroundColor: Colors.green,
                        tagBorderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(5)),
                      )
                  ],
                )),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 6,
            mainAxisCellCount: 1,
            child: buildFieldInfo(
                'desc'.tr(), Text(task.description?.tr() ?? "N/A")),
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 9,
              mainAxisCellCount: 1,
              child: buildFieldInfo('startTime'.tr(),
                  Text(workStationModel.setDateTimeFormate(task.startTime!))
                  // task.startTime.toString() ?? "N/A"),
                  )),
          StaggeredGridTile.count(
              crossAxisCellCount: 9,
              mainAxisCellCount: 1,
              child: buildFieldInfo(
                'endTime'.tr(),
                Text(workStationModel.setDateTimeFormate(task.endTime!)),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 4,
              mainAxisCellCount: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "TODOS".tr(),
                  style: GoogleFonts.aldrich(
                    color: Color(0xFF2e282a),
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 5,
              mainAxisCellCount: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: ToggleSwitch(
                  minWidth: 60.0,
                  minHeight: 30,
                  cornerRadius: 20.0,
                  activeBgColors: [
                    [Colors.green[800]!],
                    [Colors.red[800]!]
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  initialLabelIndex: taskState.switchToggle ? 1 : 0,
                  totalSwitches: 2,
                  labels: ['list'.tr(), 'card'.tr()],
                  radiusStyle: true,
                  onToggle: (index) {
                    // 切换模式
                    taskState.switchToggleMode();
                    print('switched to: $index');
                  },
                ),
              )),

          //*******************Todos******************
          StaggeredGridTile.count(
            crossAxisCellCount: 9,
            mainAxisCellCount: 12,
            child: TodoListCard(task),
          )
        ],
      );
    });
  }
}
