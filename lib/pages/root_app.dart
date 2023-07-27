import 'dart:convert';
import 'package:advisor_ui/pages/budget_page.dart';
import 'package:advisor_ui/pages/chat.dart';
import 'package:advisor_ui/pages/create_budge_page.dart';
import 'package:advisor_ui/pages/daily_page.dart';
import 'package:advisor_ui/pages/note.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import '../api_data/limitdata.dart';
import '../api_data/userProfile.dart';
import '../core/route/app_route_name.dart';
import '../logout/logout.dart';
import '../module/home/presentation/home_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class RootApp extends StatefulWidget {
  final String accessToken;
  RootApp({required this.accessToken});
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> with WidgetsBindingObserver {
  bool isKeyboardVisible = false;
  dynamic responseData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _amountController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  List<ExpCategory> expcategories = [];
  String fname = '';
  String lname = '';
  String email = '';
  List<UserProfile> profile = [];
  ExpCategory? selectedCategory;
  List<categorydata> categoriesdata = [];
  List<overalldata> overalldatas = [];
  List<categorylimit> categorylimits = [];
  List<overalllimit> overalllimits = [];
  int pageIndex = 0;
  late List<Widget> pages;
  // List<Widget> pages = [
  //   DailyPage(),
  //   StatsPage(),
  //   BudgetPage(),
  //   ChatScreen(),
  //   CreatBudgetPage(accessToken: widget.accessToken),
  // ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _fetchProfileData(widget.accessToken);
    fetchexpCategories(widget.accessToken);
    // Initialize the pages list after accessing the widget.accessToken
    pages = [
      DailyPage(accessToken: widget.accessToken),
      NotePage(accessToken: widget.accessToken),
      BudgetPage(accessToken: widget.accessToken),
      ChatScreen(accessToken: widget.accessToken),
      CreatBudgetPage(accessToken: widget.accessToken),
    ];
    amountFocusNode.addListener;
    // fetchdata(widget.accessToken);
  }

  @override
  void dispose() {
    amountFocusNode.removeListener;
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final keyboardHeight = WidgetsBinding.instance!.window.viewInsets.bottom;
    setState(() {
      isKeyboardVisible = keyboardHeight > 0;
    });
  }

  Future<bool> validateToken(String accessToken) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/user/validate/');
    final headers = {'Authorization': 'Bearer $accessToken'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final bool isValid = responseData['valid'];
      // print("token validate-----" + responseData);
      return isValid;
    } else {
      throw Exception('Failed to validate token');
    }
  }

//  Future<List<dynamic>> fetchdata(String accessToken) async {
//     final url = 'http://10.0.2.2:8000/limit/limit/';

//     final response = await http.get(Uri.parse(url), headers: {
//       'Authorization': 'Bearer $accessToken',
//     });

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       final categoriesData = jsonData;
//       // print("root data limit: $categoriesData");
//       List<categorydata> categoriesdata = [];
//       List<categorylimit> categorylimits = [];
//       List<overalllimit> overalllimits = [];

//       for (var categoryData in categoriesData) {
//         final overallLimit = categoryData['overall_limit']?.toDouble() ?? 0.0;
//         final expensesCategory = categoryData['expenses_Category'];
//         final categoryLimit = categoryData['category_limit']?.toDouble() ?? 0.0;

//         if (overallLimit != 0 && expensesCategory == null) {
//           overalllimits.add(overalllimit.fromJson(categoryData));
//         } else if (overallLimit == 0 && expensesCategory != null) {
//           categorylimits.add(categorylimit.fromJson(categoryData));
//         } else {
//           categoriesdata.add(categorydata.fromJson(categoryData));
//         }
//       }

//       // // Print the categories data
//       // for (var data in categoriesdata) {
//       //   print('Category Name: ${data.category_name}');
//       //   print('Category Limit: ${data.category_limit}');
//       //   print('Category Total: ${data.category_total}');
//       //   print('------------------------');
//       // }

//       // // Print the category limits data
//       // for (var data in categorylimits) {
//       //   print('Category Name: ${data.category_name}');
//       //   print('Category Limit: ${data.category_limit}');
//       //   print('------------------------');
//       // }

//       // // Print the overall limits data
//       // for (var data in overalllimits) {
//       //   print('Overall Limit: ${data.overall_limit}');
//       //   print('------------------------');
//       // }

