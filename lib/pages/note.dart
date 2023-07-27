import 'dart:async';
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:intl/intl.dart';
import '../api_data/notedata.dart';
import '../core/route/app_route_name.dart';

class NotePage extends StatefulWidget {
  final String accessToken;
  NotePage({required this.accessToken});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<notedata> notesdata = [];
  List<noteamount> notesamount = [];
  List<String> list = <String>['Payable', 'Receivable'];
  String dropdownValue = 'Payable';

  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _discController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  late double totalPayable = 0;
  late double totalreceivable = 0;
  @override
  void initState() {
    super.initState();
    dropdownValue = list.first;
    fetchamount(widget.accessToken);
    fetchdata(widget.accessToken);
    // Timer.periodic(Duration(seconds: 2), (_) {
    //   fetchamount(widget.accessToken);
    //   fetchdata(widget.accessToken);
    // });
  }

  Future<void> _createnote(
      String title, int amount, String desc, String type, String date) async {
    final url = Uri.parse('http://10.0.2.2:8000/todo/todo/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
      // Add any required headers
    };
    print(widget.accessToken);
    final body = jsonEncode({
      'title': title,
      'amount': amount,
      'discription': desc,
      'type': type,
      'date': date,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Budget created successfully
      // You can perform any additional actions here
      print('NOte created successfully');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('SuccessFully created Note '),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: button),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the previous dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      await fetchamount(widget.accessToken);
      await fetchdata(widget.accessToken);
    } else {
      // Failed to create budget
      // Handle the error accordingly
      print('Failed to create note. Status code: ${response.statusCode}');
    }
  }

