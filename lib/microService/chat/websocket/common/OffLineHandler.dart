/*
  离线消息队列处理类
 */

import 'dart:convert';

import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/chat/websocket/common/MessageEncrypte.dart';
import 'package:app_template/microService/chat/websocket/common/tools.dart';
import 'package:app_template/microService/chat/websocket/model/ClientObject.dart';

class OffLine with Console {
  // 离线消息队列开关
  bool isOffLine = true;

  // 将消息进入离线消息队列中
  bool enOffLineQueue(String deviceId, String send_secret, Map message) {
    /*
    deviceId": deviceId,
      "secret": send_secret,  都是发送者
     */
    // 封装离线消息队列Map
    Map offMessage = {
      "deviceId": deviceId,
      "secret": send_secret,
      "msg_map": message
    };
    // 进入离线消息队列中
    try {
      GlobalManager.offLineMessageQueue.enqueue(offMessage);
      return true;
    } catch (e) {
      printCatch(" msg进入离线消息队列失败!, more detail: $e");
      return false;
    }
  }

  // 执行离线消息队列
  void offLineHandler() {
    int length = GlobalManager.offLineMessageQueue.length;

    while (length-- > 0) {
      // 获取当前出队列msg
      Map? msg = GlobalManager.offLineMessageQueue.dequeue();

      // **********切换secret进行文本的加密**********
      String deviceId = msg?["deviceId"]; // 仅仅离线模式才有该字段,发送者
      String secret = msg?["secret"]; // 仅仅离线模式才有该字段，发送者

      String de_str = MessageEncrypte()
          .decodeMessage(secret, msg!["msg_map"]["info"])
          .toString();
      Map de_str_map = json.decode(de_str);

      // 2.加密:
      /// (1) 获取目标(接收信息者)的deviceId
      String receive_deviceId = de_str_map["recipient"]["id"];

      /// (2) 根据device获取clientObject对象
      ClientObject? receive_clientObject =
          Tool().getClientObjectByDeviceId(receive_deviceId);

      if (receive_clientObject == null) {
        // 如果接受者仍然不在线则将该消息重新添加进队列中
        GlobalManager.offLineMessageQueue.enqueue(msg);
      } else {
        /// (3) 根据发送者的secret加密文本
        String reEncode_str = MessageEncrypte()
            .encodeMessage(receive_clientObject!.secret, de_str);

        // 利用接受者clientObject发送消息
        try {
          // 封装新信息
          Map new_msg = {"type": msg["msg_map"]["type"], "info": reEncode_str};
          receive_clientObject.socket.add(json.encode(new_msg));
        } catch (e) {
          printCatch("离线消息队列发送失败！失败device_id=$deviceId, more detail: $e");
        }
      }
    }
    if (length == 0) {
      printInfo(" 离线消息队列为空!");
    }
  }
}
