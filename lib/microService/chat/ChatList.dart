import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/chat/widget/menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:popup_menu_plus/popup_menu_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../config/AppConfig.dart';
import '../../database/daos/UserDao.dart';
import 'package:random_avatar/random_avatar.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return _ChatListState();
  }
}

class _ChatListState extends StatefulWidget {
  _ChatListState({Key? key}) : super(key: key);
  @override
  State<_ChatListState> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_ChatListState> {
  _MyHomePageState() {
    userList = [];
  }
  GlobalKey btnKey_menu = GlobalKey();
  PopupMenu? menu;
  int page = 1; //页码
  int pageNum = 10; // 每页数量
  late List userList;
  late final controller = SlidableController(this as TickerProvider);
  //获取控制器
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("--------websocket-------");

    // 加载websocket
    GlobalManager().GlobalChatWebsocket.bootWebsocket();
    // 加载数据
    UserDao.selectUserByPage(page, pageNum).then((value) {
      print("------------用户分页显示: page=$page pageNum=$pageNum-----------");
      // 页面重构渲染数据
      setState(() {
        userList = value;
      });
      print(userList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          //centerTitle: true,
          // 标题左右间距为
          leadingWidth: 50,
          //标题间隔
          titleSpacing: 1,
          //左边
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
                iconSize: 25,
                icon: const Icon(
                  Icons.chat_bubble_outlined,
                  color: Colors.blue,
                ),
                onPressed: () {
                  //
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
              key: btnKey_menu,
              onPressed: () {
                showMenu();
              },
              icon: const Icon(
                Icons.add,
                size: 35,
              ),
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
            height: 160,
            child: Image.network(
              "https://ts1.cn.mm.bing.net/th/id/R-C.d4822697ad0424efafe6b62e5e6e0d1d?rik=ZdcMlu%2f2ng6ltA&riu=http%3a%2f%2fimg95.699pic.com%2fphoto%2f40141%2f5356.gif_wh860.gif&ehk=OMCk8kp7dU8UKPdcHORkcrjitRqABE0xoh7sa%2baGN4k%3d&risl=1&pid=ImgRaw&r=0",
              fit: BoxFit.cover,
            ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: listUser(),
        ));
  }

  doNothing(BuildContext context) {}
  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  Widget listUser() {
    return ListView(
      children: [
        for (User item in userList)
          Slidable(
            // Specify a key if the Slidable is dismissible.
            key: const ValueKey(0),

            // The start action pane is the one at the left or the top side.
            startActionPane: ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const ScrollMotion(),

              // A pane can dismiss the Slidable.
              dismissible: DismissiblePane(onDismissed: () {}),

              // All actions are defined in the children parameter.
              children: [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                  onPressed: doNothing,
                  backgroundColor: Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
                SlidableAction(
                  onPressed: doNothing,
                  backgroundColor: Color(0xFF21B7CA),
                  foregroundColor: Colors.white,
                  icon: Icons.share,
                  label: 'Share',
                ),
              ],
            ),
            // The end action pane is the one at the right or the bottom side.
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  flex: 2,
                  onPressed: (_) => controller.openEndActionPane(),
                  backgroundColor: const Color(0xFF7BC043),
                  foregroundColor: Colors.white,
                  icon: Icons.archive,
                  label: 'Archive',
                ),
                SlidableAction(
                  onPressed: (_) => controller.close(),
                  backgroundColor: const Color(0xFF0392CF),
                  foregroundColor: Colors.white,
                  icon: Icons.save,
                  label: 'Save',
                ),
              ],
            ),

            // The child of the Slidable is what the user sees when the
            // component is not dragged.
            child: ListTile(
                leading: randomAvatar('saytoonz', height: 50, width: 50),
                subtitle: Text(item.createdAt),
                trailing: Text(item.id.toString()),
                title: Text(item.username)),
          ),
      ],
    );
  }

  void onClickMenu(PopUpMenuItemProvider item) {
    // 获取index
    for (var menu in topMenus()) {
      //判断
      if (menu["menu"] == item) {
        // 执行函数
        menu["click"](context);
      }
    }
    print('Click menu -> ${item.menuTitle}');
  }

  void showMenu() {
    PopupMenu menu = PopupMenu(
        context: context,
        config: const MenuConfig(
            // itemWidth: 130,
            type: MenuType.grid,
            backgroundColor: Colors.black,
            lineColor: Colors.white70,
            maxColumn: 2),
        items: <PopUpMenuItem>[for (var item in topMenus()) item["menu"]],
        onClickMenu: onClickMenu,
        onDismiss: onDismiss);
    menu.show(widgetKey: btnKey_menu);
  }
}
