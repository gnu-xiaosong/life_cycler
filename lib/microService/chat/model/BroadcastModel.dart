/*
广播机制模块
 */
import 'dart:async';

import 'package:app_template/manager/GlobalManager.dart';

class BroadcastModel {
  /**************广播新增的deviceId**********************/
  void broadcastInlineUser(List deviceIdList) {
    // 广播
    GlobalManager.streamController.sink.add(deviceIdList);
  }
}
