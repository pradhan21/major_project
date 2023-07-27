import 'package:advisor_ui/pages/root_app.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../core/route/app_route_name.dart';
class SettingsPage extends StatefulWidget{
  final String accessToken;
  SettingsPage({required this.accessToken});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool valueNotifyl= false;
  bool valueNotify2=false;
  bool valueNotify3=false;
  
onChangeFunction1(bool newValue1) {
  setState(() {
    valueNotifyl = newValue1;
    
  });
}


    onChangeFunction2(bool newValue2){
    setState(() {
      valueNotify2=newValue2;
    });
  }

    onChangeFunction3(bool newValue3){
    setState(() {
      valueNotify3=newValue3;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Settings'),),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  children: [
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Account",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, thickness: 1),
                    SizedBox(height: 10),
                    buildAccountOption(context, "Change Password"),
                    buildAccountOption(context, "Content Settings"),
                    buildAccountOption(context, "Social"),
                    buildAccountOption(context, "Language"),
                    buildAccountOption(context, "Privacy and Security"),
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Icon(Icons.volume_up_outlined,color: Colors.blue,),
                        SizedBox(width: 10),
                        Text("Notifications", style:TextStyle(
                          fontSize: 22,fontWeight: FontWeight.bold
                        ))
                      ],
                    ),
                    Divider(height: 20, thickness: 1),
                    SizedBox(height:10),
                    buildNotificationOption("Theme Dark", valueNotifyl, onChangeFunction1),
                    buildNotificationOption("Mute notifications", valueNotify2, onChangeFunction2),
                    buildNotificationOption("Acount Active", valueNotify3, onChangeFunction3),

                  ],
                ),
              ),
            ),
            // Add another container for a new section
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   child: Column(
            //     children: [
            //       Text(
            //         "Modes",
            //         style: TextStyle(
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       // Add more widgets as per your requirements
            //       Divider(height: 20, thickness: 1),
            //       SizedBox(height: 10),
            //       buildModesOption(context, "Change Password"),
            //       buildModesOption(context, "Content Settings"),
            //       buildModesOption(context, "Social"),
            //       buildModesOption(context, "Language"),
            //       buildModesOption(context, "Privacy and Security"),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildAccountOption(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        // Add your logic here
        showDialog(context: context, builder: (BuildContext context ){
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("option 1"),
                Text("option 1"),
              ],
            ),
            actions: [
              TextButton(
                onPressed:(){
                  Navigator.of(context).pop();
                },
                 child: Text("close")
                 )
            ],
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: black,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
 Padding buildNotificationOption(String title, bool value, Function onChangedmethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(
              fontSize: 20,
                fontWeight: FontWeight.normal,
                color: black,
          )),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              activeColor: Colors.blue,
              trackColor: Colors.grey,
              value: value,
              onChanged:(bool newValue){
                onChangedmethod(newValue);
              }
            )
          )
        ]),
      );  
}

}
  

    
 