/*
 * @Author: xskj
 * @Date: 2023-12-29 13:25:12
 * @LastEditors: xskj
 * @LastEditTime: 2023-12-29 13:40:14
 * @Description: 聊天websocket管理器类
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:app_template/config/AppConfig.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../microService/chat/websocket/Client.dart';
import '../microService/chat/websocket/Server.dart';

class ChatWebsocketIsolateManager {
  // 静态属性，存储唯一实例
  static ChatWebsocketIsolateManager? _instance;
  /*
    选择本机为服务器端还是客户端策略
   */
  // IP地址
  InternetAddress? server_ip = InternetAddress.anyIPv4;
  // 端口port
  final int port = AppConfig.port;
  bool result = true; // 是否作为服务端
  bool isServer = true; // 是否作为服务端
  // 限制扫描最大ip数
  Object limitPort = 100;

  // 私有的命名构造函数，确保外部不能实例化该类
  ChatWebsocketIsolateManager._internal() {
    // 初始化逻辑
    print("-------chatWebsocket instance-----");
  }

  // 提供一个静态方法来获取实例
  static ChatWebsocketIsolateManager getInstance() {
    _instance ??= ChatWebsocketIsolateManager._internal();
    return _instance!;
  }

  Future<bool> selectLocalHostAsServerStrategy(SendPort sendPort) async {
    if (!GlobalManager.appCache.containsKey("server_ip") ||
        GlobalManager.appCache.getString("server_ip")?.length == 0) {
      //设置
      await GlobalManager.appCache.setString("server_ip", "192.168.1.1");
    }

    // 获取缓存中的server_ip进行连接性测试
    //转化地址
    // 将字符 IP 地址转换为 InternetAddress 对象
    try {
      String? ipString = GlobalManager.appCache.getString("server_ip");
      sendPort.send("待转换ip: $ipString");
      InternetAddress server_ip = InternetAddress(ipString!);
      sendPort.send("转换成功: ${server_ip.address}");
    } catch (e) {
      sendPort.send("转换失败: $e");
      // 关闭线程并重启
      sendPort.send("close");
      // exit(0);
    }

    // 存在server_进行连接性测试
    bool isConnected =
        await testConnection("${server_ip.toString()}", AppConfig.port);

    if (isConnected) {
      // 检测连接成功
      result = false;
    } else {
      // 1. 获取子网
      // 192.168.0.1
      var wifiIP = await NetworkInfo().getWifiIP();
      sendPort.send("本机: $wifiIP");
      // 192.168.0
      var subnet = ipToCSubnet(wifiIP!);
      sendPort.send("子网ip:$subnet");

      // 2. 进行连接性测试: 策略为ip+端口连接检测

      int i = 1;
      while (result && i != limitPort) {
        sendPort.send("测试地址: $subnet.$i:${AppConfig.port}");
        bool isConnected = await testConnection("$subnet.$i", AppConfig.port);
        if (isConnected) {
          // 服务端ip
          server_ip = InternetAddress("$subnet.$i");
          sendPort.send('连接成功！');
          result = false;

          // 存储server的ip地址，备下次直接使用
          await GlobalManager.appCache
              .setString("server_ip", server_ip.toString());
          break;
        } else {
          sendPort.send('连接失败。');
        }
        i++;
      }
    }

    // 3. 如果存在服务端则返回：false 并设置服务端ip地址绑定 启动客户端服务

    return result;
  }

  void isolateBootWebsocket() async {
    // 创建一个接收子线程消息的ReceivePort
    final receivePort = ReceivePort();

    // 启动一个新的Isolate，执行子线程函数
    await Isolate.spawn(bootWebsocket, receivePort.sendPort);

    // 监听子线程传来的消息
    receivePort.listen((message) {
      print('接收到子线程的消息: $message');

      if (message == "close") {
        // 关闭线程
        receivePort.close();
        print("线程已关闭!");
      }
    });
  }

  /*
    启动websocket服务
   */
  void bootWebsocket(SendPort sendPort) async {
    sendPort.send("子线程启动!");
    // 1.判断是否作为server端
    bool isServer = await selectLocalHostAsServerStrategy(sendPort);

    // 2.启动对用的socket
    if (isServer) {
      // 启动server
      // 实例化WebSocketServer
      ChatWebsocketServer chatWebsocketServer = ChatWebsocketServer();
      chatWebsocketServer.ip = AppConfig.ip;
      chatWebsocketServer.port = AppConfig.port;
      // 启动server
      chatWebsocketServer.start();
      // 将是否是server的结果发送回主线程
      sendPort.send("启动server成功!");
    } else {
      // 启动client
      ChatWebsocketClient chatWebsocketClient = ChatWebsocketClient();
      chatWebsocketClient.ip = server_ip;
      chatWebsocketClient.port = AppConfig.port;
      // 连接
      chatWebsocketClient.connnect();
      // 将是否是server的结果发送回主线程
      sendPort.send("启动client成功!");
    }
  }

  Future<bool> testConnection(String ipAddress, int port) async {
    try {
      RawDatagramSocket socket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.timeout(Duration(seconds: 1)); // 设置超时时间为1秒钟

      Completer<bool> completer = Completer<bool>();

      // 发送一个UDP数据包给目标地址和端口
      await socket.send(utf8.encode('ping'), InternetAddress(ipAddress), port);

      // 监听来自目标地址的响应
      socket.listen((RawSocketEvent event) async {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = await socket.receive();
          if (datagram != null) {
            print(
                '收到来自 ${datagram.address.address}:${datagram.port} 的响应: ${utf8.decode(datagram.data)}');
            completer.complete(true); // 表示连接成功
          }
        }
      });

      // 等待超时
      await Future.delayed(Duration(seconds: 1));

      // 如果未收到响应，则连接失败
      if (!completer.isCompleted) {
        print('连接超时，未收到响应');
        completer.complete(false);
      }

      return completer.future;
    } catch (e) {
      print('连接测试失败: $e');
      return false;
    }
  }
}
