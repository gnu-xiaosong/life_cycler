/*
 扫描类：主要扫码登录,聊天(加好友、加群) 等业务场景
 */
import 'dart:convert';
import 'package:app_template/config/AppConfig.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/chat/websocket/common/MessageEncrypte.dart';
import 'package:app_template/microService/chat/websocket/common/unique_device_id.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widget/ConstomAddDialog.dart';

class Scan with Console {
  // 扫码不同类型调用方法
  void scanHandlerByType(
      BuildContext context, MobileScannerController controller, Map qr_map) {
    if (qr_map["type"] == "ADD_USER") {
      // 关闭
      controller.stop();
      // 增加模态框
      showCustomDialog(
          context, qr_map["deviceId"], qr_map["username"], controller);
    }
  }

  // 扫描加好友
  Future<void> addChatUserByScan(Map qr_map) async {
    // 封装消息
    String send_deviceId = await UniqueDeviceId.getDeviceUuid();
    Map message = {
      "type": "REQUEST_SCAN_ADD_USER",
      "info": {
        // 发送方：扫码方
        "sender": {"id": send_deviceId, "username": qr_map["username"]},
        // 接收方: 等待接受
        "recipient": {"id": qr_map["deviceId"], "username": AppConfig.username},
        // 留言
        "content": qr_map["msg"] // 这个字段不是二维码扫描出的，而是用户自定义加上去的
      }
    };

    // 加密
    message["info"] = MessageEncrypte().encodeMessage(
        GlobalManager.appCache.getString("chat_secret").toString(),
        message["info"]);
    //发送消息
    try {
      print("message:$message");
      // 调用全局实例:发送
      GlobalManager()
          .GlobalChatWebsocket
          .chatWebsocketClient
          .send(json.encode(message));

      printInfo("REQUEST_SCAN_ADD_USER: send is successful!");
    } catch (e) {
      printCatch("REQUEST_SCAN_ADD_USER: send is failure! more detail: $e");
    }
  }
}
