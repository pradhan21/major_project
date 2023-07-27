import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class SubscriptionView extends StatefulWidget {
  // final String accessToken;
  // SubscriptionView({required this.accessToken});

  @override
  _SubscriptionViewState createState() => _SubscriptionViewState();
}

// class _SubscriptionViewState extends State<SubscriptionView> {
//   final Completer<WebViewController> _controller =
//       Completer<WebViewController>();
//   late final Future<String> url;

//   @override
//   void initState() {
//     super.initState();
//     manage();
//   }

//   Future<void> manage() async {
//     try {
//       final response =
//           await http.get(Uri.parse('http://10.0.2.2/order/customer-portal/'));
//       Map<String, dynamic> decodedJson = jsonDecode(response.body);
//       Map<String, dynamic> session = decodedJson['session'];
//       setState(() {
//         url = session['url'];
//       });
//       print("URL: $url");
//     } catch (e) {
//       print("Customer_portal: $e");
//       // print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Customer Portal"),
//       ),
//       body: WebView(
//         initialUrl: url,
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller.complete(webViewController);
//         },
//         navigationDelegate: (NavigationRequest request) {
//           if (request.url == 'http://10.0.2.2:8000/') {
//             // replace with your success url
//             Navigator.of(context).pop(); // close the WebView
//             return NavigationDecision
//                 .prevent; // prevent the navigation to the success page
//           }
//           return NavigationDecision.navigate;
//         },
//       ),
//     );
//   }
// }
// import 'dart:convert';

class _SubscriptionViewState extends State<SubscriptionView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late final Future<String> urlFuture;

  @override
  void initState() {
    super.initState();
    urlFuture = manage();
  }

  Future<String> manage() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/order/customer-portal/'));
      Map<String, dynamic> decodedJson = jsonDecode(response.body);
      Map<String, dynamic> session = decodedJson['session'];
      return session['url'];
    } catch (e) {
      print("Customer_portal: $e");
      // return a default url in case of error
      return 'https://default-url.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Portal"),
      ),
      body: FutureBuilder<String>(
        future: urlFuture,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading spinner while waiting for url
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return WebView(
              initialUrl: snapshot.data,
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
            );
          }
        },
      ),
    );
  }
}
