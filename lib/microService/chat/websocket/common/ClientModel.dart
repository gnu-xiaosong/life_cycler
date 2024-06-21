/*
client客户端功能模块
 */
import '../../../../Layouts/adaptive/AdaptiveLayout.dart';
import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../manager/GlobalManager.dart';

class ClientModel extends AdaptiveLayoutState with Console {
  /*
  好友请求处理方法一: 弹窗提示
  scan Qr instance dialog to show
   */
  addUserMsgQueue(Map data) {
    try {
      GlobalManager.clientWaitUserAgreeQueue.enqueue(data);
    } catch (e) {
      printCatch("ERROR: the wait user agree process som error in enqueue!");
    }
  }

  test() {
    Map? single = GlobalManager.clientWaitUserAgreeQueue.dequeue();
    singleAgreeUserHandler(single);
  }

  /*
  处理等待好友同意消息队列: 单条消息信息处理
  mag 铭文未加密
      {
     "type": "REQUEST_SCAN_ADD_USER",
     "info": {
         // 发送方：扫码方
         "sender": {"id": send_deviceId, "username": qr_map["username"]},
         // 接收方: 等待接受
         "recipient": {"id": qr_map["deviceId"], "username": AppConfig.username},
         // 留言
         "content": qr_map["msg"] // 这个字段不是二维码扫描出的，而是用户自定义加上去的
     }
 }
   */
  singleAgreeUserHandler(msg) {
    // 消息拆分
    print(
        "******************************我正在使用context*******************************************");
    // 弹窗显示
    return QuickAlert.show(
      context: GlobalManager.context,
      title: "add user request".tr(),
      type: QuickAlertType.confirm,
      text: 'from'.tr() +
          " " +
          "ID".tr() +
          ": " +
          msg["info"]["sender"]["id"] +
          "\n " +
          "username".tr() +
          ": " +
          msg["info"]["username"],
      confirmBtnText: 'Agree'.tr(),
      cancelBtnText: 'Cancel'.tr(),
      confirmBtnColor: Colors.green,
    );
  }
}
