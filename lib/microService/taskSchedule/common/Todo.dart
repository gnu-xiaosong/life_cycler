import 'package:uuid/uuid.dart';

class Todo {
  String todoID = '';
  DateTime? createAt;
  DateTime? updateAt;
  String? name;
  String? description;
  String? duration;
  DateTime? startTime;
  DateTime? endTime;

  Todo() {
    todoID = "todo_" + Uuid().v1().toString();
    createAt = DateTime.now();
  }

  Map toMap() {
    Map todo = {
      "name": name,
      "description": description,
      "duration": duration, // 分钟整数 该优先级低于下面的严格执行时间点
      "startTime": startTime, // 以毫秒整数进行存储
      "endTime": endTime, // 以毫秒整数进行存储
    };
    return todo;
  }
}
