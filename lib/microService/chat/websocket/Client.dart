import 'package:app_template/common/WebsocketClient.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'common/ClientMessageHandlerByType.dart';
import 'common/MessageEncrypte.dart';
import 'common/tools.dart';

class ChatWebsocketClient extends WebsocketClient {
  ClientMessageHandlerByType clientMessageHandlerByType =
      ClientMessageHandlerByType();
  /*
  client与server连接成功时
   */
  @override
  void conn_success(WebSocketChannel? channel) {
    String plait_text = "I am websocket client that want to authenticate";
    String key = "sjkvsbkjdvbsdjvhbsjhvbdsjhvbsdjhvbsdjhvbsdvjs";
    // 发起身份认证
    Map auth_req = {
      "type": "AUTH",
      "info": {
        "plait_text": plait_text,
        "key": key,
        "encrypte": generateMd5Secret(key + plait_text)
      }
    };
    // 消息加密:采用AUTH级别
    auth_req["info"] = MessageEncrypte.encodeAuth(auth_req["info"]);
    // 发送
    try {
      channel?.sink.add(auth_req);
    } catch (e) {
      print("发送AUTH认证失败!请重新发起认证，连接将中断!");
      channel!.sink.close(status.goingAway);
    }
    // TODO: implement conn_success
    super.conn_success(channel);
  }

  /*
  监听消息处理程序
   */
  @override
  void listenMessageHandler(message) {
    // 根据不同消息类型处理程序
    clientMessageHandlerByType.handler(channel);
    // 将string重构为Map
    Map msgDataTypeMap = stringToMap(message.toString());
    // 传递消息
    clientMessageHandlerByType.msgDataTypeMap = msgDataTypeMap;
    // TODO: implement listenMessageHandler
    super.listenMessageHandler(message);
  }

  /*
  连接中断时
   */
  @override
  void interruptHandler(WebSocketChannel channel) {
    // TODO: implement interruptHandler
    super.interruptHandler(channel);
  }
}
