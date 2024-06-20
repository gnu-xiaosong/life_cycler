/*
 针对不同消息类型进行处理
 */
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/chat/websocket/common/tools.dart';
import 'package:app_template/microService/chat/websocket/model/MessageQueue.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'MessageEncrypte.dart';

class ClientMessageHandlerByType extends Tool with Console {
  MessageEncrypte messageEncrypte = MessageEncrypte();
  // 消息类型
  late Map msgDataTypeMap;

  // 消息处理函数
  void handler(WebSocketChannel? channel) {
    //***********************Message Type  Handler*******************************
    if (msgDataTypeMap["type"] == "SCAN") {
      // 解密info字段
      msgDataTypeMap["info"] =
          messageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      // 处理该类型的返回
      scan(channel);
    } else if (msgDataTypeMap["type"] == "AUTH") {
      // 解密info字段
      msgDataTypeMap["info"] =
          messageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      printInfo("解密结果:$msgDataTypeMap");

      // 客户端client 第一次请求认证服务端server
      auth(channel);
    } else if (msgDataTypeMap["type"] == "MESSAGE") {
      // 从缓存中取出secret 通讯秘钥
      String? secret = GlobalManager.appCache.getString("chat_secret");
      // 解密info字段
      msgDataTypeMap["info"] =
          messageEncrypte.decodeMessage(secret!, msgDataTypeMap["info"]);
      // 为消息类型
      message();
    } else if (msgDataTypeMap["type"] == "REQUEST_INLINE_CLIENT") {
      // 从缓存中取出secret 通讯秘钥
      String? secret = GlobalManager.appCache.getString("chat_secret");
      // 解密info字段
      msgDataTypeMap["info"] =
          messageEncrypte.decodeMessage(secret!, msgDataTypeMap["info"]);
      // 处理在线client
      requestInlineClient();
    } else if (msgDataTypeMap["type"] == "REQUEST_SCAN_ADD_USER") {
      // 通过扫码请求添加好友请求
      // 从缓存中取出secret 通讯秘钥
      String? secret = GlobalManager.appCache.getString("chat_secret");
      // 解密info字段
      msgDataTypeMap["info"] =
          messageEncrypte.decodeMessage(secret!, msgDataTypeMap["info"]);
      printInfo(msgDataTypeMap);
      // 处理在线client
      scanQrAddUser();
    } else {
      // 为表示消息类型: 明文传输
      printWarn("为标识消息类型");
      other();
    }
  }

  /*
  扫描Qr添加用户
   */
  void scanQrAddUser() {
    // 统一处理服务器相应的扫描Qr天假好友请求，两种方式
    /// 方式一 利用待同意好友消息队列（等待制) 推荐
    /// 方式二 全局弹窗相应通知用户(即刻制)
  }

  /*
   处理server在线client用户
   */
  void requestInlineClient() {
    // 1.获取deviceId 列表
    List<String> deviceIdList = msgDataTypeMap["info"]["deviceId"];
    // 2.将其存入缓存中
    GlobalManager.appCache.setStringList("deviceId_list", deviceIdList);
    // 3.创建为每个clientObject对象，采用list存储
    deviceIdList.map((deviceId) {
      // 为每个deviceId设置一个全局的消息队列
      GlobalManager.userMapMsgQueue[deviceId] = MessageQueue();
    });
    printInfo("userMapMsgQueue:$GlobalManager.userMapMsgQueue");
  }

  /*
    客户端请求局域网内服务端server的请求
   */
  void scan(WebSocketChannel? channel) {
    // 打印消息
    printInfo("--------------SCAN TASK HANDLER--------------------");
    printTable(msgDataTypeMap);
    try {
      if (int.parse(msgDataTypeMap["info"]["code"]) == 200) {
        // 扫描成功
        printSuccess("INFO: ${msgDataTypeMap["info"]["msg"]}");
      } else {
        // 扫描失败
        printFaile("FAILURE: ${msgDataTypeMap["info"]["msg"]}");
      }
    } catch (e) {
      // 非法字段
      printCatch(
          "ERR:the server is not authen! this conn will interrupt!more detail: ${e.toString()}");

      channel!.sink.close(status.goingAway);
    }

    //************************其他处理: 记录日志等******************************
  }

  /*
    客户端client 第一次请求认证服务端server
   */
  void auth(WebSocketChannel? channel) {
    // 打印消息
    printInfo("--------------AUTH TASK HANDLER--------------------");
    printInfo(">> receive: $msgDataTypeMap");

    try {
      if (int.parse(msgDataTypeMap["info"]["code"]) == 200) {
        // 认证成功
        printSuccess("+INFO: ${msgDataTypeMap["info"]["msg"]}");
        // 存储通讯秘钥secret
        String secret = msgDataTypeMap["info"]["secret"].toString();
        GlobalManager.appCache.setString("chat_secret", secret);
      } else {
        // 扫描失败
        printFaile("-FAILURE: ${msgDataTypeMap["info"]["msg"]}");
      }
    } catch (e) {
      // 非法字段
      printCatch(
          "-ERR: ${e.toString()} server is not authed! this conn will interrupt!");
      channel!.sink.close(status.goingAway);
    }
    //************************其他处理: 记录日志等******************************
  }

  /*
    消息类型
   */
  void message() {
    printInfo("--------------MESSAGE TASK HANDLER--------------------");
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
