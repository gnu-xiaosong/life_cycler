/*
desc: UserDao类DAO操作: DAO类集中管理 CRUD 操作
*/
import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/database/daos/BaseDao.dart';
import 'package:drift/drift.dart';
import '../../manager/GlobalManager.dart';

class ChatDao implements BaseDao<Chat> {
  // 查询数据
  Future<List> selectChat(ChatsCompanion chatsCompanion) async {
    // 获取database单例
    var db = GlobalManager.database;

    // 构建查询
    final query = db.select(db.chats)
      ..where((tbl) => tbl.id.equals(chatsCompanion.id.value));
    // 获取查询结果
    final result = await query.get();

    // 将查询结果转换为 UserData 的列表
    return result.toList();
  }

  // 插入数据
  Future<dynamic> insertChat(ChatsCompanion chatsCompanion) async {
    // 获取database单例
    var db = GlobalManager.database;

    // 构建
    final result = await db.into(db.chats).insert(chatsCompanion);

    return result;
  }

  // 更新数据
  Future<int> updateChat(ChatsCompanion chatsCompanion) async {
    // 获取database单例
    var db = GlobalManager.database;
    int result = 0;
    await db.update(db.chats)
      ..where((tbl) => tbl.id.equals(chatsCompanion.id.value))
      ..write(chatsCompanion).then((value) {
        print("update result: $value");
        result = value;
      });

    return result;
  }

  // 删除数据
  int deleteChat(ChatsCompanion chatsCompanion) {
    // 获取database单例
    var db = GlobalManager.database;
    // 删除条数
    int result = 0;
    db.delete(db.users)
      ..where((tbl) => tbl.id.equals(chatsCompanion.id as int))
      ..go().then((value) {
        print("delete data count: $value");
        result = value;
      });

    return result;
  }
}
