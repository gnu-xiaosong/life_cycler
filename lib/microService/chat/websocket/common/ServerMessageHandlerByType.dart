/*
 针对不同消息类型进行处理
 */
import 'dart:convert';
import 'dart:io';

import 'package:app_template/microService/chat/websocket/common/Console.dart';
import 'package:app_template/microService/chat/websocket/common/secret.dart';
import 'package:app_template/microService/chat/websocket/common/tools.dart';
import '../../../../manager/GlobalManager.dart';
import '../model/ClientObject.dart';
import 'MessageEncrypte.dart';
import 'OffLineHandler.dart';

class ServerMessageHandlerByType with Console {
  Tool tool = Tool();
  MessageEncrypte messageEncrypte = MessageEncrypte();
  // 消息类型
  late Map msgDataTypeMap;

  // 消息处理函数
  void handler(HttpRequest request, WebSocket webSocket) {
    //***********************Message Type  Handler*******************************
    if (msgDataTypeMap["type"] == "SCAN") {
      // 解密info字段
      msgDataTypeMap["info"] =
          messageEncrypte.decodeAuth(msgDataTypeMap["info"]);
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
          messageEncrypte.decodeAuth(msgDataTypeMap["info"]);
      printInfo("解密结果:$msgDataTypeMap");

      // 客户端client 第一次请求认证服务端server
      auth(request, webSocket);

      // 认证成功被动触发一次离线消息队列处理
      OffLine offLine = OffLine();
      offLine.offLineHandler();
    } else if (msgDataTypeMap["type"] == "MESSAGE") {
      // 获取websoket对应的ClientObject对象
      ClientObject clientObject = getClientObject(request, webSocket);

      // 解密info字段
      msgDataTypeMap["info"] = messageEncrypte.decodeMessage(
          clientObject.secret, msgDataTypeMap["info"]);
      // 为消息类型
      message(request, webSocket);
    } else if (msgDataTypeMap["type"] == "REQUEST_INLINE_CLIENT") {
      // 获取websoket对应的ClientObject对象
      ClientObject clientObject = getClientObject(request, webSocket);
      //请求在线客户端client
      // 解密info字段
      msgDataTypeMap["info"] = messageEncrypte.decodeMessage(
          clientObject.secret, msgDataTypeMap["info"]);
      // 请求在线用户
      requestInlineClient(request, webSocket);
    } else if (msgDataTypeMap["type"] == "REQUEST_SCAN_ADD_USER") {
      printInfo("-------------REQUEST_SCAN_ADD_USER-----------------");

      // 用于扫码添加好友
      // 获取websoket对应的ClientObject对象
      ClientObject clientObject = getClientObject(request, webSocket);
      //请求在线客户端client
      // 解密info字段
      msgDataTypeMap["info"] = messageEncrypte.decodeMessage(
          clientObject.secret, msgDataTypeMap["info"]);

      // 请求在线用户
      responseScanAddUser(request, webSocket);
    } else {
      // 未标识消息类型
      printWarn("未识别消息类型: ${msgDataTypeMap.toString()}");
    }
  }

  /*
   用于扫码添加好友
   */
  void responseScanAddUser(HttpRequest request, WebSocket webSocket) {
    // 接收方deviceId
    String recive_deviceId = msgDataTypeMap["info"]["recipient"]["id"] ?? "";

    // 根据deviceId获取clientObject
    ClientObject? receive_clientObject =
        tool.getClientObjectByDeviceId(recive_deviceId);

    /// 1.封装数据
    Map send_data = msgDataTypeMap;

    print(send_data);

    // 判断对方是否在线
    if (receive_clientObject == null) {
      //***************************待测试需要找第三个设备: 存在bug******************
      print("对方不在线");

      /// 2.加密数据
      send_data["info"] = MessageEncrypte()
          .encodeMessage(receive_clientObject!.secret, send_data["info"]);
      // 发送者
      String send_deviceId = msgDataTypeMap["info"]["sender"]["id"] ?? "";
      ClientObject? send_clientObject =
          tool.getClientObjectByDeviceId(send_deviceId);
      // 利用sender方加密信息
      send_data["info"] = MessageEncrypte()
          .encodeMessage(send_clientObject!.secret, send_data["info"]);
      // 不在线，进入离线消息队列等待： send_data已加密数据
      printWarn(
          "because receiver is offline for REQUEST_SCAN_ADD_USER,so the msg data enter the offLineMessageQueue");
      OffLine offLine = OffLine();
      offLine.enOffLineQueue(send_deviceId, send_clientObject!.secret,
          send_data); // send_data已加密，发送方加密
    } else {
      //***************************待测试需要找第三个设备******************
      // 在线直接发起add user请求
      /// 2.加密数据
      send_data["info"] = MessageEncrypte()
          .encodeMessage(receive_clientObject!.secret, send_data["info"]);

      /// 3.发送
      try {
        receive_clientObject.socket.add(json.encode(send_data));
        printInfo("server send REQUEST_SCAN_ADD_USER: successful!");
      } catch (e) {
        printCatch(
            "server send REQUEST_SCAN_ADD_USER: failure!,more detail: $e");
      }
    }
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

    printInfo("有主机: $clientIp:$clientPort 扫描本机!");
    // 算法加密:采用auth加解密算法
    re["info"] = messageEncrypte.encodeAuth(re["info"]);

    // 发送消息给client
    webSocket.add(json.encode(re));
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
    Map clientAuthResult = messageEncrypte.clientInitAuth(msgDataTypeMap);

    printInfo("----------------AUTH认证------------------");
    // printInfo(clientAuthResult);

    if (clientAuthResult["result"]) {
      // 加密组合
      String data_encry = clientIp.toString() +
          clientPort.toString() +
          DateTime.now().toString();
      String secret = encrypte(data_encry);
      // 2.1 如果认证成功则封装该client为WebsocketClientObject并添加进全局list
      ClientObject client = ClientObject(
        deviceId: msgDataTypeMap["deviceId"],
        socket: webSocket,
        ip: clientIp.toString(),
        secret: secret,
        port: clientPort!.toInt(),
      );

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
      re["info"] = messageEncrypte.encodeAuth(re["info"]);
      printInfo("-----------------测试点-------------------------");
      // print(re);
      // 项该client发送认证成功
      webSocket.add(json.encode(re));
      printSuccess(
          'Client connected: IP = $clientIp, Port = $clientPort is connect successful!');
    } else {
      // 2.2.不通过client认证，则返回错误消息
      Map re = {
        "type": "AUTH",
        "info": {"code": "300", "msg": clientAuthResult["msg"]}
      };
      // 消息加密: 认证类的message的key为空
      re["info"] = messageEncrypte.encodeAuth(re["info"]);
      // 项该client发送认证失败消息
      webSocket.add(json.encode(re));
      // 主动断开该client的连接
      webSocket.close();
    }
  }

