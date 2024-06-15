/*
 针对不同消息类型进行处理
 */
import 'dart:io';

import 'package:app_template/microService/chat/websocket/common/secret.dart';
import '../../../../manager/GlobalManager.dart';
import '../model/ClientObject.dart';
import 'MessageEncrypte.dart';

class ServerMessageHandlerByType {
  // 消息类型
  late Map msgDataTypeMap;

  // 消息处理函数
  void handler(HttpRequest request, WebSocket webSocket) {
    //***********************Message Type  Handler*******************************
    if (msgDataTypeMap["type"] == "SCAN") {
      // 解密info字段
      msgDataTypeMap["info"] =
          MessageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      // 客户端请求局域网内服务端server的请求
      scan(request, webSocket);
    } else if (msgDataTypeMap["type"] == "AUTH") {
      //************************测试************************************
      // msgDataTypeMap["info"] =
      //     MessageEncrypte.encodeAuth(msgDataTypeMap["info"]);
      // print("加密结果: $msgDataTypeMap");
      //***************************************************************
      // 解密info字段
      msgDataTypeMap["info"] =
          MessageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      print("解密结果:$msgDataTypeMap");

      // 客户端client 第一次请求认证服务端server
      auth(request, webSocket);
    } else if (msgDataTypeMap["type"] == "MESSAGE") {
      // 获取websoket对应的ClientObject对象
      ClientObject clientObject = getClientObject(request, webSocket);

      // 解密info字段
      msgDataTypeMap["info"] = MessageEncrypte.decodeMessage(
          clientObject.secret, msgDataTypeMap["info"]);
      // 为消息类型
      message(request, webSocket);
    } else {
      // 未标识消息类型
      print("未识别消息类型: ${msgDataTypeMap.toString()}");
    }
    //***********************Message Type  Handler*******************************
  }

  /*
    客户端请求局域网内服务端server的请求
   */
  void scan(HttpRequest request, WebSocket webSocket) {
    // 获取客户端 IP 和端口
    var clientIp = request.connectionInfo?.remoteAddress.address;
    var clientPort = request.connectionInfo?.remotePort;

    // 不进行加密，直接明文返回
    Map re = {
      "type": "SCAN",
      "info": {"code": 200, "msg": "I am server for websocket!"}
    };

    print("有主机: $clientIp:$clientPort 扫描本机!");
    // 算法加密:采用auth加解密算法
    re["info"] = MessageEncrypte.encodeAuth(re["info"]);

    // 发送消息给client
    webSocket.add(re.toString());
    // 主动关闭连接
    webSocket.close();
  }

  /*
    客户端client 第一次请求认证服务端server
   */
  void auth(HttpRequest request, WebSocket webSocket) {
    // 获取客户端 IP 和端口
    var clientIp = request.connectionInfo?.remoteAddress.address;
    var clientPort = request.connectionInfo?.remotePort;

    // 1. client认证
    Map clientAuthResult = MessageEncrypte.clientAuth(msgDataTypeMap);

    print("----------------AUTH认证------------------");
    print(clientAuthResult);

    if (clientAuthResult["result"]) {
      // 加密组合
      String data_encry = clientIp.toString() +
          clientPort.toString() +
          DateTime.now().toString();
      String secret = encrypte(data_encry);
      // 2.1 如果认证成功则封装该client为WebsocketClientObject并添加进全局list
      ClientObject client = ClientObject(
          socket: webSocket,
          ip: clientIp.toString(),
          secret: secret,
          port: clientPort!.toInt());

      // 添加进lsit中
      GlobalManager.webscoketClientObjectList.add(client);

      // 返回消息
      Map re = {
        "type": "AUTH",
        "info": {
          "code": "200", // 代表成功
          "secret": secret, //通信秘钥
          "msg": clientAuthResult["msg"]
        }
      };
      // 消息加密: 认证类的message的key为空
      re["info"] = MessageEncrypte.encodeAuth(re["info"]);
      // 项该client发送认证成功
      webSocket.add(re.toString());
      print(
          'Client connected: IP = $clientIp, Port = $clientPort is connect successful!');
    } else {
      // 2.2.不通过client认证，则返回错误消息
      Map re = {
        "type": "AUTH",
        "info": {"code": "300", "msg": clientAuthResult["msg"]}
      };
      // 消息加密: 认证类的message的key为空
      re["info"] = MessageEncrypte.encodeAuth(re["info"]);
      // 项该client发送认证失败消息
      webSocket.add(re.toString());
      // 主动断开该client的连接
      webSocket.close();
    }
  }

  /*
  客户端client通信秘钥认证
   */
  bool clientAuth(String secret, HttpRequest request, WebSocket webSocket) {
    ClientObject clientObject = getClientObject(request, webSocket);
    if (secret == clientObject.secret) {
      return true;
    } else {
      return false;
    }
  }

  /*
    消息类型
   */
  void message(HttpRequest request, WebSocket webSocket) {
    // 1.客户端身份验证
    bool secret_auth =
        clientAuth(msgDataTypeMap["info"]["secret"], request, webSocket);

    if (secret_auth) {
      // 2.如果认证成功，将该消息添加进client的消息队列中
      GlobalManager.webscoketClientObjectList.map((websocketClientObj) {
        if (websocketClientObj.socket == webSocket ||
            request.connectionInfo?.remoteAddress.address ==
                websocketClientObj.ip) {
          print("----------------中断处理：找到了目标websocket------------------------");
          // 算法加密
          msgDataTypeMap["info"] = MessageEncrypte.encodeMessage(
              websocketClientObj.secret, msgDataTypeMap["info"]);
          //添加新消息进入消息队列中
          websocketClientObj.messageQueue.enqueue(msgDataTypeMap);
          // 返回
          return websocketClientObj;
        } else {
          // 返回原来的
          return websocketClientObj;
        }
      });
    } else {
      // 3.1 认证失败返回数据相应给客户端
      Map re = {
        "type": "AUTH",
        "info": {"code": 400, "msg": "secret is not pass!"}
      };
      // 加密消息:采用auth加密
      re["info"] = MessageEncrypte.encodeAuth(re["info"]);
      // 发送
      webSocket.add(re.toString());
      // 3.2 主动关闭该不信任的client客户端
      webSocket.close();
      // 3.3 更改该client的状态
      GlobalManager.webscoketClientObjectList.map((websocketClientObj) {
        if (websocketClientObj.socket == webSocket ||
            request.connectionInfo?.remoteAddress.address ==
                websocketClientObj.ip) {
          print("----------------中断处理：找到了目标websocket------------------------");
          //找到了该webSocket,更改属性: 3 为被ban状态
          websocketClientObj.status = 3;
          // 返回
          return websocketClientObj;
        } else {
          // 返回原来的
          return websocketClientObj;
        }
      });
    }
  }

  ClientObject getClientObject(HttpRequest request, WebSocket webSocket) {
    late ClientObject clientObject;
    for (ClientObject clientObject_item
        in GlobalManager.webscoketClientObjectList) {
      // 根据ip地址匹配查找
      if (clientObject_item.ip ==
              request.connectionInfo?.remoteAddress.address ||
          clientObject_item.socket == webSocket) {
        // 匹配成功
        clientObject = clientObject_item;
      }
    }

    return clientObject;
  }
}
