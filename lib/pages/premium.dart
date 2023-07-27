import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/route/app_route_name.dart';
import '../theme/colors.dart';
import 'webviewpay.dart';
import 'package:http/http.dart' as http;

class PremiumPage extends StatefulWidget {
    final String accessToken;
  PremiumPage({required this.accessToken});
  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  String selectedPackage = '';
  late String url;

  void selectPackage(String package) {
    setState(() {
      selectedPackage = package;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 54, 54),
        title: Text('Premium Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  ' Premium',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text(
                    'Historical Data Access',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text(
                    'Add Free Services',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text(
                    'Export to Excel Reports',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text(
                    'Machine Learning Services',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  // onPressed: () {
                  //   Navigator.pushNamed(
                  //     context,
                  //     AppRouteName.payment,
                  //   );
                  // },
                  onPressed: () async {
                    if (await checkout() == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebViewPayment(url: url)),
                      );
                    }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => WebViewPayment()),
                    // );
                  },
                  child: Text('Package 1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: button,
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkout() async {
    //* ------- checkout according to the user this creates a order to the order table a changes the payment status to paid ---------->//*
    try {
      Map<String, dynamic> body = {
        "order": [
          {"name": "Premium", "product": 11, "quantity": 1, "price": 99}
        ]
      };
      var response_put = await http.post(
        Uri.parse('http://10.0.2.2:8000/order/create-checkout-session/'),
        headers: {
          'Authorization':
              'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // print("Response body: ${response_put.body}\n\n\n");
      Map<String, dynamic> decodedJson = jsonDecode(response_put.body);
      Map<String, dynamic> session = decodedJson['session'];
      url = session['url'];
      print("URL: $url");

      // print(response_put.body);
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }
}
