import 'dart:convert';
import 'package:advisor_ui/api_data/userProfile.dart';
import 'package:advisor_ui/pages/scanned_values_page.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'addCategory.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class CreatBudgetPage extends StatefulWidget {
  final String accessToken;
  CreatBudgetPage({required this.accessToken});

  @override
  _BudgetAddPageState createState() => _BudgetAddPageState();
}

class _BudgetAddPageState extends State<CreatBudgetPage> {
  int activeCategory = 0;
  TextEditingController _budgetName = TextEditingController();
  TextEditingController _budgetPrice = TextEditingController();

  TextEditingController _budgetNameexp = TextEditingController();
  TextEditingController _budgetPriceexp = TextEditingController();
  TextEditingController _noteexp = TextEditingController();

  List<CameraDescription>? cameras; // list out the cameras available
  CameraController? controller; // controller for camera
  XFile? image; // for captured image
  FocusNode nameFocusNode = FocusNode();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _namedController = TextEditingController();
  String? selectedIcon;
  // Define a list to store the categories
  List<Category> categories = [];
  List<ExpCategory> expcategories = [];
  String scannedTotalAmount = '';
  late String categoryName;
  late int categoryId;
  @override
  void initState() {
    super.initState();
    loadCamera();
    // Call the fetchCategories function and store the result in the 'categories' list
    fetchCategories(widget.accessToken).then((fetchedCategories) {
      setState(() {
        categories = fetchedCategories;
      });
    }).catchError((error) {
      print('Error fetching categories: $error');
      // Handle the error or display an error message here
    });

    // Call the fetchCategories function and store the result in the 'categories' list
    fetchexpCategories(widget.accessToken).then((fetchedCategories) {
      setState(() {
        expcategories = fetchedCategories;
      });
    }).catchError((error) {
      print('Error fetching  Expenses categories: $error');
      // Handle the error or display an error message here
    });
    // Timer.periodic(Duration(seconds: 2), (_) {
    //   fetchCategories(widget.accessToken);
    //   fetchexpCategories(widget.accessToken);
    // });
  }

  final List<String> iconOptions = [
    "assets/images/auto.png",
    "assets/images/bank.png",
    "assets/images/cash.png",
    "assets/images/charity.png",
    "assets/images/eating.png",
    "assets/images/gift.png",
  ];
  loadCamera() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      cameras = await availableCameras();
      if (cameras != null) {
        controller = CameraController(cameras![0], ResolutionPreset.max);
        // cameras[0] = first camera, change to 1 for another camera

        controller!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      } else {
        print("No camera found");
      }
    } else {
      print("Permission not granted");
    }
  }
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  _startScan() async {
  try {
    List<OcrText> list = await FlutterMobileVision.read(
      waitTap: true,
      camera: _cameraOcr,
      fps: 5,
    );

    // Process the OCR results and extract the last amount
    String? totalAmount;
    for (int i = list.length - 1; i >= 0; i--) {
      OcrText text = list[i];
      List<String> words = text.value.split(' ');
      for (int j = words.length - 1; j >= 0; j--) {
        String word = words[j];
        if (word.contains(RegExp(r'\d+(?:,\d+)?'))) {
          // Extract the last amount using regular expression
          totalAmount = word.replaceAll(',', '');
          break;
        }
      }
      if (totalAmount != null) {
        break;
      }
    }

    if (totalAmount != null) {
      String lastDigits = totalAmount.replaceAll(RegExp(r'[^0-9]'), '');
       _budgetPriceexp.text = lastDigits;
      // Do something with the total amount
      print('Total Amount: $totalAmount');
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ScannedValuesPage(scannedValues: list),
      //   ),
      // );
    } else {
      print('Total Amount not found');
    }
  } catch (e) {
    print('Error: $e');
  }
}


  void _addCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryPage()),
    ).then((newCategory) {
      if (newCategory != null) {
        setState(() {
          categories.add(newCategory);
        });
      }
    });
  }

