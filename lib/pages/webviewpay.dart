// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewPayment extends StatefulWidget {
//   final String url;
//   WebViewPayment({required this.url});

//   @override
//   _WebViewPaymentState createState() => _WebViewPaymentState();
// }

// class _WebViewPaymentState extends State<WebViewPayment> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     String url = widget.url;
//     if (!url.startsWith('http://') && !url.startsWith('https://')) {
//       url = 'http://$url'; // or 'https://$url', depending on your requirements
//     }
//     _controller = WebViewController()
//       ..loadRequest(
//         Uri.parse(url),
//       )
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url == 'http://10.0.2.2:8000/') {
//               // replace with your success url
//               Navigator.of(context).pop(); // close the WebView
//               return NavigationDecision
//                   .prevent; // prevent the navigation to the success page
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment"),
//       ),
//       body: WebViewWidget(
//         controller: _controller,
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPayment extends StatefulWidget {
  final String url;
  WebViewPayment({required this.url});

  @override
  _WebViewPaymentState createState() => _WebViewPaymentState();
}

class _WebViewPaymentState extends State<WebViewPayment> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url == 'http://10.0.2.2:8000/') {
            // replace with your success url
            Navigator.of(context).pop(); // close the WebView
            return NavigationDecision
                .prevent; // prevent the navigation to the success page
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
