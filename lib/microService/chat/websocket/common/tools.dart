/*
工具函数
 */

import 'dart:convert';

import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/database/daos/ChatDao.dart';
import 'package:crypto/crypto.dart';

Map stringToMap(String data) {
  print("------json decode for string to map--------");
  print("待转string: $data");
  try {
    // 检查输入字符串是否是有效的JSON格式
    if (data != null && data.isNotEmpty) {
      // 使用json.decode将JSON字符串解析为Map
      Map re = json.decode(data);
      print("转换map: $re");
      return re;
    } else {
      throw FormatException("Input data is empty or null");
    }
  } catch (e) {
    // 处理解析错误，输出错误信息并返回一个空的Map
    print('Error parsing JSON: $e');
    return {};
  }
}

// auth认证加密算法认证:md5算法
String generateMd5Secret(String data) {
  var bytes = utf8.encode(data); // data being hashed
  String digest = md5.convert(bytes) as String;
  return digest;
}

// 客户端接收消息处理函数
void handlerMessgae(msgDataTypeMap) {
  // 信息为map类型
  print("等待client消息处理");
  // 写入数据库中
  // 消息
  Map msgObj = msgDataTypeMap["info"];

  // 1.实例化ChatDao事务操作类
  ChatDao chatDao = ChatDao();

  // 转为字符
  msgObj["content"]["attachments"] =
      msgObj["content"]["attachments"].toString();
  // 封装实体
  ChatsCompanion chatsCompanion = ChatsCompanion(
      senderId: msgObj["senderId"], //发送者ID,
      senderUsername: msgObj["sender"]["username"], // 发送者用户名
      senderAvatar: msgObj["sender"]["avatar"], // 发送者头像
      recipientId: msgObj["recipient"]["id"], //接收者ID（对应user表的唯一id），群聊时为群号',
      recipientType: msgObj["recipient"]["type"], //接收者类型
      contentText: msgObj["content"]["text"], //文本内容',
      contentAttachments: msgObj["content"]["attachments"], //附件列表',
      timestamp: msgObj["timestamp"], //时间戳,
      metadataMessageId: msgObj["metadata"]["messageId"], //消息ID',
      //消息状态,消息状态，例如 sent, delivered, read
      metadataStatus: msgObj["metadata"]["status"]);

  chatDao.insertChat(chatsCompanion).then((value) {
    print("插入消息结果:$value");
  });
  // 写入页面缓存队列中：主要用于，用户页面显示消息取用，省去查询数据库耗时
}