/////api to get list of category////////////////////////////////////////////////////////////////////
  Future<List<Category>> fetchCategories(String accessToken) async {
    final url = 'http://192.168.203.233:8000/incomeCat/incomecategory/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['filtered'];
      // print(categoriesData);
      List<Category> categories = [];
      for (var categoryData in categoriesData) {
        categories.add(Category.fromJson(categoryData));
      }

      return categories;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////

////////api integration for fetching the category lists//////////////////////////////////////////////
  Future<List<ExpCategory>> fetchexpCategories(String accessToken) async {
    const url = 'http://192.168.203.233:8000/expensesCat/excategory/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['filtered'];
      // print("Expenses Categories:__________" + categoriesData.toString());
      List<ExpCategory> expcategories = [];

      for (var categoryData in categoriesData) {
        expcategories.add(ExpCategory.fromJson(categoryData));
      }

      return expcategories;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////api to add new income/////////////////////////////////////////////////////////
  void createIncome(String budgetName, String budgetPrice, int category) async {
    final url =
        'http://192.168.203.233:8000/income/income/'; // Update with the correct API endpoint

    // Replace 'accessToken' with your actual access token
    final headers = {'Authorization': 'Bearer ${widget.accessToken}'};

    final body = {
      'note': budgetName,
      'amount': budgetPrice,
      'incCategory': category.toString(),
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201) {
      _budgetName..clear();
      _budgetPrice..clear();
      // Success: Handle the response as needed
      print('Income created successfully');
    } else {
      // Error: Handle the error condition
      print('Failed to create income. Status code: ${response.statusCode}');
    }
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////api to add new expenses/////////////////////////////////////////////////////////
  void createexpenses(
      String expname, String expprice, String note, int category) async {
    final url =
        'http://192.168.203.233:8000/expenses/expenses/'; // Update with the correct API endpoint

    // Replace 'accessToken' with your actual access token
    final headers = {'Authorization': 'Bearer ${widget.accessToken}'};

    final body = {
      'name': expname,
      'amount': expprice,
      'note': note,
      'exCategory': category.toString(),
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201) {
      _budgetNameexp.clear();
      _budgetPriceexp..clear();
      _noteexp..clear();
      // Success: Handle the response as needed
      print('expenses created successfully');
    } else {
      // Error: Handle the error condition
      print('Failed to create income. Status code: ${response.statusCode}');
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////
  bool showwidget1 = true;
  bool showwidget2 = false;
  bool showaddcategory = false;
  bool showaddcategory1 = false;
  void toggleWidgets() {
    setState(() {
      showwidget1 = !showwidget1;
      showwidget2 = !showwidget2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 227, 227),
      body: getBody(context),
    );
  }

  Widget getBody(BuildContext context) {
    // print("BudgetPage__________:${widget.accessToken}");
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: black,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: black,
                          ),
                          //  width: 411,
                          //  height: 160,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 55, right: 20, left: 20, bottom: 25),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const SizedBox(width: 80),
                                    Text(
                                      "Create Income/expenses",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: white),
                                    ),
                                  ]),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  const SizedBox(width: 50),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showwidget1 = true;
                                        showwidget2 = false;
                                        _budgetName.clear();
                                        _budgetPrice.clear();
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              button),
                                    ),
                                    child: Text(
                                      'Income',
                                      style:
                                          TextStyle(color: white, fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showwidget1 = false;
                                        showwidget2 = true;
                                        _budgetName.clear();
                                        _budgetPrice.clear();
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              button),
                                    ),
                                    child: Text('Expenses',
                                        style: TextStyle(
                                            color: white, fontSize: 18)),
                                  ),
                                ],
                              )
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          //////////////category integration////////////////
          if (showwidget1) ...[
            Container(
              decoration: BoxDecoration(color: grey, boxShadow: [
                BoxShadow(
                  color: grey.withOpacity(0.01),
                  spreadRadius: 10,
                  blurRadius: 3,
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, right: 20, left: 20, bottom: 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Create Income",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: black),
                        ),
                        // IconButton(
                        //   icon: const Icon(AntDesign.scan1),
                        //   onPressed: _startScan,

                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose category",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black.withOpacity(0.5)),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            // setState(() {
                            //   showaddcategory = true;
                            // });
                            _showPopup1(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(button),
                          ),
                          child: Text('Add Category'))
                    ],
                  ),
                ],
              ),
            ),
            // Container(
            //   child: Visibility(
            //     visible: showaddcategory,
            //     child: SizedBox(child: addcategory(context)),
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeCategory = index;
                      });
                      categoryName = categories[index].name;
                      categoryId = categories[index].id;
                      // print(categoryName);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 140,
                        height: 130,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border.all(
                            width: 2,
                            color: activeCategory == index
                                ? Color.fromARGB(255, 12, 198, 227)
                                : Colors.transparent,
                          ),
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
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grey.withOpacity(0.15),
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      categories[index].iconUrl,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                categories[index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Budget name",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    TextField(
                      controller: _budgetName,
                      cursorColor: black,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Budget Name",
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: (size.width - 140),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter budget",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17,
                                  color: Color(0xff67727d),
                                ),
                              ),
                              TextField(
                                controller: _budgetPrice,
                                cursorColor: black,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter Budget",
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: button,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(button),
                            ),
                            icon: const Icon(AntDesign.arrowright),
                            onPressed: () async {
                              // Call the createIncome function with the input values
                              // print(_budgetName.text);
                              // print(_budgetPrice.text);
                              createIncome(_budgetName.text, _budgetPrice.text,
                                  categoryId);
                              await fetchexpCategories(widget.accessToken);
                            },
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ],
          if (showwidget2) ...[
            Container(
              decoration: BoxDecoration(color: white, boxShadow: [
                BoxShadow(
                  color: grey.withOpacity(0.01),
                  spreadRadius: 10,
                  blurRadius: 3,
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, right: 20, left: 20, bottom: 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Create Expenses",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: black),
                        ),
                        IconButton(
                          icon: const Icon(AntDesign.scan1),
                          onPressed: _startScan,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose category",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black.withOpacity(0.5)),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            // setState(() {
                            //   showaddcategory1 = true;
                            // });
                            _showPopup2(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(button),
                          ),
                          child: Text('Add Category')),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _addCategory,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Container(
            //   child: Visibility(
            //     visible: showaddcategory1,
            //     child: SizedBox(child: addcategory1(context)),
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(expcategories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeCategory = index;
                      });
                      categoryName = expcategories[index].name;
                      categoryId = expcategories[index].id;
                      // print(categoryName);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 140,
                        height: 130,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border.all(
                            width: 2,
                            color: activeCategory == index
                                ? Color.fromARGB(255, 12, 198, 227)
                                : Colors.transparent,
                          ),
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
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grey.withOpacity(0.15),
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      expcategories[index].iconUrl,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                expcategories[index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Budget name",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Color(0xff67727d)),
                  ),
                  TextField(
                    controller: _budgetNameexp,
                    cursorColor: black,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: black),
                    decoration: InputDecoration(
                        hintText: "Enter Budget Name",
                        border: InputBorder.none),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Note",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Color(0xff67727d)),
                  ),
                  TextField(
                    controller: _noteexp,
                    cursorColor: black,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: black),
                    decoration: InputDecoration(
                        hintText: "Enter notes related to expenses ",
                        border: InputBorder.none),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: (size.width - 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter budget",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: Color(0xff67727d)),
                            ),
                            TextField(
                              controller: _budgetPriceexp,
                              cursorColor: black,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter Budget",
                                border: InputBorder.none,
                              ),
                              
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: button,
                            borderRadius: BorderRadius.circular(15)),
                        child: IconButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(button),
                          ),
                          icon: const Icon(AntDesign.arrowright),
                          onPressed: () async {
                            // print(_budgetNameexp.text);
                            // print(_budgetPriceexp.text);
                            // print(_noteexp.text);
                            createexpenses(
                                _budgetNameexp.text,
                                _budgetPriceexp.text,
                                _noteexp.text,
                                categoryId);
                            await fetchCategories(widget.accessToken);
                          },
                          color: white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<http.Response> _createCategory(String name, String accessToken) async {
    final url = Uri.parse('http://192.168.203.233:8000/expensesCat/excategory/');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    final body = {
      'name': name,
    };
    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    // print(response);
    return response;
  }

  Future<void> _createIncome(String name, String accessToken) async {
    final url = Uri.parse(
        'http://192.168.203.233:8000/incomeCat/incomecategory/'); // Update the URL here
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    final body = {
      'name': name,
    };
    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    // print(response);
    if (response.statusCode == 201) {
      // Update the condition to check for 201 (HTTP_CREATED)
      print("category added");
    } else {
      print('Failed to create income. Status code: ${response.statusCode}');
    }
  }

  void _showPopup1(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Income Category'),
              content: Text('Enter the name of Category'),
              actions: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Category Name'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(button),
                      ),
                      onPressed: () async {
                        // Retrieve the category name and selected icon

                        // Create a new Category object
                        // BudgetCategory newCategory = BudgetCategory(
                        //   name: categoryName,
                        // );
                        _createIncome(_nameController.text, widget.accessToken);
                        await fetchCategories(widget.accessToken);
                        setState(() {
                          _nameController.clear();
                        });
                        Navigator.pop(context);
                        // Pass the new category back to the previous page
                      },
                      child: Text('Save Category'),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(button),
                        ),
                        onPressed: () {
                          setState(() {
                            _nameController.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"))
                  ],
                )
              ]);
        });
  }

  void _showPopup2(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Expense Category'),
              content: Text('Enter the name of Category'),
              actions: [
                TextField(
                  focusNode: nameFocusNode,
                  controller: _namedController,
                  decoration: InputDecoration(labelText: 'Category Name'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(button),
                      ),
                      onPressed: () async {
                        // Retrieve the category name and selected icon
                        // Create a new Category object
                        // BudgetCategory newCategory = BudgetCategory(
                        //   name: categoryName,
                        // );

                        // Send the category data to the API
                        _createCategory(
                            _namedController.text, widget.accessToken);
                        await fetchexpCategories(widget.accessToken);
                        setState(() {
                          _namedController.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Save Category'),
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(button),
                        ),
                        onPressed: () {
                          setState(() {
                            _namedController.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Cancel")),
                  ],
                )
              ]);
        });
  }
}

class category {
  final String name;
  final String icon;
  category({required this.name, required this.icon});
}
