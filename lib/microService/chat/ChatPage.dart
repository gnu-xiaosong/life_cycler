import 'dart:convert';
import 'dart:io';
import 'package:app_template/database/LocalStorage.dart';
import 'package:app_template/microService/chat/websocket/common/unique_device_id.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as FlutterChat;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../../config/AppConfig.dart';
import '../../widgets/dropdowns/DropdownButton1.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

import 'model/ChatPageModel.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key}) {}

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatPageModel chatPageModel = ChatPageModel();
  // 存储消息的列表
  List<types.Message> _messages = [];
  // 当前用户
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac', // 唯一用户 ID
  );
  // 底部可变高度
  double _changeHeight = 0.0;

  final _emoController = TextEditingController();
  late TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _emojiShowing = false;
  final FocusNode _focusNode = FocusNode();

  late AnimationController animControl;
  bool animate = false;
  bool _isText = false;

  @override
  Widget build(BuildContext context) {
    return DefaultSheetController(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: _BottomAppBar(),
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
        body: Stack(
          children: [
            FlutterChat.Chat(
              messages: _messages, // 消息列表
              onAttachmentPressed: _handleAttachmentPressed, // 附件按钮点击事件
              onMessageTap: _handleMessageTap, // 消息点击事件
              onPreviewDataFetched: _handlePreviewDataFetched, // 预览数据加载完成事件
              onSendPressed: _handleSendPressed, // 发送按钮点击事件
              showUserAvatars: true, // 显示用户头像
              showUserNames: true, // 显示用户名
              user: _user, // 当前用户
              // 自定义底部菜单栏
              customBottomWidget: chatBottom(),
              bubbleBuilder: _bubbleBuilder,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> initState() async {
    super.initState();
    // 接收页面传递过来的deviceId
    String? deviceId = ModalRoute.of(context)?.settings.arguments.toString();

    // 添加监听器来监控焦点变化
    _focusNode.addListener(() {
      print("-------------focusNode------------------");
      if (_focusNode.hasFocus) {
        print("TextField 获得焦点");
      } else {
        print("TextField 失去焦点");
      }
    });
    _loadMessages(deviceId!); // 加载消息
  }

  // 添加消息到消息列表
  void _addMessage(types.Message message) {
    // 添加进入数据库库
    setState(() {
      _messages.insert(0, message); // 将新消息插入到列表的开头
    });
  }

  // 处理附件按钮点击事件
  void _handleAttachmentPressed() {
    // 弹出一个底部弹窗，显示照片和文件选项
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection(); // 处理图片选择
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'), // 显示“照片”选项
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection(); // 处理文件选择
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'), // 显示“文件”选项
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'), // 显示“取消”选项
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 处理文件选择
  void _handleFileSelection() async {
    // 弹出文件选择器，允许选择任意类型的文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      // 封装文件消息
      final message = types.FileMessage(
        author: _user, // 当前用户
        createdAt: DateTime.now().millisecondsSinceEpoch, // 当前时间戳
        id: const Uuid().v4(), // 生成唯一消息 ID
        mimeType: lookupMimeType(result.files.single.path!), // 文件类型
        name: result.files.single.name, // 文件名
        size: result.files.single.size, // 文件大小
        uri: result.files.single.path!, // 文件路径
      );

      _addMessage(message); // 添加消息
    }
  }

  // 处理图片选择
  void _handleImageSelection() async {
    // 弹出图片选择器，选择来自图库的图片
    final result = await ImagePicker().pickImage(
      imageQuality: 70, // 图片质量压缩比例
      maxWidth: 1440, // 图片最大宽度
      source: ImageSource.gallery, // 图片来源：图库
    );

    if (result != null) {
      final bytes = await result.readAsBytes(); // 读取图片字节
      final image = await decodeImageFromList(bytes); // 解码图片

      // 封装图片消息
      final message = types.ImageMessage(
        author: _user, // 当前用户
        createdAt: DateTime.now().millisecondsSinceEpoch, // 当前时间戳
        height: image.height.toDouble(), // 图片高度
        id: const Uuid().v4(), // 生成唯一消息 ID
        name: result.name, // 图片名称
        size: bytes.length, // 图片大小
        uri: result.path, // 图片路径
        width: image.width.toDouble(), // 图片宽度
      );

      _addMessage(message); // 添加消息
    }
  }

  // 处理消息点击事件
  void _handleMessageTap(BuildContext _, types.Message message) async {
    // 如果消息是文件消息类型
    if (message is types.FileMessage) {
      // 获取本地路径
      var localPath = message.uri;

      // 如果文件是通过网络加载的
      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true, // 显示加载状态
          );

          setState(() {
            _messages[index] = updatedMessage; // 更新消息列表
          });

          // 下载文件
          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes; // 获取文件字节
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}'; // 文件保存路径

          // 如果文件不存在，则写入文件
          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null, // 取消加载状态
          );

          setState(() {
            _messages[index] = updatedMessage; // 更新消息列表
          });
        }
      }

      // 打开文件
      await OpenFilex.open(localPath);
    }
  }

  // 处理预览数据加载完成事件
  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    // 更新消息中的预览数据
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  // 处理发送文本消息
  void _handleSendPressed(types.PartialText message) {
    // 创建文本消息
    final textMessage = types.TextMessage(
      author: _user, // 当前用户
      createdAt: DateTime.now().millisecondsSinceEpoch, // 当前时间戳
      id: const Uuid().v4(), // 生成唯一消息 ID
      text: message.text, // 消息文本
    );

    _addMessage(textMessage); // 添加消息
  }

  // 加载消息
  void _loadMessages(String deviceId) async {
    // 从本地文件加载消息
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    // ********************************************************
    print("获取到的deviceId: $deviceId");
    // 本地deviceId
    String myselfDeviceId = await UniqueDeviceId.getDeviceUuid();

    // 从数据库中获取聊天信息
    List<Chat> chatMessagesList =
        (await chatPageModel.getUserChatMessagesByDeviceId(
            userDeviceId: deviceId.toString(), myselfDeviceId: myselfDeviceId));
    // 转换
    _messages = chatPageModel.chatToMessageTypeList(chatMessagesList)
        as List<types.Message>;

    setState(() {
      _messages = messages; // 更新消息列表
    });
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) {
    print("message:");
    print(message);
    // 从消息对象中提取文本
    String messageText = '';
    if (message is types.TextMessage) {
      messageText = message.text ?? ''; // 如果消息为空，则默认为空字符串
    }
    // 判断消息类型
    if (message.type == types.MessageType.image) {
      // 图片bubble
    } else if (message.type == types.MessageType.text) {
      // 文本bubble
      return ChatBubble(
        clipper: ChatBubbleClipper3(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20),
        backGroundColor: Colors.blue,
        child: Container(
          // constraints: BoxConstraints(
          //   maxWidth: MediaQuery.of(context).size.width * 0.7,
          // ),
          child: Text(
            messageText.toString().tr(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (message.type == types.MessageType.audio) {
      // 音频bubble
    } else if (message.type == types.MessageType.file) {
      // 文件bubble
    } else if (message.type == types.MessageType.system) {
      // 系统消息bubble
    } else if (message.type == types.MessageType.video) {
      // 视频bubble
    } else if (message.type == types.MessageType.unsupported) {
      // 不支持的bubble
    } else if (message.type == types.MessageType.custom) {
      // 自定义的类型bubble
    }

    return Text("遇到程序性错误!");
  }

  // 底部聊天输入框2
  Widget chatBottom() {
    // return _ExampleSheet();
    return MessageBar(
      // replyingTo: "回复消息",
      messageBarHitText: "Type your message here".tr(),
      messageBarHintStyle: TextStyle(
          fontWeight: FontWeight.w200,
          fontSize: 15,
          overflow: TextOverflow.ellipsis),
      onTextChanged: (text) {
        if (text.length != 0) {
          setState(() {
            _isText = true;
          });
        } else {
          setState(() {
            _isText = false;
          });
        }
        print("text change: $text");
      },
      // prefixIcon:
      suffixIcon: Padding(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: InkWell(
          child:
              // 切换
              _isText
                  ? InkWell(
                      child: Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 24,
                      ),
                      onTap: () {
                        // 创建一个新的 PartialText 对象并设置其文本
                        var message = types.PartialText(
                            text: _textController.text.toString() ?? '');
                        // 发送消息
                        _handleSendPressed(message);

                        _isText = false;
                        // 清空消
                        _textController.text = '';
                        // 打印发送确认
                        print("Message sent successfully.");
                      })
                  : SocialMediaRecorder(
                      // 滑动部分
                      slideToCancelText: "slide to cancel".tr(),
                      // 锁定部分
                      cancelText: "cancel".tr(),
                      cancelTextBackGroundColor: Colors.transparent,
                      // 背景颜色
                      backGroundColor: Colors.transparent,
                      recordIconBackGroundColor: Colors.blue,
                      counterBackGroundColor: Colors.transparent,

                      // fullRecordPackageHeight: 80,
                      radius: BorderRadius.circular(25),
                      // maxRecordTimeInSecond: 5,
                      startRecording: () {
                        // function called when start recording
                      },
                      stopRecording: (_time) {
                        // function called when stop recording, return the recording time
                      },
                      sendRequestFunction: (soundFile, _time) {
                        //  print("the current path is ${soundFile.path}");
                      },
                      encode: AudioEncoderType.AAC,
                    ),
          onTap: () {
            setState(() {
              // 关闭键盘
              print("----------------------open emo-----------------");
              FocusScope.of(context).unfocus();
              _emojiShowing = !_emojiShowing;
              print("open emo: $_emojiShowing");
            });
            // // 弹出emos
            // openEmjo();
          },
        ),
      ),
      rightAction: [
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: InkWell(
            child: Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: 28,
            ),
            onTap: () {
              setState(() {
                // 关闭键盘
                print("----------------------open emo-----------------");
                FocusScope.of(context).unfocus();
                _emojiShowing = false;

                animate = !animate;
                _changeHeight = (_changeHeight == 0.0 ? 300.0 : 0.0); // 切换高度
                print("_changeHeight: $_changeHeight");
              });
            },
          ),
        ),
      ],
      // left左边功能
      actions: [
        InkWell(
          child: Icon(
            Icons.file_present,
            color: Colors.black,
            size: 28,
          ),
          onTap: () {
            print("open file");
            // 打开sheet显示图片和文件
            _handleAttachmentPressed();
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 3, right: 5),
          child: InkWell(
            child: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.black,
              size: 28,
            ),
            onTap: () {
              setState(() {
                // 关闭键盘
                print("----------------------open emo-----------------");
                FocusScope.of(context).unfocus();
                animate = !animate;
                _emojiShowing = !_emojiShowing;
                print("open emo: $_emojiShowing");
              });
              // // 弹出emos
              // openEmjo();
            },
          ),
        )
      ],
      //
    );
  }

  Widget MessageBar(
      {replying = false,
      replyingTo = "",
      actions = const [],
      replyWidgetColor = const Color(0xffF4F4F5),
      replyIconColor = Colors.blue,
      replyCloseColor = Colors.black12,
      messageBarColor = const Color(0xffF4F4F5),
      sendButtonColor = Colors.blue,
      messageBarHitText = "Type your message here",
      messageBarHintStyle = const TextStyle(fontSize: 16),
      onTextChanged,
      onTapCloseReply,
      suffixIcon,
      rightAction = const [],
      prefixIcon}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            replying
                ? Container(
                    color: replyWidgetColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          color: replyIconColor,
                          size: 24,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              'Re : ' + replyingTo,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onTapCloseReply,
                          child: Icon(
                            Icons.close,
                            color: replyCloseColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ))
                : Container(),
            replying
                ? Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  )
                : Container(),
            Container(
              color: messageBarColor,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Row(
                children: <Widget>[
                  ...actions,
                  Expanded(
                    child: Container(
                      child: TextField(
                        // readOnly: true, // 不弹出键盘
                        focusNode: _focusNode,
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 3,
                        onChanged: onTextChanged,
                        decoration: InputDecoration(
                          prefixIcon: prefixIcon,
                          suffixIcon: suffixIcon,
                          hintText: messageBarHitText,
                          hintMaxLines: 1,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10),
                          hintStyle: messageBarHintStyle,
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 0.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Colors.black26,
                              width: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...rightAction,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部聊天输入框1
  Widget BottomSheet() {
    final _formKey = GlobalKey<FormBuilderState>();
    final _messageFieldKey = GlobalKey<FormBuilderFieldState>();
    // 存储信息
    String? msgText;

    return Container(
        padding: EdgeInsets.fromLTRB(0, 3.sp, 0, 3.sp),
        color: Colors.grey,
        width: double.infinity,
        height: 50.h,
        child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: StaggeredGrid.count(
              crossAxisCount: 6,
              // mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              children: [
                // left
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Center(
                    child: Icon(Icons.emoji_emotions),
                  ),
                ),
                //center
                StaggeredGridTile.count(
                  crossAxisCellCount: 4,
                  mainAxisCellCount: 1,
                  child: FormBuilder(
                      key: _formKey,
                      child: FormBuilderTextField(
                        key: _messageFieldKey,
                        name: 'text',
                        onChanged: (text) {
                          msgText = text;
                          print("msg content: $msgText");
                        },
                        decoration: InputDecoration(
                            // 提示
                            hintText: "input message",
                            // 设置背景色为灰色
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            // 确保在不同状态下使用相同的圆角边框
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            suffixIcon: MaterialButton(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  // 打印发送的消息文本
                                  print("Send: $msgText");
                                  // 创建一个新的 PartialText 对象并设置其文本
                                  var message =
                                      types.PartialText(text: msgText ?? '');
                                  // 发送消息
                                  _handleSendPressed(message);

                                  // 打印发送确认
                                  print("Message sent successfully.");
                                }),
                            prefixIcon: MaterialButton(
                                child: Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  print("emo..........");
                                })),
                      )),
                ),
                // right
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Center(
                    child: Icon(
                      Icons.add_circle_outlined,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            )));
  }

  _BottomAppBar() {
    return Container(
      width: double.infinity,
      color: Colors.red,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 底部功能栏
          bottomArea(),
          // 拓展功能区域
          toolArea(),
          // emoj
          emoj()
        ],
      ),
    );
  }

  bottomArea() {
    return Container(
      width: double.infinity,
      // height: 50.h,
      color: Colors.green,
      child: chatBottom(),
    );
  }

  toolArea() {
    List<Map> tabs = [
      {
        "tab": Tab(
          icon: Icon(Icons.directions_transit),
          text: "transit",
        ),
        "view": Center(
          child: Icon(Icons.directions_car),
        ),
      },
      {
        "tab": Tab(
          icon: Icon(Icons.directions_transit),
          text: "transit",
        ),
        "view": Center(
          child: Icon(Icons.directions_car),
        ),
      },
      {
        "tab": Tab(
          icon: Icon(Icons.directions_transit),
          text: "transit",
        ),
        "view": Center(
          child: Icon(Icons.directions_car),
        ),
      },
    ];

    return AnimatedContainer(
        duration: Duration(milliseconds: 400), // 动画持续时间
        height: _changeHeight, // 动态高度
        color: Colors.blueAccent, // 容器颜色
        child: Container(
          width: double.infinity,
          height: 100.h,
          color: Colors.blueAccent,
          child: DefaultTabController(
            length: tabs.length,
            child: Column(
              children: <Widget>[
                ButtonsTabBar(
                  backgroundColor: Colors.red,
                  tabs: [for (var item in tabs) item["tab"]],
                ),
                Expanded(
                  child: TabBarView(
                    children: [for (var item in tabs) item["view"]],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _emoController.dispose();
    super.dispose();
  }

  Widget emoj() {
    // 开始播放

    return Offstage(
        offstage: !_emojiShowing,
        child: SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: _emoController,
              scrollController: _scrollController,
              onEmojiSelected: (category, emoji) {
                print(emoji);
                if (emoji is Emoji) {
                  // 添加进文本
                  print("==================emoj=============================");
                  String text = _textController.text;
                  // 更新
                  setState(() {
                    _textController.text += emoji.emoji.toString();
                    _isText = true;
                    print("emoj msg: $text");
                  });
                }
              },
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  // Issue: https://github.com/flutter/flutter/issues/28894
                  emojiSizeMax: 28 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.2
                          : 1.0),
                ),
                swapCategoryAndBottomBar: true,
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: const CategoryViewConfig(),
                bottomActionBarConfig: const BottomActionBarConfig(
                    backgroundColor: Color(0xFFEBEFF2),
                    buttonIconColor: Colors.black,
                    buttonColor: Color(0xFFEBEFF2)),
                searchViewConfig:
                    const SearchViewConfig(backgroundColor: Color(0xFFEBEFF2)),
              ),
            )));
  }
}
