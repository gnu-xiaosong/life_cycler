/*
  user 级别任务调度
 */

import '../../../../manager/GlobalManager.dart';
import '../model/ClientObject.dart';

class UserSchedule {
  // 单例实例
  static UserSchedule? _instance;

  // 索引index，用于获取用户client
  static int index = 0;

  // 私有构造函数
  UserSchedule._();

  // 存储 WebsocketClientObject 对象的数组
  List<ClientObject> clientObjectList = GlobalManager.webscoketClientObjectList;

  // 获取单例实例
  static UserSchedule getInstance() {
    _instance ??= UserSchedule._();
    return _instance!;
  }

  /*
   * 获取下一个 WebsocketClientObject
   */
  ClientObject? getNextClientObject() {
    // 获取横向客户端index:选取策略
    if (clientObjectList.isEmpty) {
      print("无在线client");
      return null;
    }

    // 获取对象client
    ClientObject clientObject = clientObjectList[index];
    // 执行调度策略
    clientScheduleStrategyByOrder();
    // 假设获取第一个元素作为下一个对象
    if (messageQueueIsNull(clientObject)) return null;

    return clientObject;
  }

  // 调度user client的策略1: 逐步自增
  void clientScheduleStrategyByOrder() {
    if (index++ == (clientObjectList.length - 1)) index = 0;
  }

  // 判断空队列消息检测
  bool messageQueueIsNull(ClientObject clientObject) {
    if (clientObject.messageQueue.length == 0) return true;
    return false;
  }
}
