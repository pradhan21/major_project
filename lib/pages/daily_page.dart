import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:advisor_ui/api_data/dailpagedata.dart';
import 'package:advisor_ui/json/daily_json.dart';
import 'package:advisor_ui/json/day_month.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:flutter/material.dart';
import "package:flutter_vector_icons/flutter_vector_icons.dart";
import 'package:intl/intl.dart';

import '../core/route/app_route_name.dart';

class DailyPage extends StatefulWidget {
  final String accessToken;
  DailyPage({required this.accessToken});

  @override
  _DailyPageState createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> with TickerProviderStateMixin {
  Timer? timer;
  DateTime currentDate = DateTime.now(); // Get the current date
  List<DateTime> visibleDates = [];
  List<income> incomes = [];
  List<expense> expenses = [];
  List<Category> categories = [];
  List<ExpCategory> expcategories = [];
  List<ExpCategory> expcategoy = [];

  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      DateTime date = currentDate.add(Duration(days: i));
      visibleDates.add(date);
    }
    //   Timer.periodic(Duration(seconds: 20), (_) {  fetchExpenses();
    // fetchIncomes();
    //     fetchCategories(widget.accessToken);
    //    fetchexpCategories(widget.accessToken);});
    fetchExpenses();
    fetchIncomes();
    fetchCategories(widget.accessToken);
    fetchexpCategories(widget.accessToken);
  }

  int activeDay = 1;

  void goToPreviousDates() {
    setState(() {
      currentDate = currentDate.subtract(Duration(days: 1));
    });
  }

  void goToFutureDates() {
    setState(() {
      currentDate = currentDate.add(Duration(days: 1));
    });
  }

  void updateVisibleDates() {
    visibleDates.clear();
    for (int i = 0; i < 7; i++) {
      DateTime date = currentDate.add(Duration(days: i));
      visibleDates.add(date);
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel any active timers
    super.dispose();
  }

  Future<void> fetchIncomes() async {
    try {
      List<income> fetchedIncomes = await fetchIncome(widget.accessToken);
      // print(fetchedIncomes);
      setState(() {
        incomes = fetchedIncomes;
      });
    } catch (error) {
      print('Error fetching incomes: $error');
    }
  }

  Future<List<income>> fetchIncome(String accessToken) async {
    final url = 'http://10.0.2.2:8000/income/income/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final incomesData = jsonData['results'];
      List<income> fetchedIncomes = [];

      if (incomesData != null) {
        for (var incomeData in incomesData) {
          fetchedIncomes.add(income.fromJson(incomeData));
        }
      }
      return fetchedIncomes;
    } else {
      throw Exception(
          'Failed to fetch incomes. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchExpenses() async {
    try {
      List<expense> fetchedExpenses = await fetchExpense(widget.accessToken);
      setState(() {
        expenses = fetchedExpenses;
      });
    } catch (error) {
      print('Error fetching expenses: $error');
    }
  }

  Future<List<expense>> fetchExpense(String accessToken) async {
    final url = 'http://10.0.2.2:8000/expenses/expenses/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final expensesData = jsonData['results'];
      // print(jsonData);
      List<expense> expenses = [];
      if (expensesData != null) {
        for (var expenseData in expensesData) {
          expenses.add(expense.fromJson(expenseData));
        }
      }
      return expenses;
    } else {
      print("error");
      throw Exception(
          'Failed to fetch expenses. Status code: ${response.statusCode}');
    }
  }

  Future<List<Category>> fetchCategories(String accessToken) async {
    final url = 'http://10.0.2.2:8000/incomeCat/incomecategory/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['filtered'];
      List<Category> fetchedCategories = [];

      for (var categoryData in categoriesData) {
        fetchedCategories.add(Category.fromJson(categoryData));
      }

      setState(() {
        categories = fetchedCategories;
      });

      return fetchedCategories;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }

  Future<List<ExpCategory>> fetchexpCategories(String accessToken) async {
    // print("hello ");
    final url = 'http://10.0.2.2:8000/expensesCat/excategory/';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final categoriesData = jsonData['filtered'];
      // print("URI Expenses Categories:__________$jsonData" );
      // List<ExpCategory> expcategories = [];
      for (var categoryData in categoriesData) {
        expcategories.add(ExpCategory.fromJson(categoryData));
      }
      for (var data in expcategories) {
        print('Category Name: ${data.id}');
        print('Category Limit: ${data.name}');
        print('Category Total: ${data.iconUrl}');
        print('------------------------');
      }
      return expcategories;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 227, 227),
      body: getBody(),
      //  floatingActionButton: FloatingActionButton(
      //   backgroundColor: button,
      //   onPressed: (){
      //     Navigator.pushNamed(context,AppRouteName.note,  arguments: {
      //               'accessToken': widget.accessToken,
      //             },);
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(AntDesign.book),
      // ),
    );
  }

  Widget getBody() {
    // print("daily_page_accessToken__________" + widget.accessToken);
    var size = MediaQuery.of(context).size;
    List<income> filteredIncomes = incomes.where((income) {
      DateTime incomeDate = DateTime.parse(income.date);
      return incomeDate.year == currentDate.year &&
          incomeDate.month == currentDate.month &&
          incomeDate.day == currentDate.day;
    }).toList();
    List<expense> FilteredExpenses = expenses.where((expense) {
      try {
        DateTime expenseDate = DateFormat('yyyy-MM-dd').parse(expense.date);
        return expenseDate.year == currentDate.year &&
            expenseDate.month == currentDate.month &&
            expenseDate.day == currentDate.day;
      } catch (e) {
        print('Error parsing date: $e');
        return false; // Exclude the expense if the date parsing fails
      }
    }).toList();
    // print(FilteredExpenses);

    double calculateTotalAmount(
        List<income> filteredIncomes, List<expense> filteredExpenses) {
      double itotal = 0;
      for (var income in filteredIncomes) {
        itotal += income.amount;
      }
      double etotal = 0;
      for (var expense in filteredExpenses) {
        etotal += expense.amount;
      }

      double gtotal = itotal - etotal;
      return gtotal;
    }

    String getCategoryIconUrl(int categoryId, List<Category> categories) {
      final category = categories.firstWhere((c) => c.id == categoryId,
          orElse: () => Category(id: 0, name: '', iconUrl: ''));
      return category.iconUrl;
    }

    String getexpCategoryIconUrl(
        int categoryId, List<ExpCategory> expcategories) {
      int cid = categoryId;
      print("categoryId: $categoryId");
      final category = expcategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => ExpCategory(
            id: 0,
            name: '',
            iconUrl: ''), // Provide default values when not found
      );
      // print(category.iconUrl);
      return category.iconUrl;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: black, boxShadow: [
              // BoxShadow(
              //   color: const Color.fromARGB(255, 47, 47, 47),
              //   spreadRadius: 10,
              //   blurRadius: 3,
              //   // changes position of shadow
              // ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 50, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const SizedBox(width:35),
                      Text(
                        "Daily Transaction",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                      //  IconButton(onPressed:(){
                      //   Navigator.pushNamed(context,AppRouteName.note);
                      // }, icon:  Icon(AntDesign.book,color: white,)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: goToPreviousDates,
                        icon: Icon(
                          Icons.arrow_back,
                          color: white,
                        ),
                      ),
                      Text(
                        DateFormat('EEE, MMM d, y').format(currentDate),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                      IconButton(
                        onPressed: goToFutureDates,
                        icon: Icon(
                          Icons.arrow_forward,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(visibleDates.length, (index) {
                      final DateFormat dayFormat =
                          DateFormat('EEE'); // Format the day abbreviation
                      final DateFormat dateFormat =
                          DateFormat('dd'); // Format the day of the month

                      DateTime date = visibleDates[index];
                      bool isCurrentDate = date.day == currentDate.day &&
                          date.month == currentDate.month &&
                          date.year == currentDate.year;
                      // Set the index of the current date

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            String currentDate =
                                DateFormat('y-M-d').format(date);
                            // print(currentDate);
                            activeDay = index;
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 40) / 7,
                          child: Column(
                            children: [
                              Text(
                                dayFormat.format(visibleDates[
                                    index]), // Display the day abbreviation
                                style: TextStyle(fontSize: 10, color: white),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isCurrentDate
                                      ? button
                                      : white, // Highlight current date in red color
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: activeDay == index ? white : white,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    dateFormat.format(visibleDates[
                                        index]), // Display the day of the month
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      // color: activeDay == index ? white : black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
          Container(
            color: Color.fromARGB(255, 46, 45, 45),
            height: 80,
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Total ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: white)),
                    const SizedBox(height: 8),
                    Text(
                        "\Rs   ${calculateTotalAmount(filteredIncomes, FilteredExpenses).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: white)),
                  ]),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: grey,
            ),
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(filteredIncomes.length, (index) {
                      final income = filteredIncomes[index];
                      return ListTile(
                        onTap: () {
                          // Open edit popup
                          // Call a method to handle the edit functionality
                          editincomePopup(context,
                              income); // Pass the selected item as an argument
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (size.width - 40) * 0.7,
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: white),
                                      color: grey,
                                    ),
                                    child: Center(
                                      child: Image.network(
                                        getCategoryIconUrl(
                                          income.category_id,
                                          categories,
                                        ),
                                        color: black,
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Container(
                                    width: (size.width - 90) * 0.5,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          income.category_name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          income.note,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: black.withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: (size.width - 200) * 0.3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    income.amount.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 65, top: 8),
                          child: Divider(
                            thickness: 0.8,
                            color: black,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(FilteredExpenses.length, (index) {
                      final expense = FilteredExpenses[index];
                      return ListTile(
                        onTap: () {
                          // Open edit popup
                          // Call a method to handle the edit functionality
                          editexpensePopup(context,
                              expense); // Pass the selected item as an argument
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (size.width - 40) * 0.7,
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: white),
                                      color: grey,
                                    ),
                                    child: Center(
                                      child: getexpCategoryIconUrl(
                                                  expense.category_id,
                                                  expcategories)
                                              .isEmpty
                                          ? Icon(Icons
                                              .error) // Display a default error icon for empty URLs
                                          : Image.network(
                                              getexpCategoryIconUrl(
                                                  expense.category_id,
                                                  expcategories),
                                              color: black,
                                              width: 30,
                                              height: 30,
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Container(
                                    width: (size.width - 90) * 0.5,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.category_name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          expense.note,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: black.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: (size.width - 200) * 0.3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    expense.amount.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 65, top: 8),
                          child: Divider(
                            thickness: 0.8,
                            color: black,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: Text(
                        "Total",
                        style: TextStyle(
                            fontSize: 16,
                            color: black,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "\Rs   ${calculateTotalAmount(filteredIncomes, FilteredExpenses).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 20,
                            color: black,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> editincomePopup(
      BuildContext context, income selectedIncome) async {
    final TextEditingController _amountController = TextEditingController(
      text: selectedIncome.amount.toStringAsFixed(2),
    );
    double editedAmount = selectedIncome.amount;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                selectedIncome.category_name,
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
                        editedAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  // Add more fields as needed to edit other properties of the income
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        // Call the method to update the income with the edited values
                        updateIncome(selectedIncome.id, editedAmount);
                        Navigator.pop(context); // Close the popup
                      },
                      child: Text('Update'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        // Call the method to delete the income
                        deleteIncome(selectedIncome.id);
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

// Helper methods for updating and deleting the income
  Future<void> updateIncome(int incomeId, double amount) async {
    final url = Uri.parse('http://10.0.2.2:8000/income/income/$incomeId/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
      // Add any required headers
    };
    // print(widget.accessToken);
    final body = jsonEncode({
      'amount': amount,
    });

    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Budget created successfully
      // You can perform any additional actions here
      print('Inocme updated successfully');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('SuccessFully Updated Income '),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: button),
                onPressed: () {
                  fetchIncome(widget.accessToken);
                  Navigator.of(context).pop(); // Close the previous dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      // fetchdata(widget.accessToken);
    } else {
      // Failed to create budget
      // Handle the error accordingly
      print('Failed to update income. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteIncome(int incomeId) async {
    // Implement the logic to delete the income with the given ID
    final url = 'http://10.0.2.2:8000/income/income/$incomeId/';

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
      print('income data deleted');
      //    setState(() {
      //   fetchedIncomes.removeWhere((item) => item.note_id == incomeId);
      // });
      await fetchIncome(widget.accessToken);
      await fetchCategories(widget.accessToken);
      Navigator.pushNamed(context, AppRouteName.root, arguments: {
        'accessToken': widget.accessToken,
      });
    } else {
      // Error deleting category data
      print(
          'Failed to delete income data. Status code: ${response.statusCode}');

      // If deletion fails, add the item back to the local list
    }
  }

  Future<void> editexpensePopup(
      BuildContext context, expense selectedExpense) async {
    final TextEditingController _amountController = TextEditingController(
      text: selectedExpense.amount.toStringAsFixed(2),
    );
    double editedAmount = selectedExpense.amount;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                selectedExpense.category_name,
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
                        editedAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  // Add more fields as needed to edit other properties of the expense
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        // Call the method to update the expense with the edited values
                        updateExpense(selectedExpense.id, editedAmount);
                        Navigator.pop(context); // Close the popup
                      },
                      child: Text('Update'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: button),
                      onPressed: () {
                        // Call the method to delete the expense
                        deleteExpense(selectedExpense.id);
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

// Helper methods for updating and deleting the expense
  Future<void> updateExpense(int expenseId, double amount) async {
    final url = Uri.parse('http://10.0.2.2:8000/expenses/expenses/$expenseId/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
      // Add any required headers
    };
    // print(widget.accessToken);
    final body = jsonEncode({
      'amount': amount,
    });

    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Budget created successfully
      // You can perform any additional actions here
      print('Expense updated successfully');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('SuccessFully Updated Expense '),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: button),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the previous dialog
                  fetchExpense(widget.accessToken);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      // fetchdata(widget.accessToken);
    } else {
      // Failed to create budget
      // Handle the error accordingly
      print('Failed to update expense. Status code: ${response.statusCode}');
    }
  }

  // Implement the logic to update the expense with the given ID and amount
  Future<void> deleteExpense(int expenseId) async {
    // Implement the logic to delete the expense with the given ID
    final url = 'http://10.0.2.2:8000/expenses/expenses/$expenseId/';

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
      print('Expenses data deleted');
      //    setState(() {
      //   fetchedIncomes.removeWhere((item) => item.note_id == incomeId);
      // });
      await fetchExpense(widget.accessToken);
      await fetchexpCategories(widget.accessToken);
      Navigator.pushNamed(context, AppRouteName.root, arguments: {
        'accessToken': widget.accessToken,
      });
    } else {
      // Error deleting category data
      print(
          'Failed to delete expense data. Status code: ${response.statusCode}');

      // If deletion fails, add the item back to the local list
    }
  }
}
