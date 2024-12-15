import 'package:app_template/microService/taskSchedule/module/WorkStationModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../widgets/tabViews/MobileTabView1.dart';
import '../component/FoldingCellTaskCard.dart';

// 功能区
List<Widget> StaggeredGridList = [
  StaggeredGridTile.count(
      crossAxisCellCount: 2, mainAxisCellCount: 2, child: Tile(0)),
  StaggeredGridTile.count(
    crossAxisCellCount: 2,
    mainAxisCellCount: 1,
    child: Tile(1),
  ),
  StaggeredGridTile.count(
    crossAxisCellCount: 1,
    mainAxisCellCount: 1,
    child: Tile(2),
  ),
  StaggeredGridTile.count(
    crossAxisCellCount: 1,
    mainAxisCellCount: 1,
    child: Tile(3),
  ),
  StaggeredGridTile.count(
    crossAxisCellCount: 4,
    mainAxisCellCount: 2,
    child: Tile(4),
  ),
];

// 今日task的todo卡片列表
List<Widget> taskCard = [];

class WorkStation extends StatefulWidget {
  const WorkStation({super.key});

  @override
  State<WorkStation> createState() => _WorkStationState();
}

class _WorkStationState extends State<WorkStation> {
  late List taskList;
  WorkStationModel workStationModel = WorkStationModel();

  getTask() async {
    taskList = await workStationModel.getAllTaskInExpirationDate();
    print("在有效期内的所有task: ${taskList}");
    // 设置list
    for (var task in taskList) {
      // 传递参数
      taskCard.add(Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: FoldingCellTaskCard(task),
      ));
    }
    print("components task 组件卡片: ${taskCard}");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // 请求有效期内的task任务
    getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("workStation".tr()),
        backgroundColor: Colors.blue,
        leading: Icon(Icons.work, color: Colors.white),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
            children: [
              // 功能区
              StaggeredGrid.count(
                crossAxisCount: 4, // 水平占用格数
                mainAxisSpacing: 4, // 垂直cell间间隔
                crossAxisSpacing: 4, // 水平cell间间隔
                // cell数组
                children: StaggeredGridList,
              ),
              // 今日task的todo区
              ListTile(
                leadingAndTrailingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: Color(0xFF2e282a)),
                leading: Text("Task ToDay"),
              ),
              ...taskCard
            ],
          )),
    );
  }
}
