/*
desc: TaskDao类DAO操作: DAO类集中管理 CRUD 操作
*/
import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/database/daos/BaseDao.dart';
import 'package:drift/drift.dart';
import '../../manager/GlobalManager.dart';
import '../../microService/chat/websocket/common/Console.dart';
import '../../microService/taskSchedule/common/Task.dart' as TASK;

class TaskDao extends BaseDao with Console {
  // 获取database单例
  LocalDatabase db = GlobalManager.database;

// 根据taskId查询
  Future<Task?> selectTaskByTaskName(String taskName) async {
    // 构建查询
    final query = db.select(db.tasks)
      ..where((tbl) => tbl.name.equals(taskName));
    // 获取查询结果
    final result = await query.getSingleOrNull();
    if (result == null) {
      return null;
    }
    return result;
  }

  // 根据taskId查询
  Future<Task?> selectTaskByTaskId(String taskId) async {
    // 构建查询
    final query = db.select(db.tasks)
      ..where((tbl) => tbl.taskId.equals(taskId));
    // 获取查询结果
    final result = await query.getSingleOrNull();
    if (result == null) {
      return null;
    }
    return result;
  }

  // 获取所有task
  Future<List<Task>> selectAllTasks() async {
    // 构建查询
    List<Task> query = await (db.select(db.tasks)).get();

    // 将查询结果转换为 User 的列表
    return query;
  }

  // 获取用户，分页查询，按时间查询
  Future<List> selectTaskByPage(int page, int pageNum) {
    /*
      page: 页面 1,2.。。。
      pageNum: 每页数量
     */
    final offset = (page - 1) * pageNum;
    // 构建查询
    final query = (db.select(db.tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createAt, mode: OrderingMode.desc)
          ])
          ..limit(pageNum, offset: offset))
        .get();

    // 将查询结果转换为 User 的列表
    return query;
  }

  // 插入数据
  Future<bool> insertTask(TasksCompanion tasksCompanion) async {
    try {
      await db.into(db.tasks).insert(tasksCompanion);
      return true; // 插入成功，返回 true
    } catch (e, stacktrace) {
      printCatch("task插入失败: $e");
      printCatch("Stacktrace: $stacktrace");
      return false;
    }
  }

  // 更新数据
  updateTask(TasksCompanion tasksCompanion) async {
    int result = 0;
    await db.update(db.tasks)
      ..where((tbl) => tbl.id.equals(tasksCompanion.id as int))
      ..write(tasksCompanion).then((value) {
        print("update result: $value");
        result = value;
      });

    return result;
  }

  // 删除数据
  int deleteTask(String taskId) {
    // 删除条数
    int result = 0;
    db.delete(db.tasks)
      ..where((tbl) => tbl.taskId.equals(taskId))
      ..go().then((value) {
        print("delete data count: $value");
        result = value;
      });

    return result;
  }
}
