import 'package:app_template/manager/GlobalManager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: Text("add user".tr()),
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
              iconSize: 25,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
              ),
              onPressed: () {
                // 返回
                Navigator.of(context).pop();
              });
        }),
      ),
      body: Container(
          child: Center(
        child: ListView(
          children: [
            // 启动客户端
            MaterialButton(
              height: 45.0,
              onPressed: () {
                // socket client
              },
              child: const Text('扫描局域网内所有ip'),
            ),
            // 启动服务端
            MaterialButton(
              height: 45.0,
              onPressed: () {
                // socket serve
                // GlobalManager().GlobalChatWebsocket.scanDevices();
              },
              child: const Text('启动服务端'),
            ),
          ],
        ),
      )),
    );
  }
}
