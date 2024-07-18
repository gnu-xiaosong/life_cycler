/*
desc: 这是AddTaskpage页面对应的模型方法
 */

import 'dart:convert';
import 'dart:io';
import 'package:app_template/database/LocalStorage.dart' hide Task;
import 'package:app_template/database/daos/TaskDao.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/taskSchedule/module/Model.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:name_plus/name_plus.dart';
import '../common/Task.dart';

class AddTaskModel extends Model with Console {
  // todos: 事项数组
  List<Map> todos = [];

  // task数据库操作
  TaskDao taskDao = TaskDao();

  /*
  addDatabase: 添加task数据库
   */
  Future<void> insertDataToDatabase(TaskModel task) async {
    // 删掉相同的任务
    taskDao.deleteTask(task.taskId!);

    // 数据封装
    TasksCompanion tasksCompanion = TasksCompanion.insert(
        taskId: task.taskId!,
        name: task.name!,
        priority: task.priority,
        status: task.status,
        // 其他字段
        userId: Value(task.userId),
        label: Value(task.label),
        category: Value(task.category),
        description: Value(task.description),
        createAt: Value(DateTime.now()),
        updateAt: Value(DateTime.now()),
        startTime: Value(task.startTime),
        endTime: Value(task.endTime));
    // 插入数据库
    bool re = await taskDao.insertTask(tasksCompanion);
    if (!re) {
      print("插入数据失败!");
    } else {
      print("插入数据成功!");
    }
  }

  /*
   add: 增加todo
   需要参数:
   todo = {
     "name":"事项名",
     "description": "描述",
     "duration": "待办事项时长",  // 分钟整数 该优先级低于下面的严格执行时间点
     "startTime": "开始执行时间",  // 以毫秒整数进行存储
   	 "endTime": "结束时间",       // 以毫秒整数进行存储
   }
   */
  void addTodo(Map todo) {
    // 1、封装todoItem
    // Map todo = {
    // "todoID": "待办事项的唯一ID",
    //     	  "name":"事项名",
    //     	  "description": "描述",
    //   		  "createAt": "创建时间",
    //   		  "updateAt": "更新时间",
    //   		  "duration": "待办事项时长", // 该优先级低于下面的严格执行时间点
    //   		  "startTime": "开始执行时间",
    //   		  "endTime": "结束时间",
    //   		// 从开始之日起记录每日该todo的完成情况(只记录执行的，没执行的日期不记录)，按时间顺序依次往下
    //   		  "executiveLog":[]
    // };

    // 自动添加部分字段
    todo["executiveLog"] = [];
    todo["createAt"] =
        DateTime.now().microsecondsSinceEpoch.toString(); // 以毫秒整数进行存储
    todo["updateAt"] = DateTime.now().microsecondsSinceEpoch.toString();
    todo["todoID"] = "todo_${Uuid().v4()}";
    //.....其他带扩展字段

    // 2. append进入todos中
    todos.add(todo);
  }

  /*
   create: 创建新任务的method
   */
  Future<Map<String, Object>> createTask(
      {required taskID, required taskName}) async {
    // 1. 接收参数数据并统一封装
    List supportTypeForJson = [String, int, Null, List];
    Map taskDataMap = {
      "taskID": taskID,
      "taskName": taskName,
      // 其中data为数组形式，每个item为Map对象，对应该任务的每日待办事项
      "data": todos.map((e) {
        return e.map((key, value) {
          if (supportTypeForJson.contains(value.runtimeType)) {
            return MapEntry(key, value);
          }
          return MapEntry(key, value.toString());
        });
      }).toList()
    };

    // 2. 转化为Json字符串
    String taskJsonToString = json.encode(taskDataMap);

    // 3.在该目录下创建tasks目录用于存储对应的json文件: 采用name_plus库
    final taskFileInDir = (await super.getTaskFileInDir()).path;
    printInfo("外部存储目录: ${taskFileInDir.toString()}");
    // 创建包含新目录名的目录路径
    final newDirectoryPath = taskFileInDir + "/" + taskDirName;
    // (await Directory(taskFileInDir).namePlus(taskDirName)).path;
    print(newDirectoryPath);
    final newDirectory = Directory(newDirectoryPath.toString());
    // Directory('path').namePlusSync(taskDirName ); // 异步
    // 检查目录是否存在，如果不存在则创建
    if (!await newDirectory.exists()) {
      await newDirectory.create(recursive: false);
      print('目录创建成功: $newDirectoryPath');
    }

    // 3.1 获取存储的位置目录:继承Model属性
    String taskDir = newDirectoryPath.toString();

    /// 判断文件目录是否存在
    if (!Directory(taskDir).existsSync()) {
      printError('Directory does not exist');
      return {"result": false, "msg": '${taskDir}:Directory does not exist'};
    }

    // 4. 生成json文件名: 规则为{taskId}.json
    String fileName = "${taskID.toString()}.json";

    // 5. 拼接task文件路径
    String path = "${taskDir}/${fileName}";

    // 6. 判断该任务是否已经存在: 即判断该该文件在指定中是否存在
    if (File(path).existsSync()) {
      printError('${path}:File does exist');
      return {"result": false, "msg": '${path}:File does  exist!'};
    }

    // 8. false： 如果不能存在则调用文件写入操作，完成对数据的写入，并返回写入结果给用户
    try {
      // 写入文件
      final file = File(path);
      file.writeAsString(taskJsonToString);

      return {"result": true, "msg": "success"};
    } catch (e) {
      // 写入失败
      printError("ERR: ${e.toString()}");
      return {"result": false, "msg": "ERR: ${e.toString()}"};
    }
  }
}