//       return [categoriesdata, categorylimits, overalllimits];
//     } else {
//       throw Exception(
//           'Failed to fetch categories data. Status code: ${response.statusCode}');
//     }
//   }

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
      // print("email: ${userProfile.email}");
      // print("fname: ${userProfile.fName}");
      // print("lname: ${userProfile.lName}");
      // print(fname);
      // print(email);
      // print(lname);
      return userProfile;
    } else {
      throw Exception(
          'Failed to fetch profile data. Status code: ${response.statusCode}');
    }
  }

  Future<List<ExpCategory>> fetchexpCategories(String accessToken) async {
    final url = 'http://10.0.2.2:8000/expensesCat/excategory/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['filtered'];
      // print("Expenses Categories:__________" + categoriesData.toString());

      for (var categoryData in categoriesData) {
        expcategories.add(ExpCategory.fromJson(categoryData));
        // print(expcategories);
      }

      return expcategories;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }

Future<void> _createcustomBudget(double amount, int category) async {
  // Check if a limit already exists for the category and user
  if (checkLimitExists(category)) {
    // Limit already exists, show an error message or handle accordingly
    print('Limit already exists for the category');
    return;
  }

  // Continue with creating the new limit
  final url = Uri.parse('http://10.0.2.2:8000/limit/limit/'); // Replace with your API URL

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.accessToken}',
    // Add any required headers
  };

  final body = jsonEncode({
    'category_limit': amount,
    'expenses_Category': category,
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 201) {
    // Budget created successfully
    // You can perform any additional actions here
    print('Budget created successfully');
  } else {
    // Failed to create budget
    // Handle the error accordingly
    print('Failed to create budget. Status code: ${response.statusCode}');
  }
}


