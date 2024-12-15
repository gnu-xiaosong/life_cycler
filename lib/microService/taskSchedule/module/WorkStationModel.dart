/*
WorkStation 页面逻辑模块
 */
import 'dart:convert';
import 'dart:io';
import 'package:app_template/database/daos/TaskDao.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/taskSchedule/module/TimeModel.dart';
import 'package:jiffy/jiffy.dart';
import '../../../database/LocalStorage.dart';

class WorkStationModel extends TimeModel with Console {
  TaskDao taskDao = TaskDao();

  /*
  根据taskId获取对应文件json内容
   */
  Future<Map> getFileTaskContentByTaskId(String taskId) async {
    // 组织文件名
    String fileName = taskId + ".json";

    // 组织文件完整路径
    String path =
        (await getTaskFileInDir()).path + "/" + taskDirName + "/" + fileName;

    // 获取文件内容
    final file = File(path);
    if (!await file.exists()) {
      print('${path}文件不存在');
      return {};
    }
    final contents = await file.readAsString();

    // 解析JSON数据
    Map<String, dynamic> jsonData = jsonDecode(contents);

    return jsonData;
  }

  /*
  设置时间
   */
  String setDateTimeFormate(DateTime time1) {
    var jiffy = Jiffy.parseFromDateTime(time1);

    return jiffy.yMMMMEEEEdjm.toString();
  }

  /*
  获取数据库中的有效的task任务数据
   */
  Future<List<Task>> getAllTask() async {
    // 存储数据
    List<Task> taskList = [];

    // 查询所有task
    List<Task> allTask = await taskDao.selectAllTasks();
    print("数据库中所有task: ${allTask}");
    // 筛选符合的数据
    for (Task task in allTask) {
      // 筛选存在本地文件的task
      final taskFileInDir = (await getTaskFileInDir()).path;
      // 创建包含新目录名的目录路径
      final newDirectoryPath = taskFileInDir + "/" + taskDirName;
      // (await Directory(taskFileInDir).namePlus(super.taskDirName));
      final taskPath = newDirectoryPath + "/" + "${task.taskId}.json";
      // (await File(newDirectoryPath).namePlus("task_${task.taskId}.json"))
      //     .path;

      /// 判断文件是否存在
      if (await File(taskPath).exists()) {
        // 存在文件
        taskList.add(task);
      }
    }

    return taskList;
  }

  /*
  获取数据库中的有效的且在有效期内的task任务数据
   */
  Future<List<Task>> getAllTaskInExpirationDate() async {
    List<Task> taskList = await getAllTask();
    print("存在json文件的Task: ${taskList}");
    List<Task> taskListFilter = filterTaskNowDateInExpirationDate(taskList);
    print("在有效期内: ${taskListFilter}");
    return taskListFilter;
  }

  /*
  根据给定的task列表中的时间范围筛选符合的task：task是否在有效期内
   */
  List<Task> filterTaskNowDateInExpirationDate(List<Task> taskList) {
    List<Task> filterTaskList = [];

    for (var task in taskList) {
      // 日期转化
      DateTime? start = task.startTime ?? DateTime.now();
      // DateTime.fromMicrosecondsSinceEpoch(int.parse(task.startTime));
      DateTime? end = task.endTime ?? DateTime.now();
      // DateTime.fromMicrosecondsSinceEpoch(int.parse(task.endTime));
      // 调用方法
      if (nowDateIndateDuration(start, end)) {
        filterTaskList.add(task);
      }
    }
    return filterTaskList;
  }

  /*
  执行事项时间间隔程序:duration设定时
   */
  void handlerTaskTodoDurationTimer() {}

  /*
  执行事项设定时间段程序:当设定为startTime - sendTime时
   */
  Future<void> handlerTaskTodoPeriodTimer(
      String taskId, Map data, Map info) async {
    // 相对应信息
    print("TASK todo information: ${data}");
    // 判断该todo在今日记录中是否存在
    bool isTodoRecorderExec = justifyTodoRecorderInExecutiveLog(
        taskId: taskId,
        todoId: data["todoID"],
        executiveLogList: data["executiveLog"]);
    if (isTodoRecorderExec) return;

    // 封装信息
    Map re = {
      "time": DateTime.now().toString(), // 只需记录到年月日即可
      "duration": 0, // 分钟整数: 时间段
      "startTime": data["startTime"], // 以毫秒整数进行存储
      "endTime": DateTime.now().toString(), // 以毫秒整数进行存储
      "status": info[
          "status"], // 完成情况: giveUp(主动放弃) completed(完成) interrupt(中断，指任务已进行但为100%完成只是完成部分)
      "tip": info["tip"], // 用户标记: 主要给用户提供比如情绪等标记
      "notes": info["notes"] // 用户记录：猪腰提供给用户在完成该任务或其他情况需要用户自定义该日todo事项的说明与记录
    };
    // 读取对应taskId的文件信息然后添加item进入数组中
    // 组织文件完整路径
    String fileName = "${taskId}.json";
    String path =
        (await getTaskFileInDir()).path + "/" + taskDirName + "/" + fileName;
    // 获取文件内容
    final file = File(path);
    if (!await file.exists()) {
      print('${path}文件不存在');
      return;
    }
    final contents = await file.readAsString();
    // 解析JSON数据
    Map<String, dynamic> jsonData = jsonDecode(contents);

    print("获取json文本数据: ${jsonData}");
    // 根据todoId找出对应的事项的item序号进行修改
    for (int i = 0; i < jsonData["data"].length; i++) {
      Map todoItem = jsonData["data"][i];
      if (todoItem["todoID"] == data["todoID"]) {
        // 添加item
        todoItem["executiveLog"].add(re);
        jsonData["data"][i] = todoItem;
        break;
      }
    }

    // 保存文件
    try {
      String taskJsonToString = json.encode(jsonData);
      // 写入文件
      final file = File(path);
      file.writeAsString(taskJsonToString);
      print("写入成功");
    } catch (e) {
      // 写入失败
      printError("ERR: ${e.toString()}");
    }
    print("更改后的json文本数据: ${jsonData}");
  }

  /*
  根据taskId、todoID和日期判断executiveLog中是否存在记录
   */
  bool justifyTodoRecorderInExecutiveLog(
      {required String? taskId,
      required String? todoId,
      required List executiveLogList}) {
    // 获取今日日期
    DateTime nowTime = DateTime.now();

    printSuccess("---------------判断是否存在记录--------------");
    // 遍历
    for (Map item in executiveLogList) {
      // 日期记录
      DateTime recorderTime = DateTime.parse(item["time"]);
      printError("现在时间: ${nowTime.year}-${nowTime.month}-${nowTime.day}");
      printError(
          "记录时间: ${recorderTime.year}-${recorderTime.month}-${recorderTime.day}");
      // 判断日期
      if (nowTime.year == recorderTime.year &&
          nowTime.month == recorderTime.month &&
          nowTime.day == recorderTime.day) {
        // 符合
        // print(true);
        exit(0);
        return true;
      }
    }

    return false;
  }
}
