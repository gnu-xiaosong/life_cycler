/*
 websocket server端处理主线bus消息队列
 */

import 'package:app_template/manager/GlobalManager.dart';

import '../model/ClientObject.dart';
import 'Bus.dart';

class MessageQueueTask {
  // 私有构造函数
  MessageQueueTask._internal();

  // 静态私有变量，但不立即初始化
  static MessageQueueTask? _instance;

  // 工厂构造函数
  factory MessageQueueTask() {
    _instance ??= MessageQueueTask._internal();
    return _instance!;
  }

  // 执行一次webscoket serverbus消息队列任务调度一次
  void execOnceWebsocketServerMessageBusQueueScheduleTask() {
    // 单例模式: 实例化busSchedule
    BusSchedule busSchedule = BusSchedule();

    // 循环处理
    int clientCount = GlobalManager.webscoketClientObjectList.length;
    int index = 0;
    print("client count: $clientCount");
    while (index++ <= (clientCount - 1)) {
      // 获取clientObj
      ClientObject? clientObject = busSchedule.busSchedule();
      if (clientObject!.connected &&
          clientObject.status == 1 &&
          clientObject.messageQueue.length != 0) {
        // 发送send消息
        Map? message = clientObject.messageQueue.dequeue();
        clientObject.socket.add(message.toString());
        print("执行client 消息队列成功: ${clientObject.ip}:${clientObject.port}");
      } else {
        print(
            " 忽略该client: ${clientObject.ip}:${clientObject.port} connect=${clientObject.connected} status=${clientObject.status}");
      }
    }
    print("完成一次消息阵列调度");
  }
}
