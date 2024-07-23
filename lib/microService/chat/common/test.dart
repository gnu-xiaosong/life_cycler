// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class EditableTextToolbarBuilderExampleApp extends StatefulWidget {
//   String messageText;
//   EditableTextToolbarBuilderExampleApp(this.messageText, {super.key});
//
//   @override
//   State<EditableTextToolbarBuilderExampleApp> createState() =>
//       _EditableTextToolbarBuilderExampleAppState(messageText);
// }
//
// class _EditableTextToolbarBuilderExampleAppState
//     extends State<EditableTextToolbarBuilderExampleApp> {
//   String messageText;
//   _EditableTextToolbarBuilderExampleAppState(this.messageText);
//
//   @override
//   void initState() {
//     super.initState();
//     // On web, disable the browser's context menu since this example uses a custom
//     // Flutter-rendered context menu.
//     if (kIsWeb) {
//       BrowserContextMenu.disableContextMenu();
//     }
//   }
//
//   @override
//   void dispose() {
//     if (kIsWeb) {
//       BrowserContextMenu.enableContextMenu();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SelectableText(
//       messageText.toString().tr(),
//       contextMenuBuilder:
//           (BuildContext context, EditableTextState editableTextState) {
//         // 自定义toolbar
//         return AdaptiveTextSelectionToolbar(
//             anchors: editableTextState.contextMenuAnchors,
//             // Build the default buttons, but make them look custom.
//             // In a real project you may want to build different
//             // buttons depending on the platform.
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 color: Colors.blue,
//               ),
//               Container(
//                 width: 50,
//                 height: 50,
//                 color: Colors.red,
//               ),
//               Container(
//                 width: 50,
//                 height: 50,
//                 color: Colors.blueGrey,
//               ),
//               Container(
//                 width: 50,
//                 height: 50,
//                 color: Colors.white,
//               ),
//             ]);
//       },
//     );
//   }
// }
