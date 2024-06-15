/*
desc: 这是封装好的websocket客户端
 */
import 'dart:io';
import 'package:app_template/config/AppConfig.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebsocketClient {
  Uri? wsUrl;

  // IP地址
  InternetAddress? ip = InternetAddress.anyIPv4;

  // 端口port
  int port = AppConfig.port;

  WebSocketChannel? channel;

  String type = "ws";

  WebsocketClient() {
    this.wsUrl = Uri.parse('$type://$ip:$port');
  }

  // 连接websocketServer
  Future<void> connnect() async {
    try {
      // 开始连接
      channel = await WebSocketChannel.connect(wsUrl!);
      await channel!.ready;
    } catch (e) {
      // 连接异常
      print("-------connnect is error, this client is interrupter------");
      print("INFO:$e");

      // 关闭连接
      channel!.sink.close(status.goingAway);
    } finally {
      //*****************连接成功回调处理函数*********************
      this.conn_success(channel);
    }

    // 监听信息
    await channel!.stream.listen((message) {
      print("received: $message");
      // 处理监听信息
      listenMessageHandler(message);
    }, onError: (e) {
      // 连接错误
      print("connect is error!");
      print("INFO: $e");
    }, onDone: () {
      // websocket连接中断
      print('WebSocket client disconnected.');
      // ***************连接中断**************
      this.interruptHandler(channel!);
      //****************连接中断**************
    });
  }

  // 连接中断处理
  void interruptHandler(WebSocketChannel channel) {
    /*
      desc: 对于连接中断的处理操作,用户继承该类并重写该方法来实现
      parameters:
          channel  WebSocketChannel  中断的WebSocket
     */

    print("$channel is interrupted !");
  }

  // 处理监听的信息处理程序
  void listenMessageHandler(message) {
    // 发送信息给服务器
    print("Broadcast: $message");
    channel!.sink.add('received: $message');
    // 关闭
    // channel!.sink.close(status.goingAway);
  }

  /*
    连接成功回调函数
     */
  void conn_success(WebSocketChannel? channel) {
    // 连接成功
    print("$channel is connected!");
  }
}
