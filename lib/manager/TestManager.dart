/*
 * @Author: xskj
 * @Date: 2023-12-29 13:25:12
 * @LastEditors: xskj
 * @LastEditTime: 2023-12-29 13:40:14
 * @Description: 测试工具类
 */
import 'dart:io';

import 'package:app_template/database/LocalStorage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../database/daos/UserDao.dart';
import '../microService/chat/websocket/common/UserChat.dart';

class TestManager {
  // 公共调试函数
  static void debug() {
    print("------------------debug task test-----------");
    // 调试ADO
    // testADO();
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
    try {
      UserChat userChat = UserChat();

      Map re = {
        "deviceId": "deviceId2",
        "username": "username3",
        "profilePicture": "profilePicture"
      };
      print(re);
      bool result = await userChat.addUserChat(
          re["deviceId"], re["profilePicture"], re["username"]);
      if (result) {
        print("---------------测试插入okkkkkkk---------------------------");
      } else {
        print("----------------测试插入失敗--------------");
      }
    } catch (e) {
      print("-EXCEPT: $e");
    }
  }
}
