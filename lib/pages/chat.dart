import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_tawk/flutter_tawk.dart';
import '../api_data/userProfile.dart';
import '../theme/colors.dart';

class ChatScreen extends StatefulWidget {
  final String accessToken;
  ChatScreen({required this.accessToken});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String fname = '';
  String lname = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData(widget.accessToken);
  }

  @override
  List<UserProfile> profile = [];
  Future<UserProfile> _fetchProfileData(String accessToken) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/user/profile/');
    final headers = {'Authorization': 'Bearer $accessToken'};

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Access the user profile data directly from the responseData
      final userProfile = UserProfile.fromJson(responseData);

      // Use the userProfile object as needed
      fname = userProfile.fName;
      lname = userProfile.lName;
      email = userProfile.email;
      print("email: ${userProfile.email}");
      print("fname: ${userProfile.fName}");
      print("lname: ${userProfile.lName}");
      print(fname);
      print(email);
      print(lname);
      return userProfile;
    } else {
      throw Exception(
          'Failed to fetch profile data. Status code: ${response.statusCode}');
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: black,
                height: 150,
                child: Padding(
                  padding: EdgeInsets.only(top: 55, left: 15, right: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tech Support",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 600, // Set a fixed height for the Tawk widget
                child: Tawk(
                  directChatLink:
                      'https://tawk.to/chat/64ace0dacc26a871b027a065/1h51kslp4',
                  visitor: TawkVisitor(
                    name: '${fname} ${lname}',
                    email: '${email}',
                  ),
                  onLoad: () {
                    print('Hello World!');
                  },
                  onLinkTap: (String url) {
                    print(url);
                  },
                  placeholder: const Center(
                    child: Text('Loading...'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
