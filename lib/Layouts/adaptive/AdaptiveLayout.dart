import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../manager/GlobalManager.dart';
import '../../pages/adaptive/Home.dart';

class AdaptiveLayout extends StatefulWidget {
  @override
  State<AdaptiveLayout> createState() => AdaptiveLayoutState();
}

class AdaptiveLayoutState extends State<AdaptiveLayout> {
  @override
  Widget build(BuildContext context) {
    print(
        "******************************我正在初始化context*******************************************");
    GlobalManager.context = context;
    return MaterialApp(
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const AdaptiveHome(),
    );
  }
}
