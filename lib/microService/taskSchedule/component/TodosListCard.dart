// 列表展示todos
import 'package:app_template/microService/taskSchedule/module/WorkStationModel.dart';
import 'package:app_template/states/TaskState.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_clock/one_clock.dart';
import 'package:provider/provider.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import '../module/Model.dart';
import '../../../database/LocalStorage.dart';
import '../widget/buildFieldInfo.dart';
import 'TodosCard.dart';
import 'TodosList.dart';

class TodoListCard extends StatefulWidget {
  Task task;
  TodoListCard(this.task, {super.key});

  @override
  State<TodoListCard> createState() => _TodoListCardState(task);
}

class _TodoListCardState extends State<TodoListCard> {
  _TodoListCardState(this.task);
  Task? task;
  late Map<String, dynamic> data;
  WorkStationModel workStationModel = WorkStationModel();

  get cardA => null;

  // 获取对应的task的所有todos
  Future<Map> getTodosInTask(Task task) async {
    // 获取文件内容
    Map data = await workStationModel.getFileTaskContentByTaskId(task.taskId!);
    print("****************************************************************");
    print("data数据: ${data}");

    return data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTodosInTask(task!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FutureBuilder<Map>(
        future: getTodosInTask(task!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['data'] == null) {
            return Center(child: Text('No data found'));
          } else {
            final data = snapshot.data!;
            print("+++++++++++++++这里啊啊啊啊啊+++++++++++++++++++++++");
            print(data);

            // 模式切换
            bool switchToggle = Provider.of<TaskState>(context).switchToggle;
            if (switchToggle) return TaskTodosCard(data);
            return TaskTodosList(data);
          }
        },
      ),
    );
  }

  // inner布局内容
  Widget gridLayout(Task task) {
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
              child: Text(
                "mode".tr(),
                style: GoogleFonts.aldrich(
                  color: Color(0xFF2e282a),
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      ],
    );
  }
}
