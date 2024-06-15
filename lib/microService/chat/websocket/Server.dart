import 'dart:io';
import 'package:app_template/microService/chat/websocket/schedule/MessageQueueTask.dart';
import '../../../common/WebsocketServer.dart';
import '../../../manager/GlobalManager.dart';
import 'common/ServerMessageHandlerByType.dart';
import 'common/tools.dart';

class ChatWebsocketServer extends WebSocketServer {
  // 实例化消息处理类
  ServerMessageHandlerByType messageHandlerByType =
      ServerMessageHandlerByType();

  /*
   计算与该服务端连接的clientd的数量
   */
  Map getClientsCount() {
    // 与server连接成功的client数量
    int ClientCount = super.clients.length;

    // 连接成功并且经过认证为client客户端
    int chatClientCount = GlobalManager.webscoketClientObjectList.length;

    // 封装
    Map result = {"Client": ClientCount, "chatClientCount": chatClientCount};
    return result;
  }

  /*
    封装客户端连接对象: ChatClient 将其存储
    paremater:
   */

  /*
  处理客户端断开连接
   */
  @override
  void interruptHandler(WebSocket webSocket) {
    // 更改全局list中websocketclientObj的状态
    GlobalManager.webscoketClientObjectList.map((websocketClientObj) {
      if (websocketClientObj.socket == webSocket) {
        print("----------------中断处理：找到了目标websocket------------------------");
        // 更改连接状态: 0 断开
        websocketClientObj.connected = false;
        // 返回
        return websocketClientObj;
      } else {
        // 返回原来的
        return websocketClientObj;
      }
    });
    // TODO: implement interruptHandler
    super.interruptHandler(webSocket);
  }

  /*
    处理接受到的消息
   */
  @override
  void messageHandler(
      HttpRequest request, WebSocket webSocket, dynamic message) {
    // 将string重构为Map
    Map msgDataTypeMap = stringToMap(message.toString());

    messageHandlerByType.msgDataTypeMap = msgDataTypeMap;
    // 调用消息处理函数
    messageHandlerByType.handler(request, webSocket);

    // *****************被动调用bus Queue总消息队列任务************************
    MessageQueueTask messageQueueTask = MessageQueueTask();
    messageQueueTask.execOnceWebsocketServerMessageBusQueueScheduleTask();

    super.messageHandler(request, webSocket, message);
  }
}
