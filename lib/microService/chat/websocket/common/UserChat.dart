/*
UserChat聊天用户类
 */

import 'package:app_template/database/LocalStorage.dart';
import 'package:drift/drift.dart';

import '../../../../database/daos/UserDao.dart';

class UserChat {
  // 添加聊天用户
  Future<bool> addUserChat(
      String deviceId, String profilePicture, String username) {
    // 实例化DAO
    UserDao userDao = UserDao();

    // 1.数据封装
    UsersCompanion usersCompanion = UsersCompanion.insert(
      deviceId: deviceId,
      username: username,
      status: const Value(1),
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      profilePicture: profilePicture,
      email: "",
      passwordHash: "",
    );

    // 2.写入数据库中并处理结果
    return userDao.insertUser(usersCompanion);
  }
}