bool checkLimitExists(int categoryId) {
  for (var limit in categorylimits) {
    if (limit.category_id == categoryId) {
      return true;
    }
  }
  return false;
}

  Future<void> _createBudget(double amount) async {
    // Check if an overall budget already exists
    // final existingBudget = await _fetchExistingBudget();

    // if (existingBudget != null) {
    //   // Overall budget already exists, show an error message or handle accordingly
    //   print('Overall budget already exists');
    //   return;
    // }

    // Continue with creating the new budget
    final url = Uri.parse(
        'http://10.0.2.2:8000/limit/limit/'); // Replace with your API URL

    final headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'overall_limit': amount,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      // Budget created successfully
      // You can perform any additional actions here
      print('Budget created successfully');
    } else {
      // Failed to create budget
      // Handle the error accordingly
      print('Failed to create budget. Status code: ${response.statusCode}');
    }
  }

  Future<Limits?> _fetchExistingBudget() async {
    final url = Uri.parse(
        'http://10.0.2.2:8000/limit/limit/'); // Replace with your API URL

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
      // Add any required headers
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is List && jsonData.isNotEmpty) {
        // Iterate through the response data and check if an overall limit exists
        for (var item in jsonData) {
          if (item['overall_limit'] != null) {
            // Overall limit found, return the limit object
            return Limits.fromJson(item);
          }
        }
      }
    }

    return null; // No overall budget found
  }

  bool _customTileExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:Color.fromARGB(255, 233, 227, 227),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Carries the details of User
            DrawerHeader(
              padding: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                color: black,

                // borderRadius: BorderRadius.circular(12),
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.black87),
                accountName: Text(
                  "${fname} ${lname}",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text("${email}"),
                // currentAccountPictureSize: Size.square(70),
                currentAccountPicture: Container(
                 
                  decoration: BoxDecoration(shape: BoxShape.circle,color:white),
                  child:ClipOval(
                  // backgroundColor: Colors.white,
                 
                  child:  Image.asset(
                "assets/output-onlinepngtools.png", 
                fit: BoxFit.cover,// This will make the image fit within the container
              ),
                ),)
              ),
            ),

            // ListTile Widget // Provides the options
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushNamed(
                    context,
                    AppRouteName.profile,
                    arguments: {
                      'accessToken': widget.accessToken,
                      'responseData': responseData,
                    },
                  );
                }),

            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Detailed View"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouteName.details,
                  arguments: {
                    'accessToken': widget.accessToken,
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouteName.settings,
                  arguments: {
                    'accessToken': widget.accessToken,
                  },
                );
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Subscription'),
              // subtitle: const Text('Custom expansion arrow icon'),
              trailing: Icon(
                _customTileExpanded
                    ? Icons.arrow_drop_down_circle
                    : Icons.arrow_drop_down,
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.diamond_rounded),
                  title: const Text('Go Premium'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRouteName.premium,
                      arguments: {
                        'accessToken': widget.accessToken,
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.supervised_user_circle_rounded),
                  title: const Text('Customer Portal'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouteName.customer);
                  },
                ),
              ],
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _customTileExpanded = expanded;
                });
              },
            ),
            // ListTile(
            //   leading: const Icon(AntDesign.book),
            //   title: const Text('Note'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.pushNamed(
            //       context,
            //       AppRouteName.note,
            //       arguments: {
            //         'accessToken': widget.accessToken,
            //       },
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () {
                AuthService.logout();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            // Swipe from left to right (open drawer)
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        child: getBody(),
      ),
      bottomNavigationBar: getFooter(),
      floatingActionButton: getFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget getFloatingActionButton() {
    if (pageIndex == 2 && !isKeyboardVisible) {
      return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: button,
        overlayColor: Colors.black,
        overlayOpacity: 0.6,
        children: [
          SpeedDialChild(
            backgroundColor: button,
            child: Icon(Icons.add),
            label: 'Overall Budget',
            onTap: () {
              // Handle add expense action
              _showPopup(context);
            },
          ),
          SpeedDialChild(
            backgroundColor: button,
            child: Icon(Icons.add),
            label: 'Custom Budget',
            onTap: () {
              // Handle add income action
              _showcustomPopup(context);
            },
          ),
        ],
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          selectedTab(4);
        },
        child: Icon(
          Icons.add,
          size: 25,
        ),
        backgroundColor: button,
      );
    }
  }

  void _showcustomPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Custom Budget'),
              content: Text(
                'Set Budget spending for a certain category for the rest of the year',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              actions: [
                TextField(
                  focusNode: amountFocusNode,
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 20),
                DropdownButton<ExpCategory>(
                  value: selectedCategory,
                  onChanged: (ExpCategory? newValue) {
                    setState(() {
                      selectedCategory =
                          newValue; // Update the selectedCategory variable
                    });
                  },
                  items: expcategories.map<DropdownMenuItem<ExpCategory>>(
                    (ExpCategory value) {
                      return DropdownMenuItem<ExpCategory>(
                        value: value,
                        child: Text(value.name),
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () async {
                        final double amount =
                            double.parse(_amountController.text);
                        final int categoryId = selectedCategory?.id ?? 0;

                        // Check if a limit already exists for the category
                        final limitExists = await checkLimitExists(categoryId);

                        if (limitExists) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Limit Already Exists'),
                                content: Text(
                                    'A limit for the selected category already exists.'),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: button),
                                    onPressed: () {
                                      setState(){
                                         _amountController.clear();
                                      };
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pop(); // Close the previous dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Call the API to create the new budget limit
                          _createcustomBudget(amount, categoryId);
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      },
                      child: Text('Create Budget'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
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

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Overall Budget'),
          content: Text(
            'Set Budget spending for the rest of the year',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: black.withOpacity(0.5)),
          ),
          actions: [
            TextField(
              focusNode: amountFocusNode,
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: button),
                  onPressed: () async {
                    final double amount = double.parse(_amountController.text);
                    // final existingBudget = await _fetchExistingBudget();

                    // if (existingBudget != null) {
                    //   showDialog(
                    //     context: context,
                    //     barrierDismissible: false,
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         title: Text('Limit Already Exists'),
                    //         content: Text(
                    //             'A limit for the overall budget already exists.'),
                    //         actions: [
                    //           ElevatedButton(
                    //             style: ElevatedButton.styleFrom(
                    //                 backgroundColor: button),
                    //             onPressed: () {
                    //               Navigator.of(context).pop();
                    //               Navigator.of(context)
                    //                   .pop(); // Close the previous dialog
                    //             },
                    //             child: Text('OK'),
                    //           ),
                    //         ],
                    //       );
                    //     },
                    //   );
                    // } else {
                      _createBudget(amount);
                      Navigator.of(context).pop();
                    // }
                  },
                  child: Text('Create Budget'),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: button),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"))
              ],
            )
          ],
        );
      },
    );
  }

  Widget getBody() {
    // print(widget.accessToken);
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Ionicons.md_calendar,
      Ionicons.list_outline,
      Ionicons.md_wallet,
      Ionicons.chatbox_ellipses,
    ];

    return AnimatedBottomNavigationBar(
      activeColor: primary,
      splashColor: secondary,
      inactiveColor: Colors.white.withOpacity(0.5),
      icons: iconItems,
      backgroundColor: Colors.black,
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(index);
      },
    );
  }

  void selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