  /*
    消息类型
   */
  void message(HttpRequest request, WebSocket webSocket) {
    // 1.客户端身份验证: deviceId为发送者的设备id
    bool secret_auth = tool.clientAuth(
        msgDataTypeMap["info"]["sender"]["id"], request, webSocket);

    if (secret_auth) {
      // 2.如果认证成功，将该消息添加进client的消息队列中
      GlobalManager.webscoketClientObjectList.map((websocketClientObj) {
        if (websocketClientObj.socket == webSocket ||
            request.connectionInfo?.remoteAddress.address ==
                websocketClientObj.ip) {
          printInfo(
              "----------------中断处理：找到了目标websocket------------------------");
          // 算法加密
          msgDataTypeMap["info"] = messageEncrypte.encodeMessage(
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
      re["info"] = messageEncrypte.encodeAuth(re["info"]);

      printSuccess(">> send:$re");
      // 发送
      webSocket.add(json.encode(re));
      // 3.2 主动关闭该不信任的client客户端
      webSocket.close();
      // 3.3 更改该client的状态
      GlobalManager.webscoketClientObjectList.map((websocketClientObj) {
        if (websocketClientObj.socket == webSocket ||
            request.connectionInfo?.remoteAddress.address ==
                websocketClientObj.ip) {
          printInfo(
              "----------------中断处理：找到了目标websocket------------------------");
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

  /*
   请求server在线client用户
   */
  void requestInlineClient(HttpRequest request, WebSocket webSocket) {
    String deviceId = msgDataTypeMap["info"]["deviceId"];
    // 1.客户端身份验证
    bool _auth = tool.clientAuth(deviceId, request, webSocket);

    if (_auth) {
      // 认证成功
      // 1. 根据deviceId获取在线client的deviceId
      List inlineDeviceId = tool.getInlineClient(deviceId);
      // 2.根据deviceId获取接收方clientObject
      ClientObject? clientObject = tool.getClientObjectByDeviceId(deviceId);
      // 3.封装消息
      Map re = {
        "type": "REQUEST_INLINE_CLIENT",
        "info": {"deviceId": inlineDeviceId}
      };
      // 4.加密
      re["info"] =
          MessageEncrypte().encodeMessage(clientObject!.secret, re["info"]);
      // 5.发送
      try {
        printInfo("-----REQUEST_INLINE_CLIENT------");
        clientObject.socket.add(json.encode(re));
      } catch (e) {
        printCatch("转发REQUEST_INLINE_CLIENT 消息给client失败, more detail: $e");
      }
    } else {
      // 3.1 认证失败返回数据相应给客户端
      Map re = {
        "type": "AUTH",
        "info": {
          "code": 500, //代表ip+ip验证失败
          "msg":
              "REQUEST_INLINE_CLIENT: this client for ip or port is  in pass for auth !"
        }
      };
      // 加密消息:采用auth加密
      re["info"] = messageEncrypte.encodeAuth(re["info"]);

      printSuccess(">> send:$re");
      // 发送
      webSocket.add(json.encode(re));
      // 3.2 主动关闭该不信任的client客户端
      webSocket.close();
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
