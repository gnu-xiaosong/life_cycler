/*
密码本微服务页面
 */
import 'package:flutter/material.dart';
import 'package:radial_button/widget/circle_floating_button.dart';

class CipherBookPage extends StatefulWidget {
  const CipherBookPage({super.key});

  @override
  State<CipherBookPage> createState() => _CipherBookPageState();
}

class _CipherBookPageState extends State<CipherBookPage> {
  var itemsActionBar = [
    FloatingActionButton(
      backgroundColor: Colors.greenAccent,
      onPressed: () {},
      child: Icon(Icons.add),
    ),
    FloatingActionButton(
      backgroundColor: Colors.indigoAccent,
      onPressed: () {},
      child: Icon(Icons.camera),
    ),
    FloatingActionButton(
      backgroundColor: Colors.orangeAccent,
      onPressed: () {},
      child: Icon(Icons.card_giftcard),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // 添加浮动按钮
      floatingActionButton: CircleFloatingButton.floatingActionButton(
        items: itemsActionBar,
        color: Colors.redAccent,
        icon: Icons.ac_unit,
        duration: Duration(milliseconds: 1000),
        curveAnim: Curves.ease,
        useOpacity: true,
      ),
      body: Index(),
    );
  }
}

class Index extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red,
    );
  }
}
