/*
 cahtPage页面的函数业务模块
 */

import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../database/LocalStorage.dart';
import '../../../database/daos/ChatDao.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../websocket/Client.dart';
import '../websocket/common/MessageEncrypte.dart';
import '../websocket/common/unique_device_id.dart';

class ChatPageModel extends ChatWebsocketClient {
  ChatDao chatDao = ChatDao();
  MessageEncrypte messageEncrypte = MessageEncrypte();

  /*
   封装chat页面的message数据: 明文
   */
  messageInChat(Map message) {
    // 消息类型
    String msgType = message["info"]["msgType"];
    // 发送者
    final _user = types.User(
      id: message["info"]["sender"]["id"].toString(), // 唯一用户 ID
    );
    late final _message;
    // 判断消息的类型:根据不同的消息类型对消息进行封装
    if (msgType == "text") {
      // 文本消息
      _message = types.TextMessage(
          // 发送者
          author: _user,
          //消息id
          id: message["info"]["metadata"]["messageId"].toString(),
          // 文本
          text: message["info"]["content"]["text"].toString(),
          // 发送时间
          createdAt: int.parse(message["info"]["timestamp"]) ??
              DateTime.now().millisecondsSinceEpoch,
          // 数据元: Map<String, dynamic>
          metadata: message["info"]["metadata"]);
    } else if (msgType == "file") {
      // 文件消息类型
    } else {
      // 默认未识别消息类型
    }

    return _message;
  }

  /*
  格式转换: Chat 转 Message
   */
  Future<List<types.Message>> chatToMessageTypeList(List<Chat> chatList) async {
    var message;
    final String id = await UniqueDeviceId.getDeviceUuid().toString();
    final _user = types.User(
      id: id,
    );
    //
    List<types.Message> messageList = [];

    for (Chat chat in chatList) {
      // 解耦附件列表，字符串结构
      Map attachments_list = json.decode(chat.contentAttachments.toString());
      // 根据不同消息类型判断
      if (chat.msgType == "audio") {
        // 音频
        message = types.AudioMessage(
            author: _user,
            duration: Duration(),
            id: chat.metadataMessageId,
            name: attachments_list[0]["name"],
            size: 123,
            uri: attachments_list[0]["url"]);
      } else if (chat.msgType == "custom") {
        // 自定义
      } else if (chat.msgType == "file") {
        // 文件
        message = types.FileMessage(
          author: _user,
          createdAt: chat.timestamp.millisecondsSinceEpoch,
          id: chat.metadataMessageId,
          // mimeType: lookupMimeType(result.files.single.path!),
          name: attachments_list[0]["name"],
          size: 123, //result.files.single.size,
          uri: attachments_list[0]["url"],
        );
      } else if (chat.msgType == "image") {
        // 图片
        message = types.ImageMessage(
          author: _user,
          createdAt: chat.timestamp.millisecondsSinceEpoch,
          // height: image.height.toDouble(),
          id: chat.metadataMessageId,
          name: attachments_list[0]["name"],
          size: 123, //bytes.length,
          uri: attachments_list[0]["url"],
          // width: image.width.toDouble(),
        );
      } else if (chat.msgType == "system") {
        // 系统
      } else if (chat.msgType == "text") {
        // ***************文本:先测试********************
        message = types.TextMessage(
            author: _user,
            id: chat.metadataMessageId,
            text: chat.contentText,
            createdAt: chat.timestamp.microsecondsSinceEpoch);
      } else if (chat.msgType == "video") {
        // 视频
        message = types.VideoMessage(
            author: _user,
            id: chat.metadataMessageId,
            name: attachments_list[0]["name"],
            size: 123,
            uri: attachments_list[0]["url"]);
      } else if (chat.msgType == "unsupported") {
        // 不支持的类型
      } else {
        // 未知类型
        print("未知消息类型");
      }
      messageList.add(message);
    }
    return messageList;
  }

  /*
  获取聊天记录
   */
  Future<List<Chat>> getUserChatMessagesByDeviceId(
      {required String userDeviceId, required String myselfDeviceId}) async {
    // 封装查询
    ChatsCompanion chatsCompanion = ChatsCompanion.insert(
        senderUsername: "senderUsername",
        contentText: "contentText",
        metadataMessageId: "metadataMessageId",
        metadataStatus: "metadataStatus",
        timestamp: DateTime.now(),
        // 查询参数
        senderId: Value(userDeviceId),
        recipientId: Value(myselfDeviceId),
        msgType: 'recipientType',
        isGroup: 0);
    // 查询数据库
    List<Chat> chatMsgList =
        await chatDao.selectChatMessagesByDeviceId(chatsCompanion);

    return chatMsgList;
  }
}
