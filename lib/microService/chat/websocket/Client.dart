import 'dart:convert';

import 'package:app_template/common/WebsocketClient.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'common/ClientMessageHandlerByType.dart';
import 'common/Console.dart';
import 'common/MessageEncrypte.dart';
import 'common/UserChat.dart';
import 'common/tools.dart';
import 'common/unique_device_id.dart';

class ChatWebsocketClient extends WebsocketClient with Console {
  Tool tool = Tool();
  ClientMessageHandlerByType clientMessageHandlerByType =
      ClientMessageHandlerByType();
  MessageEncrypte messageEncrypte = MessageEncrypte();
  UserChat userChat = UserChat();
  /*
  client与server连接成功时
   */
  @override
  Future<void> conn_success(WebSocketChannel? channel) async {
    String plait_text = "I am websocket client that want to authenticate";
    String key = "sjkvsbkjdvbsdjvhbsjhvbdsjhvbsdjhvbsdjhvbsdvjs";
    // 设备唯一标识:为了防止安全可以在之前进行安全性检查
    String deviceId = await UniqueDeviceId.getDeviceUuid();
    // 发起身份认证
    Map auth_req = {
      "type": "AUTH",
      "deviceId": deviceId,
      "info": {
        "plait_text": plait_text,
        "key": key,
        "encrypte": tool.generateMd5Secret(key + plait_text)
      }
    };
    // print("-------------------auth encode---------------");
    // 消息加密:采用AUTH级别
    auth_req["info"] = messageEncrypte.encodeAuth(auth_req["info"]);

    // 发送
    try {
      printInfo(">> send: $auth_req");
      channel?.sink.add(json.encode(auth_req));
    } catch (e) {
      printError("-ERR:发送AUTH认证失败!请重新发起认证，连接将中断!");
      channel!.sink.close(status.goingAway);
    }
    // 调用
    // super.conn_success(channel);
  }

  /*
  监听消息处理程序
   */
  @override
  void listenMessageHandler(message) {
    printInfo("------------Listen Client Msg Task--------------------");

    // 将string重构为Map
    Map? msgDataTypeMap = tool.stringToMap(message.toString());
    printInfo(">> receive: $msgDataTypeMap");
    // 传递消息
    clientMessageHandlerByType.msgDataTypeMap = msgDataTypeMap!;
    // 根据不同消息类型处理程序
    clientMessageHandlerByType.handler(channel);
    // 调用
    // super.listenMessageHandler(message);
  }

  /*
  连接中断时
   */
  @override
  void interruptHandler(WebSocketChannel channel) {
    printInfo("+INFO:The client connect is interrupted!");
    // 调用
    // super.interruptHandler(channel);
  }

  /*
  发送获取在线用户deviceId的请求
   */
  void sendRequestInlineClient() {
    Map req = {
      "type": "REQUEST_INLINE_CLIENT",
      "info": {
        "deviceId": UniqueDeviceId.getDeviceUuid(), //请求客户端的设备唯一性id
      }
    };
    // 从缓存中加载秘钥
    String secret = GlobalManager.appCache.getString("chat_secret") ?? "";
    // 加密
    req["info"] =
        MessageEncrypte().encodeMessage(secret, req as Map<String, dynamic>);
    // 发送
    send(json.encode(req));
  }

  /*
  send方法:该方法负责客户端的chat消息发送函数
   */
  bool sendMessage(
      {Map recipient = const {"id": "all", "type": "group"},
      Map sender = const {"username": "发送者用户名", "avatar": "发送者头像（可选）"},
      Map content = const {"text": "Hello, World!", "attachments": []},
      String time = ""}) {
    Map msg = {
      "type": "MESSAGE",
      "info": {
        "sender": {
          "id": UniqueDeviceId.getDeviceUuid(),
          "username": sender["username"],
          "avatar": sender["avatar"],
        },
        "recipient": {
          "id": recipient["id"],
          "type": recipient["type"],
        },
        "content": content,
        "timestamp": time ?? DateTime.now().toString(),
        "metadata": {
          "messageId": Uuid().v1(),
          "status": "sent",
        },
      },
    };

    String secret = GlobalManager.appCache.getString("chat_secret") ?? "";
    if (secret.isEmpty) {
      print("-warning: 通讯秘钥 'chat_secret' 为空！消息加密失败。");
      return false;
    }

    try {
      msg["info"] = MessageEncrypte().encodeMessage(secret, msg["info"]);
      send(json.encode(msg));
      return true;
    } catch (e) {
      print("发送消息失败：$e");
      return false;
    }
  }
}
