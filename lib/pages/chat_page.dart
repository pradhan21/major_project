import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:advisor_ui/json/budget_json.dart';
import 'package:advisor_ui/json/day_month.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../api_data/limitdata.dart';


class BudgetPage extends StatefulWidget {

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with TickerProviderStateMixin {
  late final TabController _maintabController;
  int activeDay = 3;
  TextEditingController _amountController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  List<categorydata> categoriesdata = [];
  @override
  void initState() {
    amountFocusNode.addListener;
    fetchCategorydata($widget.accessToken);
    _maintabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  void dispose() {
    amountFocusNode.removeListener;
    _maintabController.dispose();
    super.dispose();
  }

     Future<List<categorydata>> fetchCategorydata(String accessToken) async {
    final url = 'http://127.0.0.1:8000/limit/categoryLimitView/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['filtered'];
      // print("Expenses Categories:__________" + categoriesData.toString());
      

      for (var categoryData in categoriesData) {
        categoriesdata.add(categorydata.fromJson(categoryData));
        // print(expcategories);
      }

      return categoriesdata;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: getBody(),
    );
  }

Widget getBody() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(
            top: 50, right: 20, left: 20, bottom:0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Text(
                  "Budget",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold, 
                      color: white),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Expanded(
        child: tabbody(),
      ),
    ],
  );
}

Widget tabbody() {
  var size = MediaQuery.of(context).size;
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(30), // Adjust the height as needed
            child: TabBar(
              indicatorColor: Colors.black,
              tabs: <Widget>[
                Tab(
                  text: 'Custom Budget',
                  icon: Icon(Icons.speed_rounded),
                ),
                Tab(
                  text: 'Overall Budget',
                  icon: Icon(Icons.wallet),
                ),
              ],
              controller: _maintabController,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _maintabController,
              children: [
                // Body of the 'Custom Budget' tab
                Container(
                  color: Color.fromARGB(255, 233, 227, 227), // Replace with your custom content
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 35),
                      child: Column(
                          children: List.generate(budget_json.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: grey.withOpacity(0.01),
                                    spreadRadius: 10,
                                    blurRadius: 3,
                                    // changes position of shadow
                                  ),
                                ]),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 25, right: 25, bottom: 25, top: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget_json[index]['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Color(0xff67727d).withOpacity(0.6)),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            budget_json[index]['price'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text(
                                              budget_json[index]['label_percentage'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color:
                                                      Color(0xff67727d).withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          "\$5000.00",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Color(0xff67727d).withOpacity(0.6)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        width: (size.width - 40),
                                        height: 4,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Color(0xff67727d).withOpacity(0.1)),
                                      ),
                                      Container(
                                        width: (size.width - 40) *
                                            budget_json[index]['percentage'],
                                        height: 4,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: budget_json[index]['color']),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
                    ),
                  ),
                ),
                // Body of the 'Overall Budget' tab
                Container(
                  color: Color.fromARGB(255, 233, 227, 227), // Replace with your custom content
                  child: Center(
                    child: Text('Overall Budget Tab Content'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


}
