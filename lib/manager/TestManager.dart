/*
 * @Author: xskj
 * @Date: 2023-12-29 13:25:12
 * @LastEditors: xskj
 * @LastEditTime: 2023-12-29 13:40:14
 * @Description: 测试工具类
 */
import 'package:app_template/database/LocalStorage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../database/daos/UserDao.dart';

class TestManager {
  // 公共调试函数
  static void debug() {
    // 调试ADO
    testADO();
  }

  //http返回数据打印输出
  static void textPrint(Response response) {
    print("----------------------测试调试-----------------");
    print("请求状态: ${response?.statusCode}");
    print("请求头: ${response?.headers}");
    print("请求参数: ${response?.requestOptions.toString()}");
    print("返回数据: ${response?.data}");
  }

  // sqlite数据库调试
  static Future<void> testADO() async {
    print("---------------数据库ADO测试-----------");
    // userCompanion 辅助器
    UsersCompanion usersCompanion = UsersCompanion.insert(
        username: "小S",
        email: "13145002201@qq.com",
        passwordHash: "cgsucgvsdhsdhfjsdbfjdsf");

    print(usersCompanion.toString());
    print("----------------插入操作------------");
    // 插入数据
    var result = UserDao.insertUser(usersCompanion);
    print("插入操作: $result");
    // 查询操作测试
    final queryData = await UserDao.selectUserByPage(1, 10);
    print("----------------查询操作------------");
    for (var element in queryData) {
      if (kDebugMode) {
        print(element);
      }
    }
    print("---------------test 查询操作---------------");
    print(queryData);
  }
}
