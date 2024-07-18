import 'package:app_template/microService/chat/pages/chat/widget/chat.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import '../../../../config/AppConfig.dart';
import '../../../../widgets/dropdowns/DropdownButton1.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key}) {}

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) => DefaultSheetController(
        child: Scaffold(
          extendBody: true,
          appBar: AppBar(
            // 设置背景色
            backgroundColor: Colors.grey,
            // 设置 icon 主题
            iconTheme: IconThemeData(
              // 颜色
              color: Colors.blue,
              // 不透明度
              opacity: 0.5,
            ),
            // 标题居中
            centerTitle: true,
            // 标题左右间距为
            leadingWidth: 50.sp,
            //标题间隔
            titleSpacing: 1,
            //左边
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                  iconSize: 20.sp,
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // 返回
                    Navigator.of(context).pop();
                  });
            }),
            //标题--双标题
            title: Column(children: [
              Text(
                AppConfig.appConfig['name'].toString().tr(),
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "我是小标题".tr(),
                style: const TextStyle(fontSize: 10),
              ),
            ]),
            //action（操作）right
            actions: [
              IconButton(
                onPressed: () {
                  // customBackground(context);
                },
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.delete),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton1(),
              )
            ],
            // 自定义图标样式
            actionsIconTheme: IconThemeData(
              color: Colors.blue,
            ),
            shadowColor: Theme.of(context).shadowColor,
            //灵活区域
            flexibleSpace: SizedBox(
                width: double.infinity, //无限
                height: 160.h,
                child: Container(
                  color: Colors.orange,
                )),
          ),
          body: chatView(),
        ),
      );
}
