/*
 针对不同消息类型进行处理
 */
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/websocket/common/tools.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'MessageEncrypte.dart';

class ClientMessageHandlerByType {
  // 消息类型
  late Map msgDataTypeMap;

  // 消息处理函数
  void handler(WebSocketChannel? channel) {
    //***********************Message Type  Handler*******************************
    if (msgDataTypeMap["type"] == "SCAN") {
      // 解密info字段
      msgDataTypeMap["info"] =
          MessageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      // 处理该类型的返回
      scan(channel);
    } else if (msgDataTypeMap["type"] == "AUTH") {
      // 解密info字段
      msgDataTypeMap["info"] =
          MessageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      print("解密结果:$msgDataTypeMap");

      // 客户端client 第一次请求认证服务端server
      auth(channel);
    } else if (msgDataTypeMap["type"] == "MESSAGE") {
      // 从缓存中取出secret 通讯秘钥
      String? secret = GlobalManager.appCache.getString("chat_secret");
      // 解密info字段
      msgDataTypeMap["info"] = MessageEncrypte.decodeMessage(
          secret!, msgDataTypeMap["info"].toString());
      // 为消息类型
      message();
    } else {
      // 为表示消息类型: 明文传输
      print("为标识消息类型");
      other();
    }
  }

  /*
    客户端请求局域网内服务端server的请求
   */
  void scan(WebSocketChannel? channel) {
    // 打印消息
    print("--------------SCAN TASK RESULT--------------------");
    print(msgDataTypeMap.toString());
    try {
      if (int.parse(msgDataTypeMap["info"]["code"]) == 200) {
        // 扫描成功
        print("INFO: ${msgDataTypeMap["info"]["msg"]}");
      } else {
        // 扫描失败
        print("FAILURE: ${msgDataTypeMap["info"]["msg"]}");
      }
    } catch (e) {
      print("ERR:${e.toString()}");
      // 非法字段
      print("the server is not authen! this conn will interrupt!");
      channel!.sink.close(status.goingAway);
    }

    //************************其他处理: 记录日志等******************************
  }

  /*
    客户端client 第一次请求认证服务端server
   */
  void auth(WebSocketChannel? channel) {
    // 打印消息
    print("--------------AUTH TASK RESULT--------------------");
    print(msgDataTypeMap.toString());
    try {
      if (int.parse(msgDataTypeMap["info"]["code"]) == 200) {
        // 认证成功
        print("INFO: ${msgDataTypeMap["info"]["msg"]}");
        // 存储通讯秘钥secret
        String secret = msgDataTypeMap["info"]["secret"].toString();
        GlobalManager.appCache.setString("chat_secret", secret);
      } else {
        // 扫描失败
        print("FAILURE: ${msgDataTypeMap["info"]["msg"]}");
      }
    } catch (e) {
      print("ERR:${e.toString()}");
      // 非法字段
      print("the server is not authed! this conn will interrupt!");
      channel!.sink.close(status.goingAway);
    }

    //************************其他处理: 记录日志等******************************
  }

  /*
    消息类型
   */
  void message() {
    // 调用消息处理函数
    handlerMessgae(msgDataTypeMap);
    //***********************Message Type  Handler*******************************
  }

  /*
 其他未标识消息类型
  */
  void other() {
    // 其他消息类型：明文传输
  }
}
