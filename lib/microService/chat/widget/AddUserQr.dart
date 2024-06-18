/*
添加好友二维码
 */

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class AddUserQr extends StatefulWidget {
  const AddUserQr({super.key});

  @override
  State<AddUserQr> createState() => _AddUserQrState();
}

class _AddUserQrState extends State<AddUserQr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qr'),
        actions: [],
      ),
      body: Center(
        child: PrettyQr(
          image: AssetImage('images/twitter.png'),
          typeNumber: 3,
          size: 200,
          data: 'https://www.google.ru',
          errorCorrectLevel: QrErrorCorrectLevel.M,
          roundEdges: true,
        ),
      ),
    );
  }
}
