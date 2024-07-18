/*
 * @Author: xskj
 * @Date: 2023-12-29 16:19:41
 * @LastEditors: xskj
 * @LastEditTime: 2023-12-30 14:29:53
 * @Description:add Task page页面信息共享状态  继承基类状态AppState
 */

import 'package:app_template/models/AppModel.dart';
import 'package:app_template/states/AppState.dart';

import '../manager/GlobalManager.dart';
import '../microService/taskSchedule/common/Task.dart';
import '../microService/taskSchedule/common/Todo.dart';

class TaskState extends AppState {
  // 切换icon模式
  bool _switchIconToggle = false;
  bool get switchIconToggle => _switchIconToggle;

  // 切换模式
  bool _switchToggle = true;
  bool get switchToggle => _switchToggle;

  TaskModel _tasks = TaskModel();
  TaskModel get tasks => _tasks;

  // 更改数据
  void updateTask(TaskModel task) {
    _tasks = tasks;
    notifyListeners();
  }

  // remove todo
  void removeTodo(Todo todo) {
    _tasks.todos?.remove(todo);
    notifyListeners();
  }

  // update todo
  void updateTodo(List<Todo> todos) {
    _tasks.todos = todos;
    notifyListeners();
  }

  // 模式开关切换
  void switchToggleMode() {
    _switchToggle = !_switchToggle;
    notifyListeners();
  }

  // 模式开关切换
  void switchIconToggleMode() {
    _switchIconToggle = !_switchIconToggle;
    notifyListeners();
  }
}
