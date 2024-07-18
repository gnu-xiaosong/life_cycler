import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../module/WorkStationModel.dart';
import '../module/Model.dart';

class TodoItemBottom extends StatefulWidget {
  final Map data;
  final String taskId;
  TodoItemBottom(this.taskId, this.data, {super.key});

  @override
  State<TodoItemBottom> createState() => _TodoItemBottomState(taskId, data);
}

class _TodoItemBottomState extends State<TodoItemBottom> {
  bool switchmode = true;
  final Map data;
  final String taskId;
  WorkStationModel workStationModel = WorkStationModel();
  bool isDurationMode = true;
  _TodoItemBottomState(this.taskId, this.data);

  double fontSize = 20;

  @override
  void initState() {
    super.initState();
    // 判断是否为duration模式
    isDurationMode = workStationModel.isEmpty(data["duration"]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 获取todo的period时间段的widget
  Widget taskTodoPeroidTimer(Map re, bool isTodoRecorderExec) {
    Widget? todoWidget;

    print("********************+++++++++++RE++****************************");
    print("re=${re}");
    if (re["type"] == Range.FORWARD) {
      // 前: 还未到时间
      todoWidget = const Text("未到时间");
    } else if (re["type"] == Range.HANDLING) {
      // 中: 到时提示
      todoWidget =
          Text(workStationModel.secondFormateTime(re["relativeStartSecond"]));
    } else if (re["type"] == Range.BACKWARD && isTodoRecorderExec) {
      // 后: 已过时，已存在记录
      todoWidget = const Text("已结束");
    } else {
      // 其他: 其他类型
      todoWidget = const Text("程序出错！");
    }

    // // 记录todo task执行的秒数
    // GlobalManager.taskTodoSecond = re["relativeStartSecond"];
    // if (GlobalManager.taskTodoSecond == 0) {
    //   // 说明处于播放play状态
    //   todoWidget =
    //       Text(workStationModel.secondFormateTime(re["relativeStartSecond"]));
    // } else {
    //   // 存储暂停的second数
    //   int million = GlobalManager.taskTodoSecond;
    //   // 说明处于暂停pause状态
    //   todoWidget = Text(workStationModel.secondFormateTime(million));
    // }

    return todoWidget;
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;
    // 判断是否为duration模式
    isDurationMode = workStationModel.isEmpty(data["duration"]);

    // 计算获取时间差数据
    Map? re = workStationModel.nowDateIndateDurationPeriod(
        DateTime.parse(data["startTime"]), DateTime.parse(data["endTime"]));

    // 从文件中判断该todo是否完成
    bool isTodoRecorderExec =
        workStationModel.justifyTodoRecorderInExecutiveLog(
            executiveLogList: data["executiveLog"],
            taskId: taskId,
            todoId: data["todoID"]);

    // 自动完成todo的执行
    if (!isTodoRecorderExec) {
      // period模式
      if (re?["type"] == Range.BACKWARD) {
        // 后： 一次记录
        // 封装信息
        Map info = {};

        workStationModel.handlerTaskTodoPeriodTimer(taskId, data, info);
      }

      // duration模式
    }

    /*
     设置倒计时文本提示
     */
    content = Center(
        // 判断为period or duration
        child: isDurationMode
            ? taskTodoPeroidTimer(re!, isTodoRecorderExec)
            : taskTodoDurationTimer(re!));

    return Column(
      children: [
        // 正文
        content,
        // 底部button
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          buttonHeight: 52.0,
          buttonMinWidth: 90.0,
          children: <Widget>[
            isDurationMode
                ? TextButton(
                    // peroid执行
                    onPressed: () {
                      if (re["type"] == Range.FORWARD) {
                        // 前
                      } else if (re["type"] == Range.HANDLING) {
                        // 中
                        // 结束period todo任务
                        // 封装信息
                        Map info = {};
                        workStationModel.handlerTaskTodoPeriodTimer(
                            taskId, data, info);
                      } else if (re["type"] == Range.BACKWARD) {
                        // 后
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          re["type"] == Range.FORWARD
                              ? Icons.add_alert
                              : (re["type"] == Range.HANDLING
                                  ? Icons.stop_circle
                                  : Icons.add_box_rounded),
                          size: 50.0,
                          color: re["type"] == Range.FORWARD
                              ? Colors.lightBlueAccent
                              : (re["type"] == Range.HANDLING
                                  ? Colors.red
                                  : Colors.green),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text(
                          re["type"] == Range.FORWARD
                              ? "waiting".tr()
                              : (re["type"] == Range.HANDLING
                                  ? "underway".tr()
                                  : "end".tr()),
                          style: GoogleFonts.aldrich(
                            color: const Color(0xFF2e282a),
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : TextButton(
                    // duration执行模式
                    onPressed: () {
                      // 切换执行模式
                      setState(() {
                        switchmode = !switchmode;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          switchmode ? Icons.play_circle : Icons.pause_circle,
                          size: 50.0,
                          color: switchmode ? Colors.green : Colors.redAccent,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text(
                          switchmode ? 'start'.tr() : 'pause'.tr(),
                          style: GoogleFonts.aldrich(
                            color: const Color(0xFF2e282a),
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  /*
  todo timer的计时器显示
   */
  Widget taskTodoDurationTimer(Map re) {
    int duration = isDurationMode ? 0 : int.parse(data["duration"].toString());
    return SlideCountdownSeparated(
      icon: Icon(Icons.timer),
      duration: Duration(minutes: duration),
      onChanged: (duration) {
        print(
            "duration: ${duration.inDays}天:${duration.inHours}时:${duration.inMinutes}分:${duration.inMilliseconds}秒");
      },
    );
  }
}
