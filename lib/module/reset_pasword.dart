import 'dart:convert';

import 'package:advisor_ui/core/route/app_route_name.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_color.dart';
import '../theme/colors.dart';

class resetpasswordPage extends StatefulWidget {
  @override
  _resetpasswordPageState createState() => _resetpasswordPageState();
}

class _resetpasswordPageState extends State<resetpasswordPage> {
  TextEditingController emailController = TextEditingController();

  Future<void> resetpassword(String email) async {
    print(email);
    final url = Uri.parse('http://10.0.2.2:8000/api/user/resetpasswordemail/'); // Replace with your API URL
    final headers = { 'Content-type': 'application/json','Accept': 'application/json'};
    final body = jsonEncode({
      'email': email,
    });

    final response = await http.post(url,headers: headers ,body: body);

    if (response.statusCode == 200) {
      // Budget created successfully
      // You can perform any additional actions here
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset!!'),
            content: Text('An Email has been sent to the corresponding Email.'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: button),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, AppRouteName.home);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Failed to create budget
      // Handle the error accordingly
      print('Failed to send email. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 54, 54),
        title: Text('Reset Passord'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 68, 66, 66),
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
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 68, 66, 66),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                child: Row(
                              children: [
                                Text(
                                  "Enter Your Email to reset the password:",
                                  style: TextStyle(
                                      color: white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email",
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 64,
                              child: ElevatedButton(
                                onPressed: () async{
                                  await resetpassword(emailController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: button,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text("Confirm Email"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]))),
      ),
    );
  }
}