  Future<void> _updatenote(
      int id, title, int amount, String desc, String date) async {
    final url = Uri.parse('http://10.0.2.2:8000/todo/todo/$id/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
      // Add any required headers
    };
    // print(widget.accessToken);
    final body = jsonEncode({
      'title': title,
      'amount': amount,
      'discription': desc,
      'date': date,
    });

    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Budget created successfully
      // You can perform any additional actions here
      print('NOte updated successfully');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('SuccessFully updated Note '),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: button),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close the previous dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      await fetchamount(widget.accessToken);
      await fetchdata(widget.accessToken);
    } else {
      // Failed to create budget
      // Handle the error accordingly
      print('Failed to update note. Status code: ${response.statusCode}');
    }
  }

  Future<List<notedata>> fetchdata(String accessToken) async {
    final url = 'http://10.0.2.2:8000/todo/todo/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['results'];
      print(categoriesData);


      List<notedata> notesdata = [];
      for (var categoryData in categoriesData) {
        notesdata.add(notedata.fromJson(categoryData));
      }

      // Print the categories data
      setState(() {
        this.notesdata = notesdata;
      });
      return notesdata;
    } else {
      throw Exception(
          'Failed to fetch notes data. Status code: ${response.statusCode}');
    }
  }

  Future<noteamount> fetchamount(String accessToken) async {
    final url = 'http://10.0.2.2:8000/todo/amount/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'];

      // Create a single noteamount object from the data
      noteamount amountData = noteamount.fromJson(data);

      // Do the required calculations
      totalPayable = amountData.pamount;
      totalreceivable = amountData.ramount;
      print("hello $totalPayable");
      print("hello $totalreceivable");

      setState(() {
        this.notesamount = [amountData];
      });

      await fetchdata(widget.accessToken);
      return amountData;
    } else {
      throw Exception(
          'Failed to fetch notes amount. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteoveralldata(int note_id) async {
    final url = 'http://10.0.2.2:8000/todo/todo/$note_id/';

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
        notesdata.removeWhere((item) => item.note_id == note_id);
      });
      await fetchamount(widget.accessToken);
      await fetchdata(widget.accessToken);
      Navigator.pushNamed(context, AppRouteName.root, arguments: {
        'accessToken': widget.accessToken,
      });
    } else {
      // Error deleting category data
      print(
          'Failed to delete category data. Status code: ${response.statusCode}');

      // If deletion fails, add the item back to the local list
    }
  }

  Color getTileColor(String type) {
    switch (type) {
      case 'receivable':
        return Colors.blue.shade400;
      case 'payable':
        return Colors.red.shade400;
      default:
        return Colors
            .grey; // Set a default color when the type is not recognizable
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 227, 227),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
            color: black,
            height: 170,
            child: Padding(
                padding: EdgeInsets.only(top: 55, left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const SizedBox(width:50),
                        Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // IconButton(onPressed: (){}, icon: Icon(Icons.search,color: white,) ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          "All Available Notes ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              // method to show the search bar
                              showSearch(
                                context: context,
                                // delegate to customize the search bar
                                delegate: CustomSearchDelegate(notesdata),
                              );
                            },
                            icon: Icon(
                              Icons.search,
                              color: white,
                            )),
                      ],
                    ),
                  ],
                ))),
        Container(
          color: Color.fromARGB(255, 46, 45, 45),
          height: 80,
          child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("Total Payable",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: white)),
                      const SizedBox(height: 8),
                      Text("RS ${totalPayable}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: red)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Total Receivable",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: white)),
                      const SizedBox(height: 8),
                      Text("RS ${totalreceivable}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: const Color.fromARGB(255, 0, 140, 255))),
                    ],
                  )
                ]),
          ),
        ),
        Container(
            child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            children: [
              // Add some spacing between the title and the list
              notesdata.isEmpty
                  ? Center(
                      child: Text('No data found.'),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4), //
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: notesdata.length,
                        itemBuilder: (context, index) {
                          final note = notesdata[index];
                          final Color tileColor = getTileColor(note.type);

                          return Padding(
                            // Wrap each ListTile with Padding widget
                            padding: EdgeInsets.symmetric(
                                vertical: 8), // Set the vertical spacing
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 100,
                                child: ListTile(
                                  title: Column(children: [
                                    const SizedBox(height: 20),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(note.title,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          Text(note.amount.toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                    const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(note.discription,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          Text(note.date,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        ]),
                                  ]),
                                  tileColor: tileColor,
                                  onTap: () {
                                    // Custom page transition when tapping on the ListTile
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          // This is your details page
                                          return Scaffold(
                                            backgroundColor: Color.fromARGB(
                                                255, 233, 227, 227),
                                            appBar: AppBar(
                                              title: Text(note.title),
                                              backgroundColor: Colors.black,
                                            ),
                                            body: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 20, right: 10, left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(children: [
                                                    Text(
                                                      "Amount:",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        " ${note.amount.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ]),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    "Discription:",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text("${note.discription}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "Due Date:",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(" ${note.date}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "Created Date:",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(" ${note.created_date}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "Type:",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text("Type: ${note.type}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  const SizedBox(
                                                    height: 50,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    button),
                                                        onPressed: () async {
                                                          _showeditPopup(
                                                              context, note);
                                                          //  Navigator.of(context).pop();
                                                        },
                                                        child:
                                                            Text('Edit Note'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    button),
                                                        onPressed: () {
                                                          deleteoveralldata(
                                                              note.note_id);

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            Text("Delete Note"),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          // Custom transition animation
                                          return FadeTransition(
                                              opacity: animation, child: child);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 10),
            ],
          ),
        )),
      ])),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: button,
        overlayColor: Colors.black,
        overlayOpacity: 0.6,
        children: [
          SpeedDialChild(
            backgroundColor: button,
            child: Icon(Icons.add),
            label: 'Add Note',
            onTap: () {
              // Handle add expense action
              _showPopup(context);
            },
          )
        ],
      ),
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Note'),
          content: SingleChildScrollView(
            // Add SingleChildScrollView here
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _discController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Type",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        print(
                            'Selected value: $value'); // Add this print statement to debug
                        setState(() {
                          dropdownValue =
                              value!; // Update the dropdownValue to the selected value
                        });
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Select Date Of Birth",
                  ),
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100));
                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        dateController.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {}
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final int amount = int.parse(_amountController.text);
                        final String disc = _discController.text;
                        final String type = dropdownValue.toLowerCase();
                        final String date = dateController.text;
                        print(title);
                        print(amount);
                        print(disc);
                        print(type);
                        print(date);
                        _createnote(title, amount, disc, type, date);
                        Navigator.of(context).pop();
                      },
                      child: Text('Create Note'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showeditPopup(BuildContext context, notedata note) {
    _titleController.text = note.title;
    _amountController.text = note.amount.toStringAsFixed(0);
    _discController.text = note.discription;
   
    dateController.text = note.date;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Note'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _discController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Type",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                   
                  ],
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Select Date Of Birth",
                  ),
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100));
                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        dateController.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {}
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final int amount = int.parse(_amountController.text);
                        final String disc = _discController.text;
                        final String date = dateController.text;
                        print(title);
                        print(amount);
                        print(disc);
                        print(date);
                        _updatenote(
                            note.note_id, title, amount, disc, date);
                        //  Navigator.of(context).pop();
                      },
                      child: Text('Create Note'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<notedata> notesdata = []; // Add the notesdata list as a class member

  CustomSearchDelegate(List<notedata> notesdata) {
    this.notesdata = notesdata; // Initialize the notesdata list
  }
  List<String> searchTerms = [
    "Apple",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime

  @override
  Widget buildSuggestions(BuildContext context) {
    // Filter the notesdata list based on the search query
    List<notedata> matchQuery = notesdata
        .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: Color.fromARGB(255, 233, 227,
          227), // Set the background color of the suggestions list here
      child: ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result.title),
            subtitle: Text(result.discription),
            onTap: () {
              // Navigate to the details page when the user taps on the ListTile
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    // This is your details page
                    return Scaffold(
                      backgroundColor: Color.fromARGB(255, 233, 227, 227),
                      appBar: AppBar(
                        title: Text(result.title),
                        backgroundColor: Colors.black,
                      ),
                      body: Padding(
                        padding: EdgeInsets.only(top: 20, right: 10, left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount:",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Text(" ${result.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Description:",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Text("${result.discription}",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Due Date:",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Text(" ${result.date}",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Created Date:",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Text(" ${result.created_date}",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Type:",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Text("Type: ${result.type}",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(
                              height: 50,
                            ),
                            // Add other details you want to display...
                          ],
                        ),
                      ),
                    );
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    // Custom transition animation
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
