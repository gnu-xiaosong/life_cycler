/*
工具函数
 */

import 'dart:convert';
import 'dart:io';

import 'package:app_template/config/AppConfig.dart';
import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/database/daos/ChatDao.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/chat/websocket/common/unique_device_id.dart';
import 'package:crypto/crypto.dart';

import '../model/ClientObject.dart';

class Tool with Console {
  Map? stringToMap(String data) {
    // print("------json decode for string to map--------");
    // print("待转string: $data");
    try {
      // 检查输入字符串是否是有效的JSON格式
      if (data != null && data.isNotEmpty) {
        // 使用json.decode将JSON字符串解析为Map
        Map re = json.decode(data);
        // print("转换map: $re");
        return re;
      } else {
        printFaile("Input data is empty or null");
      }
    } catch (e) {
      // 处理解析错误，输出错误信息并返回一个空的Map
      printError('Error parsing JSON: $e');
      return {};
    }
  }

  //auth认证加密算法认证:md5算法
  String generateMd5Secret(String data) {
    var bytes = utf8.encode(data); // data being hashed
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  // 根据deviceId设备ID获取对应于的clientObject对象
  ClientObject? getClientObjectByDeviceId(String deviceId) {
    // 遍历list
    for (ClientObject clientObject in GlobalManager.webscoketClientObjectList) {
      if (clientObject.deviceId == deviceId) return clientObject;
    }
    return null;
  }

  /*
  客户端client通信秘钥认证
   */
  bool clientAuth(String deviceId, HttpRequest request, WebSocket webSocket) {
    // deviceId和ip+port验证
    ClientObject? clientObject = getClientObjectByDeviceId(deviceId);
    if (request.connectionInfo?.remoteAddress.address.toString() ==
            clientObject?.ip &&
        request.connectionInfo?.remotePort.toInt() == clientObject?.port) {
      return true;
    }
    return false;
  }

  /*
  获取server在线用户:返回inline client deviceId list
   */
  List<String> getInlineClient(String deviceId) {
    /// 不包括本身
    List<String> deviceList = GlobalManager.webscoketClientObjectList
        .where((clientObject) {
          if (clientObject.deviceId != deviceId && clientObject.connected) {
            return true;
          }
          return false;
        })
        .map((clientObject) => clientObject.deviceId)
        .toList();

    return deviceList;
  }

  /*
  生成加好友二维码的存储信息
   */
  Future<Map> generateAddUserQrInfo() async {
    // 设备唯一性id
    String deviceId = await UniqueDeviceId.getDeviceUuid();
    // 用户名
    String username = AppConfig.username;
    // 封装
    Map re = {"type": "ADD_USER", "deviceId": deviceId, "username": username};

    return re;
  }

  ClientObject getClientObject(HttpRequest request, WebSocket webSocket) {
    late ClientObject clientObject;
    for (ClientObject clientObject_item
        in GlobalManager.webscoketClientObjectList) {
      // 根据ip地址匹配查找
      if (clientObject_item.ip ==
              request.connectionInfo?.remoteAddress.address ||
          clientObject_item.socket == webSocket) {
        // 匹配成功
        clientObject = clientObject_item;
      }
    }

    return clientObject;
  }
}
