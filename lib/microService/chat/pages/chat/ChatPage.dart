import 'dart:async';
import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/pages/chat/widget/chat.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import '../../../../database/daos/UserDao.dart';
import '../../../../widgets/dropdowns/DropdownButton1.dart';
import '../../model/CommonModel.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key}) {}

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late StreamSubscription<List> _subscription;
  UserDao userDao = UserDao();
  CommonModel commonModel = CommonModel();
  String? deviceId;
  late User user; // 用户信息
  late bool isInline; // 是否在线

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取页面传递过来的ddeviceId
    deviceId = commonModel.getDeviceId(context);
    // 获取是否在线
    setState(() {
      isInline = GlobalManager.userMapMsgQueue.containsKey(deviceId);
      // 全局
      GlobalManager.isOnline = isInline;
    });

    // 订阅广播流: 判断用户在线状态
    _subscription = GlobalManager.streamController.stream.listen((onlineList) {
      print("online device: ${onlineList}");
      // 监听逻辑处理
      setState(() {
        isInline = GlobalManager.userMapMsgQueue.containsKey(deviceId);
        // 全局
        GlobalManager.isOnline = isInline;
      });
    });
  }

  @override
  void dispose() {
    // 取消订阅
    _subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  /*
  获取user信息
   */
  Future<User> getUserInfo() async {
    // 查询
    user = await userDao.selectUserByDeviceId(deviceId!);
    // print("chat user info: ${user}");

    return user;
  }

  @override
  Widget build(BuildContext context) => DefaultSheetController(
        child: FutureBuilder(
          future: getUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<User> user) {
            if (user.connectionState == ConnectionState.done) {
              if (user.hasError) {
                return Text('Error: ${user.error}');
              } else {
                return Scaffold(
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
                        user.data!.username.toString().tr(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        isInline ? "online".tr() : "offline".tr(),
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
                );
              }
            } else {
              return CircularProgressIndicator(); // 显示加载指示器
            }
          },
        ),
      );
}
