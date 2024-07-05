/*
这是基本模型，其余模型都继承该类
 */

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Model {
  // 创建task文件的指定目录
  // 获取应用数据存储目录路径
  Future<Directory> getTaskFileInDir() async {
    // 请求外部存储权限
    if (await Permission.storage.request().isGranted) {
      // 获取应用文档目录
      return await getApplicationDocumentsDirectory();
    } else {
      // 用户拒绝了权限请求
      throw Exception('用户拒绝了外部存储权限请求');
    }
    // return await getApplicationDocumentsDirectory();
  }
}
