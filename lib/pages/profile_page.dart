import 'dart:convert';

import 'package:advisor_ui/pages/root_app.dart';
import 'package:advisor_ui/pages/setting_page.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:advisor_ui/api_data/userProfile.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;
  final dynamic responseData;
  ProfilePage({required this.accessToken, required this.responseData});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late var Token;
  late Future<UserProfile> _profileFuture;
  TextEditingController _email = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController password = TextEditingController();
  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() {
    final url = Uri.parse('http://10.0.2.2:8000/api/user/profile/');
    final headers = {'Authorization': 'Bearer ${widget.accessToken}'};

    _profileFuture = http.get(url, headers: headers).then((response) {
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return UserProfile.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch profile data');
      }
    }).catchError((error) {
      throw Exception('An error occurred: $error');
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userProfile = snapshot.data!;
            var size = MediaQuery.of(context).size;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 450, // Set the desired height for the top container
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.blue, Colors.red],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      right: 20,
                      left: 20,
                      bottom: 25,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Profile",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(AntDesign.arrowleft),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RootApp(
                                      accessToken: widget.accessToken,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                        Column(
                          children: [
                            Container(
                              width: (size.width - 40) * 0.4,
                              child: Container(
                                child: Stack(
                                  children: [
                                    // Wrap CircularPercentIndicator with SizedBox
                                    SizedBox(
                                      height: 170, // Set the desired height
                                      child: RotatedBox(
                                        quarterTurns: -2,
                                        child: CircularPercentIndicator(
                                          circularStrokeCap: CircularStrokeCap.round,
                                          backgroundColor: grey.withOpacity(0.3),
                                          radius: 85.0,
                                          lineWidth: 6.0,
                                          percent: 0.53,
                                          progressColor: primary,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 35,
                                      left: 5,
                                      bottom: 26,
                                      child: Container(
                                        width: 130,
                                        height: 130,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              "https://images.unsplash.com/photo-1531256456869-ce942a665e80?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTI4fHxwcm9maWxlfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${userProfile.fName} ${userProfile.lName}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 28),
                                        Icon(Icons.email_outlined),
                                        SizedBox(width: 8),
                                        Text(
                                          "${userProfile.email}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: black.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 108),
                                        Icon(Icons.phone),
                                        SizedBox(width: 8),
                                        Text(
                                          "${userProfile.phone}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: black.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Color.fromARGB(255, 233, 227, 227),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Username:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color:black,
                            ),
                          ),
                           SizedBox(height: 6),
                          Text( 
                            "${userProfile.username}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color(0xff67727d),
                            ),),
                          SizedBox(height: 20),
                          Text(
                            "Email:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: black,
                            ),
                          ),
                           SizedBox(height: 6),
                          Text( 
                            "${userProfile.email}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color(0xff67727d),
                            ),),
                          SizedBox(height: 20),
                          Text(
                            "Date of birth:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: black,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "${userProfile.dateOfBirth}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color(0xff67727d),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Phone Number:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: black,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "${userProfile.phone}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color(0xff67727d),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}