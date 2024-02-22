import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_test/my_web_view.dart';

void main() {
  // 위젯 바인딩 초기화, 웹뷰와 플러터 상호작용 위한 것
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;
  var value = 0;
  @override
  void initState() {
    controller = WebViewController()
      ..setBackgroundColor(const Color(0xFF3CC1F2))
      ..loadRequest(Uri.parse('http://erp_dev.enjoysoft.net'))
      ..addJavaScriptChannel(
        'app2web',
        onMessageReceived: (JavaScriptMessage message) {
          // 받으면 스낵바로 띄워줌
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.message),
            ),
          );
          if (value == 0) {
            value++;
            // 받았으니 자바스크립트 실행
            controller.runJavaScript('appToWeb("hihihi")');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message.message),
              ),
            );
          }
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EnjoySoftTabling',
          style: TextStyle(color: Color(0xEEEEEEEE)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF001450),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("뒤로 갈 페이지가 없습니다.")),
                    );
                    return;
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (await controller.canGoForward()) {
                    await controller.goForward();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("앞으로 갈 페이지가 없습니다.")),
                    );
                    return;
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.replay),
                onPressed: () {
                  controller.reload();
                },
              )
            ],
          )
        ],
      ),
      body: MyWebView(
        controller: controller,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: const Text(
  //           'EnjoySoftTabling',
  //           style: TextStyle(color: Color(0xFFEEEEEE)),
  //         ),
  //         centerTitle: true,
  //         backgroundColor: const Color(0xFF001450),
  //       ),
  //       body: SafeArea(
  //           child: WillPopScope(
  //               onWillPop: () => _goBack(context),
  //               child: WebViewWidget(
  //                 controller: controller,
  //               )
  //               // child: WebViewWidget(controller: controller),
  //               )));
  // }

  // Future<bool> _goBack(BuildContext context) async {
  //   if (await controller.canGoBack()) {
  //     controller.goBack();
  //     return Future.value(false);
  //   } else {
  //     if (await showExitPopup()) {
  //       return Future.value(true);
  //     } else {
  //       return Future.value(false);
  //     }
  //   }
  // }

  // Future<bool> showExitPopup() async {
  //   return await showDialog(
  //         //show confirm dialogue
  //         //the return value will be from "Yes" or "No" options
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('종료'),
  //           content: const Text('정말 종료하시겠습니까?'),
  //           actions: [
  //             ElevatedButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               //return false when click on "NO"
  //               child: const Text('아니오'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               //return true when click on "Yes"
  //               child: const Text('예'),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false; //if showDialouge had returned null, then return false
  // }
  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: () {
  //       var future = controller.canGoBack();
  //       future.then((canGoBack) => {
  //             if (canGoBack)
  //               {controller.goBack()}
  //             else
  //               {
  //                 showDialog(
  //                   context: context,
  //                   builder: (context) => AlertDialog(
  //                     title: Text('앱 종료'),
  //                     content: Text('앱이 종료됩니다.'),
  //                     actions: [
  //                       TextButton(
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                         child: Text('아니오'),
  //                       ),
  //                       TextButton(
  //                         onPressed: () {
  //                           SystemNavigator.pop();
  //                         },
  //                         child: Text('예'),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               }
  //           });
  //       return Future.value(false);
  //     },
  //     child: SafeArea(
  //       child: Scaffold(
  //         appBar: AppBar(
  //           title: const Text(
  //             'EnjoySoftTabling',
  //             style: TextStyle(color: Color(0xFFEEEEEE)),
  //           ),
  //           centerTitle: true,
  //           backgroundColor: const Color(0xFF001450),
  //         ),
  //         body: WebViewWidget(controller: controller),
  //       ),
  //     ),
  //   );
  // }
}
