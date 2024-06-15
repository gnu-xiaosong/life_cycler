/*
desc: UserDao类DAO操作: DAO类集中管理 CRUD 操作
*/
import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/database/daos/BaseDao.dart';
import 'package:drift/drift.dart';
import '../../manager/GlobalManager.dart';

class UserDao implements BaseDao<User> {
  // 获取database单例
  static LocalDatabase db = GlobalManager.database;

  // 获取用户，分页查询，按时间查询
  static Future<List> selectUserByPage(int page, int pageNum) {
    /*
      page: 页面 1,2.。。。
      pageNum: 每页数量
     */
    final offset = (page - 1) * pageNum;
    // 构建查询
    final query = (db.select(db.users)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(pageNum, offset: offset))
        .get();

    // 将查询结果转换为 User 的列表
    return query;
  }

  // 插入数据
  static insertUser(UsersCompanion usersCompanion) async {
    // 构建
    final result = await db.batch((batch) {
      batch.insertAll(db.users, [usersCompanion]);
    });

    return result;
  }

  // 更新数据
  static updateUser(UsersCompanion usersCompanion) async {
    int result = 0;
    await db.update(db.users)
      ..where((tbl) => tbl.id.equals(usersCompanion.id as int))
      ..write(usersCompanion).then((value) {
        print("update result: $value");
        result = value;
      });

    return result;
  }

  // 删除数据
  static int deleteUser(UsersCompanion usersCompanion) {
    // 删除条数
    int result = 0;
    db.delete(db.users)
      ..where((tbl) => tbl.id.equals(usersCompanion.id as int))
      ..go().then((value) {
        print("delete data count: $value");
        result = value;
      });

    return result;
  }
}
