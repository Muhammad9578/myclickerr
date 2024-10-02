import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({required this.url, Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  var loadingPercentage = 0;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('${widget.url}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        themeColor: AppColors.orange,
        title: 'Buy Product',
        action: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if (await controller.canGoBack()) {
                await controller.goBack();
              } else {
                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(
                  const SnackBar(
                      duration: Duration(seconds: 1),
                      backgroundColor: AppColors.red,
                      content: Text('No back history item')),
                );
                return;
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if (await controller.canGoForward()) {
                await controller.goForward();
              } else {
                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                      // behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                      backgroundColor: AppColors.red,
                      //    behavior: SnackBarBehavior.floating,
                      //    shape: RoundedRectangleBorder(
                      //      borderRadius: BorderRadius.circular(24),
                      //    ),
                      //    margin: EdgeInsets.only(
                      //        bottom: MediaQuery.of(context).size.height - 80,
                      //        right: 20,
                      //        left: 20),
                      content: Text('No forward history item')),
                );
                return;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
                value: loadingPercentage / 100.0,
                backgroundColor: Color(0xffc9c9c9),
                color: AppColors.orange),
        ],
      ),
    );
  }
}
