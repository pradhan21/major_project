import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:advisor_ui/json/budget_json.dart';
import 'package:advisor_ui/json/day_month.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:progress_indicator/progress_indicator.dart';
import '../api_data/limitdata.dart';
import 'dart:async';
class BudgetPage extends StatefulWidget {
  final String accessToken;
  BudgetPage({required this.accessToken});
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with TickerProviderStateMixin {
  late final TabController _maintabController;
  int activeDay = 3;
  TextEditingController _amountController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  List<categorydata> categorydatas = [];
  List<overalldata> overalldatas = [];
  List<categorylimit> categorylimits = [];
  List<overalllimit> overalllimits = [];

  late double overallpercent = 0;
  late double overall_limits = 0;
  late double expense_total = 0;
  late double limit_left = 0;

  @override
  void initState() {
    super.initState();
    amountFocusNode.addListener;
    // Timer.periodic(Duration(seconds: 2), (_) {fetchdata(widget.accessToken);
    // fertchoveralldata(widget.accessToken);
    // });
    fetchdata(widget.accessToken);
    fertchoveralldata(widget.accessToken);
    fertchcategorydata(widget.accessToken);
    _maintabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  void dispose() {
    amountFocusNode.removeListener;
    _maintabController.dispose();
    super.dispose();
  }

// Future<List<overalldata>> fertchoveralldata(String accessToken) async{
//   final url = 'http://10.0.2.2:8000/limit/OverallLimitView/';

//     final response = await http.get(Uri.parse(url), headers: {
//       'Authorization': 'Bearer $accessToken',
//     });

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       final categoriesData = jsonData;
//       print("overall data : $categoriesData");
//       List<overalldata> overalldatas = [];
//       for(var data in categoriesData){
//         overalldatas.add(overalldata.fromJson(data));
//       }

//       for(var data in overalldatas){
//           print('Category Name: ${data.month}');
//         print('Category Limit: ${data.overall_total}');

//       }
//       return overalldatas;
//     }
//     else{
//       throw Exception(
//           'Failed to fetch categories data. Status code: ${response.statusCode}');
//     }
// }
  Future<List<overalldata>> fertchoveralldata(String accessToken) async {
    final url = 'http://10.0.2.2:8000/limit/OverallLimitView/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print(jsonData);
      
      if (jsonData is Map<String, dynamic>) {
        // Convert the JSON object to a list containing a single element
        final categoriesData = [jsonData];
        List<overalldata> overalldatas = [];
        for (var data in categoriesData) {
          overalldatas.add(overalldata.fromJson(data));
        }

        for (var data in overalldatas) {
          // print('Category Name: ${data.month}');
          // print('Category Limit: ${data.overall_total}');
          overallpercent = data.percent;
          overall_limits = data.overall_limit;
          expense_total = data.overall_total;
          limit_left = data.limit_left;
        }
        return overalldatas;
      } else {
        throw Exception('Invalid API response format');
      }
    } else {
      throw Exception(
          'Failed to fetch categories data. Status code: ${response.statusCode}');
    }
  }

  Future<List<categorydata>> fertchcategorydata(String accessToken) async {
    final url = 'http://10.0.2.2:8000/limit/categoryLimitView/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print(jsonData);
      // List<categorydata> categorydatas = [];
      if (jsonData is List<dynamic>) {
        // Check if the response is a list

        for (var data in jsonData) {
          // Iterate through the list of objects
          categorydatas.add(categorydata.fromJson(data));
        }
        // for (var data in categorydatas) {
        //   print('Category Name: ${data.category_name}');
        //   print('Category Limit: ${data.category_limit}');
        //   print('Category Total: ${data.category_expenses_total}');
        //   print('------------------------');
        // }
        return categorydatas;
      } else {
        throw Exception('Invalid API response format');
      }
    } else {
      throw Exception(
          'Failed to fetch categories data. Status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchdata(String accessToken) async {
    final url = 'http://10.0.2.2:8000/limit/limit/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData;
      // print(categoriesData);
      List<categorydata> categoriesdata = [];
      List<categorylimit> categorylimits = [];
      List<overalllimit> overalllimits = [];

      for (var categoryData in categoriesData) {
        final overallLimit = categoryData['overall_limit']?.toDouble() ?? 0.0;
        final expensesCategory = categoryData['expenses_Category'];
        final categoryLimit = categoryData['category_limit']?.toDouble() ?? 0.0;

        if (overallLimit != 0 && expensesCategory == null) {
          overalllimits.add(overalllimit.fromJson(categoryData));
        }
        if (overallLimit == 0 && expensesCategory != null) {
          categorylimits.add(categorylimit.fromJson(categoryData));
        }

        //else {
        //   categoriesdata.add(categorydata.fromJson(categoryData));
        // }
      }

      // Print the categories data
      // for (var data in categoriesdata) {
      //   print('Category Name: ${data.category_name}');
      //   print('Category Limit: ${data.category_limit}');
      //   print('Category Total: ${data.category_total}');
      //   print('------------------------');
      // }

      // Print the category limits data
      // for (var data in categorylimits) {
      //   print('Category Name: ${data.category_name}');
      //   print('Category Limit: ${data.category_limit}');
      //   print('------------------------');
      // }

      // Print the overall limits data
      for (var data in overalllimits) {
        print('Overall Limit: ${data.overall_limit}');
        print('------------------------');
      }

      return [categoriesdata, categorylimits, overalllimits];
    } else {
      throw Exception(
          'Failed to fetch categories data. Status code: ${response.statusCode}');
    }
  }

  Future<void> updateCategorydata(int cat_id, double amount) async {
    final url = 'http://10.0.2.2:8000/limit/limit/$cat_id/';

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'category_limit': amount}),
    );

    if (response.statusCode == 200) {
      // Category data updated successfully
      print('Category data updated');
    } else {
      // Error updating category data
      print(
          'Failed to update category data. Status code: ${response.statusCode}');
    }
  }

  Future<void> deletecategorydata(int cat_id) async {
    final url = 'http://10.0.2.2:8000/limit/limit/$cat_id/';

    // Remove the deleted item from the local list

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Category data deleted successfully
      print('Category data deleted');
      setState(() {
        categorylimits.removeWhere((item) => item.cat_id == cat_id);
      });
    } else {
      // Error deleting category data
      print(
          'Failed to delete category data. Status code: ${response.statusCode}');

      // If deletion fails, add the item back to the local list
    }
  }

  Future<void> updateoveralldata(int cat_id, double amount) async {
    final url = 'http://10.0.2.2:8000/limit/limit/$cat_id/';

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'overall_limit': amount}),
    );

    if (response.statusCode == 200) {
      // Category data updated successfully
      print('Category data updated');
    } else {
      // Error updating category data
      print(
          'Failed to update category data. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteoveralldata(int cat_id) async {
    final url = 'http://10.0.2.2:8000/limit/limit/$cat_id/';

    // Remove the deleted item from the local list

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken} ',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Category data deleted successfully
      print('Category data deleted');
      setState(() {
        overalllimits.removeWhere((item) => item.cat_id == cat_id);
      });
    } else {
      // Error deleting category data
      print(
          'Failed to delete category data. Status code: ${response.statusCode}');

      // If deletion fails, add the item back to the local list
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
    return FutureBuilder<List<dynamic>>(
      future: fetchdata(widget.accessToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<dynamic> data = snapshot.data!;
          List<categorydata> categoriesdata = data[0];
          List<categorylimit> categorylimits = data[1];
          List<overalllimit> overalllimits = data[2];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 50,
                  right: 20,
                  left: 20,
                  bottom: 0,
                ),
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
                            color: white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: tabbody(categorylimits, overalllimits),
              ),
            ],
          );
        }
      },
    );
  }

  Widget tabbody(
    List<categorylimit> categorylimits,
    List<overalllimit> overalllimits,
  ) {
    var size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(30),
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
                  Tab(
                    text: 'Budget Stats',
                    icon: Icon(Icons.query_stats_outlined),
                  )
                ],
                onTap: (index) async {
                  // Handle the tap event here
                  if (index == 2) {
                    await fertchoveralldata(widget.accessToken);
                  }
                },
                controller: _maintabController,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _maintabController,
                children: [
                  Container(
                    color: Color.fromARGB(255, 233, 227, 227),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 35),
                      child: ListView.builder(
                        itemCount: categorylimits.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              editCategoryPopup(context, categorylimits[index]);
                            },
                            child: Padding(
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
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 25, right: 25, bottom: 25, top: 25),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        categorylimits[index].category_name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Color(0xff67727d)
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                categorylimits[index]
                                                    .category_limit
                                                    .toDouble()
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(
                                              categorylimits[index]
                                                  .category_limit
                                                  .toDouble()
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                                color: Color(0xff67727d)
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Color.fromARGB(255, 233, 227, 227),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 35),
                      child: ListView.builder(
                        itemCount: overalllimits.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              editOverallPopup(context, overalllimits[index]);
                            },
                            child: Padding(
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
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 25, right: 25, bottom: 25, top: 25),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Overall Budget",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Color(0xff67727d)
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                overalllimits[index]
                                                    .overall_limit
                                                    .toDouble()
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(
                                              overalllimits[index]
                                                  .overall_limit
                                                  .toDouble()
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                                color: Color(0xff67727d)
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                      color: Color.fromARGB(255, 233, 227, 227),
                      child: Column(children: [
                        // const SizedBox(height: 50),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromARGB(255, 192, 189, 189),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 170,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Stack(
                                        // Added a Stack widget to layer the circular indicator and the image
                                        children: [
                                          RotatedBox(
                                            quarterTurns: -2,
                                            child: CircularPercentIndicator(
                                              circularStrokeCap:
                                                  CircularStrokeCap.round,
                                              backgroundColor: green,
                                              radius: 85.0,
                                              lineWidth: 6.0,
                                              percent: overallpercent / 100,
                                              progressColor: red,
                                            ),
                                          ),
                                          Positioned(
                                            top: 35,
                                            left: 17,
                                            bottom: 26,
                                            child: Container(
                                              width: 130,
                                              height: 130,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    "Overall Limit",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                      overall_limits
                                                          .toDoubleStringAsFixed(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                      // color: blue,
                                      width: 200,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Overall Limit",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                    overall_limits
                                                        .toDoubleStringAsFixed(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 18,
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Expense Total",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                    expense_total
                                                        .toDoubleStringAsFixed(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 18,
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Amount Spent(%)",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                    overallpercent
                                                        .toDoubleStringAsFixed()+"%",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 18,
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Budget Left",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                    limit_left
                                                        .toDoubleStringAsFixed(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 18,
                                                    ))
                                              ],
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            )),
                        // const SizedBox(height: 50),
                        Expanded(
                          // Use Expanded here
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 20),
                              child: ListView.builder(
                                itemCount: categorydatas.length,
                                itemBuilder: (context, index) {
                                  print("Building item at index $index");
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            categorydatas[index].category_name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                          ),
                                          // Text(
                                          //   categorydatas[index]
                                          //       .category_limit_used
                                          //       .toStringAsFixed(2),
                                          //   style: TextStyle(
                                          //     fontWeight: FontWeight.w500,
                                          //     fontSize: 18,
                                          //   ),
                                          // ),
                                          Text(
                                            categorydatas[index]
                                                .category_limit
                                                .toStringAsFixed(2),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      SizedBox(height: 10),
                                      // Tooltip(
                                      //   message:
                                      //       '${(categorydatas[index].category_limit_used_percent).toStringAsFixed(2)}%',
                                      //   child: LinearProgressIndicator(
                                      //     backgroundColor: green,
                                      //     valueColor:
                                      //         new AlwaysStoppedAnimation<Color>(
                                      //             Colors.red),
                                      //     value: categorydatas[index]
                                      //             .category_limit_used_percent /
                                      //         100,
                                      //   ),
                                      // ),
                                      BarProgress(
                                        percentage: categorydatas[index].category_limit_used_percent ,
                                        backColor: Colors.grey,
                                        gradient: LinearGradient(
                                            colors: [Colors.blue, Colors.red]),
                                        showPercentage: true,
                                        textStyle: TextStyle(
                                            color: const Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                                        stroke: 10,
                                        round: true,
                                      ),
                                      SizedBox(height: 40),
                                    
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ]))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editCategoryPopup(
      BuildContext context, categorylimit category) async {
    final TextEditingController _amountController = TextEditingController(
      text: category.category_limit.toDouble().toStringAsFixed(2),
    );
    double editedTotal = category.category_limit.toDouble();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                category.category_name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                    onChanged: (value) {
                      setState(() {
                        editedTotal = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () async {
                        await updateCategorydata(category.cat_id, editedTotal);
                        Navigator.pop(context); // Close the popup
                      },
                      child: Text('Update'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        deletecategorydata(category.cat_id);
                        Navigator.pop(context); // Close the popup
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> editOverallPopup(
      BuildContext context, overalllimit overall) async {
    final TextEditingController _amountController = TextEditingController(
      text: overall.overall_limit.toDouble().toStringAsFixed(2),
    );
    double editedTotal = overall.overall_limit.toDouble();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Overall Budget',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                    onChanged: (value) {
                      setState(() {
                        editedTotal = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        updateoveralldata(overall.cat_id, editedTotal);
                        Navigator.pop(context); // Close the popup
                      },
                      child: Text('Update'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        deleteoveralldata(overall.cat_id);
                        Navigator.pop(context); // Close the popup
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
