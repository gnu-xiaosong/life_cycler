/*
  消息加密和解密算法
 */

import 'dart:convert';
import 'package:app_template/microService/chat/websocket/common/TextEncryption.dart';
import 'package:app_template/microService/chat/websocket/common/tools.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class MessageEncrypte {
  // auth 加解密key
  static String auth_key = "5eb63bbbe01eeed093cb22bb8f5acdc3";
  static int shift = 3; //移位
  //**********************************消息文本加解密******************************************************

  /*
   为map的每一个键值进行加密
   */
  static String encodeMessage(String key_secret, String data_map_str) {
    // 加密
    String data_str = TextEncryptionForJson.encrypt(
      data_map_str,
      shift,
      key_secret,
    );

    return data_str;
  }

  /*
   为map的每一个键值进行解密
   */
  static Map decodeMessage(String key_secret, String data_str) {
    String str = TextEncryptionForJson.decrypt(key_secret, shift, data_str);
    // 转为map
    Map data_map = stringToMap(str);

    return data_map;
  }

  /*
  其中key为通讯秘钥secret
   */
  // 消息加密算法AES
  static String encodeTextASE(String key, String plainText) {
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(Key.fromUtf8(key))); // 32位秘钥
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    print("解密:$decrypted");
    return encrypted.base64;
  }

  // 消息解密算法
  static String? decodeTextASE(String key, var base64String) {
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(Key.fromUtf8(key))); // 32位秘钥
    try {
      Encrypted encrypted = Encrypted.fromBase64(base64String);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      print('解密失败: $e');
      return null;
    }
  }

  // 认证消息加密算法
  static Map encodeAuth(Map<String, dynamic> data_map) {
    // return data_map;
    data_map.forEach((key, value) {
      data_map[key] = TextEncryptionForJson.encrypt(
          value.toString(), shift, auth_key.toString());
    });
    return data_map;
  }

  // 认证消息解密算法
  static Map decodeAuth(Map<String, dynamic> data_map) {
    data_map.forEach((key, value) {
      String text = TextEncryptionForJson.decrypt(
          value.toString(), shift, auth_key.toString());
      data_map[key] = text;
    });
    return data_map;
  }

  //*****************************************************************************************
  /*
   client客户端有效性认证认证
   */
  static Map clientAuth(Map data_) {
    late String plait_text;
    bool result = false;
    String msg = "AUTH: 该client客户端认证成功!";
    // 算法规则: data_["info"]["key"] + data_["info"]["plait_text"]  使用md5加密生成encrypte
    try {
      plait_text = data_["info"]["key"] + data_["info"]["plait_text"];

      Map re = {"result": result, "msg": msg};
      return re;
    } catch (e) {
      msg = "AUTH: 认证失败，缺失info的关键字段: key or plait_text";
      result = false;
    }

    try {
      String data = generateMd5Secret(plait_text);
      if (data == data_["info"]["encrypte"]) {
        result = true;
      }
    } catch (e) {
      msg = "AUTH: 认证失败，缺失secret验证秘钥!";
      result = false;
    }

    Map re = {"result": result, "msg": msg};
    return re;
  }
}
