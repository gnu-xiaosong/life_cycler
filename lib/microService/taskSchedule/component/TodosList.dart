import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_clock/one_clock.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import '../../../states/TaskState.dart';
import '../module/Model.dart';
import '../module/WorkStationModel.dart';
import 'SwitchIconMode.dart';

class TaskTodosList extends StatefulWidget {
  Map data;
  TaskTodosList(this.data, {super.key});

  @override
  State<TaskTodosList> createState() => _TaskTodosListState(data);
}

class _TaskTodosListState extends State<TaskTodosList> {
  _TaskTodosListState(this.data);

  Map data;
  WorkStationModel workStationModel = WorkStationModel();
  List<String> remainTimeList = [];
  Timer? _timer;
  // 模式切换
  bool? switchToggle;

  @override
  Widget build(BuildContext context) {
    // 模式切换
    switchToggle = Provider.of<TaskState>(context).switchToggle;
    return listTodos(data);
  }

  @override
  void initState() {
    super.initState();
    print("***********************數據******************");
    print(data);

    for (var item in data["data"]) {
      remainTimeList.add('');
    }
    startCountDown();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  void didUpdateWidget(TaskTodosList oldWidget) {
    super.didUpdateWidget(oldWidget);
    startCountDown();
  }

  void startCountDown() {
    const repeatPeriod = Duration(seconds: 1);

    _timer?.cancel();
    _timer = Timer.periodic(repeatPeriod, (timer) {
      var nowTime = DateTime.now();
      print("+++++++++++++++++++++++++++++++++");
      print(data);

      for (int idx = 0; idx < data["data"].length; idx++) {
        Map item = data["data"][idx];
        print("item 数据:");
        print(item);

        var endTime = DateTime.parse(item["startTime"]);
        if (endTime.millisecondsSinceEpoch - nowTime.millisecondsSinceEpoch <
            1000 * 60) {
          setState(() {
            remainTimeList[idx] = '超时';
          });
          continue;
        }

        calculateTime(idx, nowTime, endTime);
      }
    });
  }

  void calculateTime(int index, DateTime nowTime, DateTime endTime) {
    var _surplus = endTime.difference(nowTime);
    int day = (_surplus.inSeconds ~/ 3600) ~/ 24;
    int hour = (_surplus.inSeconds ~/ 3600) % 24;
    int minute = _surplus.inSeconds % 3600 ~/ 60;
    int second = _surplus.inSeconds % 60;

    remainTimeList[index] = '';
    if (day > 0) {
      remainTimeList[index] = day.toString() + '天';
    }
    if (hour > 0 || (day > 0 && hour == 0)) {
      remainTimeList[index] = remainTimeList[index] + hour.toString() + '小时';
    }
    remainTimeList[index] = remainTimeList[index] + minute.toString() + '分钟';
    remainTimeList[index] = remainTimeList[index] + second.toString() + "秒";

    setState(() {});
  }

  Widget listTodos(Map data) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    return TransformableListView.builder(
      getTransformMatrix: getTransformMatrix,
      itemBuilder: (context, index) {
        return ExpansionTileCard(
          key: Key(index.toString()),
          leading: leading1(index, data["data"]),
          title: Text(data["data"][index]["name"].toString().tr(),
              style: GoogleFonts.aldrich(
                color: Color(0xFF2e282a),
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              )),
          subtitle: Text(
              (data["data"][index]["description"] ?? "N/A").toString().tr(),
              style: GoogleFonts.aldrich(
                color: Color(0xFF2e282a),
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              )),
          children: <Widget>[
            // const Divider(
            //   thickness: 1.0,
            //   height: 1.0,
            // ),

            TodoItemBottom(data["taskID"], data["data"][index]),
          ],
        );
      },
      itemCount: data["data"].length,
    );
  }

  Matrix4 getTransformMatrix(TransformableListItem item) {
    const endScaleBound = 0.3;
    final animationProgress = item.visibleExtent / item.size.height;
    final paintTransform = Matrix4.identity();

    if (item.position != TransformableListItemPosition.middle) {
      final scale = endScaleBound + ((1 - endScaleBound) * animationProgress);

      paintTransform
        ..translate(item.size.width / 2)
        ..scale(scale)
        ..translate(-item.size.width / 2);
    }

    return paintTransform;
  }

  Widget leading1(int index, List data) {
    Map? re = workStationModel.nowDateIndateDurationPeriod(
        DateTime.parse(data[index]["startTime"]),
        DateTime.parse(data[index]["endTime"]));

    print("result:${re}");

    // 时刻距离开始的间隔
    String relativeStartSecondString =
        workStationModel.secondFormateTime(re?["relativeStartSecond"]);
    // 时刻距离结束的间隔
    String relativeEndSecondString =
        workStationModel.secondFormateTime(re?["relativeEndSecond"]);

    if (re?["type"] == Range.FORWARD) {
      return Text(
        relativeStartSecondString,
        style: GoogleFonts.aldrich(
          color: Color(0xFF2e282a),
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      );
      return DigitalClock(
          showSeconds: false,
          isLive: false,
          digitalClockTextColor: Colors.black,
          decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          datetime: DateTime.parse(remainTimeList[index]));
    } else if (re?["type"] == Range.HANDLING) {
      // 中
      return Text(
        relativeStartSecondString,
        style: GoogleFonts.aldrich(
          color: Color(0xFF2e282a),
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      );
      return DigitalClock(
          showSeconds: false,
          isLive: false,
          digitalClockTextColor: Colors.black,
          decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          datetime: DateTime.parse(remainTimeList[index]));
    } else if (re?["type"] == Range.BACKWARD) {
      // 后
      return Text(
        relativeEndSecondString,
        style: GoogleFonts.aldrich(
          color: Color(0xFF2e282a),
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      );
      return DigitalClock(
          showSeconds: false,
          isLive: false,
          digitalClockTextColor: Colors.black,
          decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          datetime: DateTime.parse(remainTimeList[index]));
    } else {
      // null
      return Text("null");
    }
  }
}
