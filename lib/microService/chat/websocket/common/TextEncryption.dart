/*
基于移位的加解密算法
 */
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';

class TextEncryption {
  static String encrypt(String key, String text) {
    // return text;
    // 进行Base64编码
    String encodedString = base64Encode(utf8.encode(text));
    String encryptedText = encodedString + key;
    print('Encoded string: $encryptedText');
    return encryptedText;
  }

  static String decrypt(String key, String encryptedText) {
    // return encryptedText;
    // 去除key
    String stringWithoutLast32 =
        encryptedText.substring(0, encryptedText.length - key.length);

    // 进行Base64解码
    List<int> decodedBytes = base64Decode(stringWithoutLast32);
    String decodedString = utf8.decode(decodedBytes);
    print('Decoded string: $decodedString');
    return decodedString;
  }
}

class TextEncryptionForJson {
  static String encrypt(String text, int shift, String key) {
    String combinedText = '$text$key';
    String encodedText = base64Encode(utf8.encode(combinedText));
    String encryptedText = '';
    for (int i = 0; i < encodedText.length; i++) {
      int charCode = encodedText.codeUnitAt(i);

      // 只对字母进行移位，其他字符保持不变
      if (charCode >= 65 && charCode <= 90) {
        encryptedText += String.fromCharCode((charCode - 65 + shift) % 26 + 65);
      } else if (charCode >= 97 && charCode <= 122) {
        encryptedText += String.fromCharCode((charCode - 97 + shift) % 26 + 97);
      } else {
        encryptedText += encodedText[i];
      }
    }
    return encryptedText;
  }

  static String decrypt(String encryptedText, int shift, String key) {
    String decodedTextWithoutKey = "";
    try {
      String decodedText = '';
      for (int i = 0; i < encryptedText.length; i++) {
        int charCode = encryptedText.codeUnitAt(i);

        // 只对字母进行反向移位，其他字符保持不变
        if (charCode >= 65 && charCode <= 90) {
          decodedText +=
              String.fromCharCode((charCode - 65 + 26 - shift) % 26 + 65);
        } else if (charCode >= 97 && charCode <= 122) {
          decodedText +=
              String.fromCharCode((charCode - 97 + 26 - shift) % 26 + 97);
        } else {
          decodedText += encryptedText[i];
        }
      }
      decodedTextWithoutKey =
          utf8.decode(base64.decode(decodedText)).replaceAll(key, '');
    } catch (e) {
      print("错误信息:${e.toString()}");
      print(">>decrypt: 未识别加密字符!");
    }

    return decodedTextWithoutKey;
  }
}
