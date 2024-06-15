/*
desc: 定义数据库表结构:聊天信息表
 */
import 'package:drift/drift.dart';

// 定义聊天表
@DataClassName('Chat')
class Chats extends Table {
  IntColumn get id => integer().autoIncrement()(); // 自增主键
  TextColumn get senderId => text()
      .withLength(min: 1, max: 50)
      .customConstraint('REFERENCES chats(id) ON DELETE CASCADE')
      .nullable()(); // 发送者ID
  TextColumn get senderUsername =>
      text().withLength(min: 1, max: 50)(); // 发送者用户名
  TextColumn get senderAvatar => text().nullable()(); // 发送者头像
  TextColumn get recipientId => text()
      .withLength(min: 1, max: 50)
      .customConstraint('REFERENCES chats(id) ON DELETE CASCADE')
      .nullable()(); // 接收者ID( 对影user表的唯一id),群聊时为群号
  TextColumn get recipientType => text().withLength(min: 1, max: 20)(); // 接收者类型
  TextColumn get contentText => text().withLength(min: 1, max: 255)(); // 文本内容
  TextColumn get contentAttachments => text().nullable()(); // 附件列表
  DateTimeColumn get timestamp => dateTime()(); // 时间戳
  TextColumn get metadataMessageId =>
      text().withLength(min: 1, max: 50)(); // 消息ID
  TextColumn get metadataStatus => text().withLength(min: 1, max: 20)(); // 消息状态
}
