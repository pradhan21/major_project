import 'dart:convert';
import 'dart:math';
import 'package:advisor_ui/detailed_data/detailedincome.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:advisor_ui/detailed_data/dailyexpense.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../export to scv/export.dart';
class DetailedRoot extends StatefulWidget {
  final String accessToken;
  final List<double> dataPoints = [20, 30, 50];
  DetailedRoot({required this.accessToken});

  @override
  _DetailedRootState createState() => _DetailedRootState();
}

class _DetailedRootState extends State<DetailedRoot>
    with TickerProviderStateMixin {
  late final TabController _maintabController;

  @override
  void initState() {
    super.initState();
    _maintabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _maintabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Detailed View'),
        bottom: TabBar(
          indicatorColor: Colors.white,
          tabs: const <Widget>[
            Tab(
              text: 'Incomes',
              icon: Icon(Icons.download_for_offline_rounded),
            ),
            Tab(
              text: 'Expenses',
              icon: Icon(Icons.file_upload_outlined),
            ),
            Tab(
              text: 'Budget',
              icon: Icon(Icons.account_balance_wallet),
            ),
          ],
          controller: _maintabController,
        ),
      ),
      body: TabBarView(
        controller: _maintabController,
        children: [
          NestedTabBar(
            outerTab: 'Incomes',
            accessToken: widget.accessToken,
          ),
          NestedTabBar(
            outerTab: 'Expenses',
            accessToken: widget.accessToken,
          ),
          NestedTabBar(
            outerTab: 'Budget',
            accessToken: widget.accessToken,
          ),
        ],
      ),
    );
  }
}

class NestedTabBar extends StatefulWidget {
  final String outerTab;
  final String accessToken;

  NestedTabBar({required this.outerTab, required this.accessToken});
  final List<double> dataPoints = [20, 30, 50];
  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int currentIndex = 2;
  // List<expense> _expenseData = [];
  List<PieChartSectionData>? sections = [];
  List<PieChartSectionData>? yearexpensessection = [];
  List<PieChartSectionData>? weekexpensessection = [];

  List<PieChartSectionData>? incomesections = [];
  List<PieChartSectionData>? yearincomesection = [];
  List<PieChartSectionData>? weekincomesection = [];

  List<WeekIncome> weekincome = [];
  List<MonthIncome> monthincome = [];
  List<YearIncome> yearincome = [];

  bool incomeweek = false;
  bool incomeMonth = false;
  bool incomeyear = true;
  late String incomename = " ";

  List<weekexpense> weekexpenses = [];
  List<expense> monthexpense = [];
  List<yearexpense> yearexpenses = [];
  bool expenseweek = false;
  bool expenseMonth = false;
  bool expenseyear = true;
  late String expensename = " ";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    fetchMonthExpenseData(widget.accessToken);
    fetchYearlyExpenseData(widget.accessToken);
    fetchWeekExpenseData(widget.accessToken);
    fetchMonthIncomeData(widget.accessToken);
    fetchYearlyIncomeData(widget.accessToken);
    fetchWeekIncomeData(widget.accessToken);
    requestStoragePermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }


Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, you can now write to external storage
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////Expenses Data retrival///////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<List<weekexpense>> fetchWeekExpenseData(String accessToken) async {
    try {
      final url = "http://10.0.2.2:8000/core/expenses-category-week/";
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['filtered'] != null) {
          final dynamic filteredData = responseData['filtered'];
          // print('expenses_____+$filteredData');
          if (filteredData != null) {
            List<PieChartSectionData> sections = [];
            double totalAmount = 0;
            List<weekexpense> expenses = [];

            for (var categoryData in filteredData) {
              final incomeItem = weekexpense.fromJson(categoryData);
              totalAmount += incomeItem.amount;
              expenses.add(incomeItem);
              weekexpenses.add(incomeItem);

              final section = PieChartSectionData(
                value: incomeItem.amount.toDouble(),
                color: getRandomColor(),
                title: '${incomeItem.category}',
                radius: 100,
              );
              sections.add(section);
            }

            final expenseData = PieChartSectionData(
              value: totalAmount.toDouble(),
              color: getRandomColor(),
              title: 'Monthly Expense',
              radius: 100,
            );

            setState(() {
              this.weekexpensessection = sections;
            });

            return expenses;
          }
        }
      }

      throw Exception('Failed to fetch expense data');
    } catch (e) {
      print("error fetching monthly expense data: $e");
      throw Exception('Failed to fetch expense data: $e');
    }
  }

  Future<List<expense>> fetchMonthExpenseData(String accessToken) async {
    try {
      final url = "http://10.0.2.2:8000/core/expenses-category-month/";
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['filtered'] != null) {
          final dynamic filteredData = responseData['filtered'];
          // print('expenses_____+$filteredData');
          if (filteredData != null) {
            List<PieChartSectionData> sections = [];
            double totalAmount = 0;
            List<expense> expenses = [];

            for (var categoryData in filteredData) {
              final incomeItem = expense.fromJson(categoryData);
              totalAmount += incomeItem.amount;
              expenses.add(incomeItem);
              monthexpense.add(incomeItem);

              final section = PieChartSectionData(
                value: incomeItem.amount.toDouble(),
                color: getRandomColor(),
                title: '${incomeItem.category}',
                radius: 100,
              );
              sections.add(section);
            }

            final expenseData = PieChartSectionData(
              value: totalAmount.toDouble(),
              color: getRandomColor(),
              title: 'Monthly Expense',
              radius: 100,
            );

            setState(() {
              this.sections = sections;
            });

            return expenses;
          }
        }
      }

      throw Exception('Failed to fetch expense data');
    } catch (e) {
      print("error fetching monthly expense data: $e");
      throw Exception('Failed to fetch expense data: $e');
    }
  }

  Future<List<yearexpense>> fetchYearlyExpenseData(String accessToken) async {
    try {
      final url = "http://10.0.2.2:8000/core/expenses-category-year/";
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['filtered'] != null) {
          final dynamic filteredData = responseData['filtered'];
          // print('expenses_____+$filteredData');
          if (filteredData != null) {
            List<PieChartSectionData> yearexpensessection = [];
            double totalAmount = 0;
            List<yearexpense> expenses = [];

            for (var categoryData in filteredData) {
              final incomeItem = yearexpense.fromJson(categoryData);
              totalAmount += incomeItem.amount;
              expenses.add(incomeItem);
              yearexpenses.add(incomeItem);

              final section = PieChartSectionData(
                value: incomeItem.amount.toDouble(),
                color: getRandomColor(),
                title: '${incomeItem.category}',
                radius: 100,
              );
              yearexpensessection.add(section);
            }

            final expenseData = PieChartSectionData(
              value: totalAmount.toDouble(),
              color: getRandomColor(),
              title: 'Monthly Expense',
              radius: 100,
            );

            setState(() {
              this.yearexpensessection = sections;
            });

            return expenses;
          }
        }
      }

      throw Exception('Failed to fetch expense data');
    } catch (e) {
      print("error fetching monthly expense data: $e");
      throw Exception('Failed to fetch expense data: $e');
    }
  }

  Widget buildExpenseOverview() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Container(
          width: 650,
          height: 490,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 50,
                blurRadius: 3,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Expenses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 11, 11, 11),
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 390,
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: weekexpensessection,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Monthly Expenses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 11, 11, 11),
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 390,
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Yearly Expenses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 390,
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: yearexpensessection,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Income data retrival///////////////////////////////////////////////////////////////////////
  Future<List<WeekIncome>> fetchWeekIncomeData(String accessToken) async {
    try {
      final url = "http://10.0.2.2:8000/core/income-category-week/";
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['filtered'] != null) {
          final dynamic filteredData = responseData['filtered'];
          // print('incomes week_____+$filteredData');
          if (filteredData != null) {
            List<PieChartSectionData> sections = [];
            double totalAmount = 0;
            List<WeekIncome> expenses = [];
            // List<WeekIncome> weekincome = [];

            for (var categoryData in filteredData) {
              final incomeItem = WeekIncome.fromJson(categoryData);
              totalAmount += incomeItem.amount;
              expenses.add(incomeItem);
              weekincome.add(incomeItem);
              // print(weekincome);
              final section = PieChartSectionData(
                value: incomeItem.amount.toDouble(),
                color: getRandomColor(),
                title: '${incomeItem.category}',
                radius: 100,
              );
              sections.add(section);
            }

            final expenseData = PieChartSectionData(
              value: totalAmount.toDouble(),
              color: getRandomColor(),
              title: 'Weekly Income',
              radius: 100,
            );

            setState(() {
              this.weekincomesection = sections;
            });

            return expenses;
          }
        }
      }

      throw Exception('Failed to weekly income data');
    } catch (e) {
      print("error fetching weekly income data: $e");
      throw Exception('Failed to weekly income data: $e');
    }
  }

  Future<List<MonthIncome>> fetchMonthIncomeData(String accessToken) async {
    try {
      final url = "http://10.0.2.2:8000/core/income-category-month/";
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['filtered'] != null) {
          final dynamic filteredData = responseData['filtered'];
          // print('income months_____+$filteredData');
          if (filteredData != null) {
            List<PieChartSectionData> sections = [];
            double totalAmount = 0;
            List<MonthIncome> expenses = [];
            // List<MonthIncome> monthincome = [];

            for (var categoryData in filteredData) {
              final incomeItem = MonthIncome.fromJson(categoryData);
              totalAmount += incomeItem.amount;
              expenses.add(incomeItem);
              monthincome.add(incomeItem);

              final section = PieChartSectionData(
                value: incomeItem.amount.toDouble(),
                color: getRandomColor(),
                title: '${incomeItem.category}',
                radius: 100,
              );
              sections.add(section);
            }

            final expenseData = PieChartSectionData(
              value: totalAmount.toDouble(),
              color: getRandomColor(),
              title: 'Monthly Income',
              radius: 100,
            );

            setState(() {
              this.incomesections = sections;
            });

            return expenses;
          }
        }
      }

      throw Exception('Failed to monthly income data');
    } catch (e) {
      print("error fetching monthly income data: $e");
      throw Exception('Failed to fetch monthly income data: $e');
    }
  }

  Future<List<YearIncome>> fetchYearlyIncomeData(String accessToken) async {
    try {
      final url = "http://10.0.2.2:8000/core/income-category-year/";
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['filtered'] != null) {
          final dynamic filteredData = responseData['filtered'];
          // print('income year_____+$filteredData');
          if (filteredData != null) {
            List<PieChartSectionData> yearexpensessection = [];
            double totalAmount = 0;
            List<YearIncome> expenses = [];
            // List<YearIncome> yearincome = [];
            for (var categoryData in filteredData) {
              final incomeItem = YearIncome.fromJson(categoryData);
              totalAmount += incomeItem.amount;
              expenses.add(incomeItem);
              yearincome.add(incomeItem);
              // print("$yearincome");

              final section = PieChartSectionData(
                value: incomeItem.amount.toDouble(),
                color: getRandomColor(),
                title: '${incomeItem.category}',
                radius: 100,
              );
              yearexpensessection.add(section);
            }

            final expenseData = PieChartSectionData(
              value: totalAmount.toDouble(),
              color: getRandomColor(),
              title: 'Yearly Income',
              radius: 100,
            );

            setState(() {
              this.yearincomesection = sections;
            });

            return expenses;
          }
        }
      }

      throw Exception('Failed to fetch yearly income data');
    } catch (e) {
      print("error fetching yearly income data: $e");
      throw Exception('Failed to fetch yearly income data: $e');
    }
  }

  Widget buildIncomeOverview() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Container(
          width: 590,
          height: 490,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 50,
                blurRadius: 3,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Expenses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 11, 11, 11),
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 390,
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: weekincomesection,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Monthly Expenses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 11, 11, 11),
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 390,
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: incomesections,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Yearly Expenses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 390,
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: yearincomesection,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIncomeReport() {
    double totalAmount = 0.0;
    if (weekincome.isNotEmpty) {
      totalAmount = weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }
    double totalmonthAmount = 0.0;
    if (monthincome.isNotEmpty) {
      totalmonthAmount =
          weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }
    double totalyearAmount = 0.0;
    if (yearincome.isNotEmpty) {
      totalyearAmount =
          weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (incomeweek) ...[
                  Text("${incomename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Last 7 Days"),
                  const SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Income"),
                        Text("Amount"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(weekincome.length, (index) {
                        final income = weekincome[index];
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        income.category,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 120),
                                      Text(
                                        income.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total"),
                      Text("${totalAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  //  totalAmount
                  const SizedBox(height: 80),

                  TextButton.icon(
                      onPressed: () async{
                        await fetchWeekIncomeData(widget.accessToken);
                        await exportincomeweekdataToCsv(weekincome);
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ],
                if (incomeMonth) ...[
                  Text("${incomename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("This Month "),
                  const SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Income"),
                        Text("Amount"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(monthincome.length, (index) {
                        final income = monthincome[index];
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        income.category,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 120),
                                      Text(
                                        income.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total"),
                      Text("${totalmonthAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  //  totalAmount
                  const SizedBox(height: 80),
                  TextButton.icon(
                      onPressed: () {
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ],
                if (incomeyear) ...[
                  Text("${incomename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("This Year"),
                  const SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Income"),
                        Text("Amount"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(yearincome.length, (index) {
                        final income = yearincome[index];
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        income.category,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 120),
                                      Text(
                                        income.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total"),
                      Text("${totalyearAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  //  totalAmount
                  const SizedBox(height: 80),
                  TextButton.icon(
                      onPressed: () {
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ]
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Monthly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_sharp),
            label: 'Yearly',
          ),
        ],
        currentIndex:
            currentIndex, // Set the current index of the selected item
        selectedItemColor: button, // Customize the selected item color
        unselectedItemColor: Colors.white,
        onTap: (int index) {
          // Handle navigation item tap
          // You can navigate to different screens based on the selected index
          // For example:
          if (index == 0) {
            setState(() {
              incomeweek = true;
              incomeMonth = false;
              incomeyear = false;
              incomename = "Week";
              currentIndex = index;
            });
          } else if (index == 1) {
            setState(() {
              incomeweek = false;
              incomeMonth = true;
              incomeyear = false;
              incomename = "Month";
              currentIndex = index;
            });
          } else if (index == 2) {
            setState(() {
              incomeweek = false;
              incomeMonth = false;
              incomeyear = true;
              incomename = "Year";
              currentIndex = index;
            });
          }
        },
      ),
    );
  }

 

  Widget buildBudgetReport() {
    double totalweekIncome = 0.0;
    double totalweekExpense = 0.0;

    double totalmonthIncome = 0.0;
    double totalmonthExpense = 0.0;

    double totalyearIncome = 0.0;
    double totalyearExpense = 0.0;
    if (weekincome.isNotEmpty) {
      totalweekIncome =
          weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }

    if (weekexpenses.isNotEmpty) {
      totalweekExpense =
          weekexpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    }

    if (monthincome.isNotEmpty) {
      totalmonthIncome =
          monthincome.fold(0.0, (sum, income) => sum + income.amount);
    }

    if (monthexpense.isNotEmpty) {
      totalmonthExpense =
          monthexpense.fold(0.0, (sum, expense) => sum + expense.amount);
    }
    if (yearincome.isNotEmpty) {
      totalyearIncome =
          yearincome.fold(0.0, (sum, income) => sum + income.amount);
    }

    if (yearexpenses.isNotEmpty) {
      totalyearExpense =
          yearexpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (expenseweek) ...[
                  Text("${expensename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Last 7 Days"),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Income"),
                            Text("Amount"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 8),
                        child: Divider(
                          thickness: 0.8,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(weekincome.length, (index) {
                          final income = weekincome[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          income.category,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(width: 120),
                                        Text(
                                          income.amount.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Expense"),
                            Text("Amount"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 8),
                        child: Divider(
                          thickness: 0.8,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(weekexpenses.length, (index) {
                          final expense = weekexpenses[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          expense.category,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(width: 120),
                                        Text(
                                          expense.amount.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total Income"),
                      Text("${totalweekIncome.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total Expense"),
                      Text("${totalweekExpense.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Net Cash Flow"),
                      Text(
                          "${(totalweekIncome - totalweekExpense).toStringAsFixed(2)}"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextButton.icon(
                      onPressed: () {
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ],
                if (expenseMonth) ...[
                  Text("${expensename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("This Month"),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Income"),
                            Text("Amount"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 8),
                        child: Divider(
                          thickness: 0.8,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(monthincome.length, (index) {
                          final income = monthincome[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          income.category,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(width: 120),
                                        Text(
                                          income.amount.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Expense"),
                            Text("Amount"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 8),
                        child: Divider(
                          thickness: 0.8,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(monthexpense.length, (index) {
                          final expense = monthexpense[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          expense.category,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(width: 120),
                                        Text(
                                          expense.amount.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total Income"),
                      Text("${totalmonthIncome.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total Expense"),
                      Text("${totalmonthExpense.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Net Cash Flow"),
                      Text(
                          "${(totalmonthIncome - totalmonthExpense).toStringAsFixed(2)}"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextButton.icon(
                      onPressed: () {
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ],
                if (expenseyear) ...[
                  Text("${expensename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("This Year"),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Income"),
                            Text("Amount"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 8),
                        child: Divider(
                          thickness: 0.8,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(yearincome.length, (index) {
                          final income = yearincome[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          income.category,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(width: 120),
                                        Text(
                                          income.amount.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Expense"),
                            Text("Amount"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 8),
                        child: Divider(
                          thickness: 0.8,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(yearexpenses.length, (index) {
                          final expense = yearexpenses[index];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          expense.category,
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(width: 120),
                                        Text(
                                          expense.amount.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total Income"),
                      Text("${totalyearIncome.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total Expense"),
                      Text("${totalyearExpense.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Net Cash Flow"),
                      Text(
                          "${(totalyearIncome - totalyearExpense).toStringAsFixed(2)}"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextButton.icon(
                      onPressed: () {
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ]
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Monthly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_sharp),
            label: 'Yearly',
          ),
        ],
        currentIndex:
            currentIndex, // Set the current index of the selected item
        selectedItemColor: button, // Customize the selected item color
        unselectedItemColor: Colors.white, // Customize the selected item color
        onTap: (int index) {
          // Handle navigation item tap
          // You can navigate to different screens based on the selected index
          // For example:
          if (index == 0) {
            setState(() {
              expenseweek = true;
              expenseMonth = false;
              expenseyear = false;
              expensename = "Week";
              currentIndex = index;
            });
          } else if (index == 1) {
            setState(() {
              expenseweek = false;
              expenseMonth = true;
              expenseyear = false;
              expensename = "Month";
              currentIndex = index;
            });
          } else if (index == 2) {
            setState(() {
              expenseweek = false;
              expenseMonth = false;
              expenseyear = true;
              expensename = "Year";
              currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget buildExpenseReport() {
    double totalAmount = 0.0;
    if (weekexpenses.isNotEmpty) {
      totalAmount = weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }
    double totalmonthAmount = 0.0;
    if (monthexpense.isNotEmpty) {
      totalmonthAmount =
          weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }
    double totalyearAmount = 0.0;
    if (yearexpenses.isNotEmpty) {
      totalyearAmount =
          weekincome.fold(0.0, (sum, income) => sum + income.amount);
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (expenseweek) ...[
                  Text("${expensename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Last 7 Days"),
                  const SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Expense"),
                        Text("Amount"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(weekexpenses.length, (index) {
                        final income = weekexpenses[index];
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        income.category,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 120),
                                      Text(
                                        income.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total"),
                      Text("${totalAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  //  totalAmount
                  const SizedBox(height: 80),
                  TextButton.icon(
                      onPressed: () async {
                        await fetchWeekExpenseData(widget.accessToken);
                        await exportweekexpensedataToCsv(weekexpenses);
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ],
                if (expenseMonth) ...[
                  Text("${expensename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("This Month "),
                  const SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Expense"),
                        Text("Amount"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(monthexpense.length, (index) {
                        final income = monthexpense[index];
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        income.category,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 120),
                                      Text(
                                        income.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total"),
                      Text("${totalmonthAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  //  totalAmount
                  const SizedBox(height: 80),
                  TextButton.icon(
                      onPressed: () async {
                        
                        await exportmonthexpensedataToCsv(monthexpense);
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ],
                if (expenseyear) ...[
                  Text("${expensename} Report"),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("This Year"),
                  const SizedBox(height: 30),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Expense"),
                        Text("Amount"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(yearexpenses.length, (index) {
                        final income = yearexpenses[index];
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        income.category,
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 120),
                                      Text(
                                        income.amount.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 8),
                    child: Divider(
                      thickness: 0.8,
                      color: black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total"),
                      Text("${totalyearAmount.toStringAsFixed(2)}"),
                    ],
                  ),
                  //  totalAmount
                  const SizedBox(height: 80),
                  TextButton.icon(
                      onPressed: () {
                        // Add your functionality here
                        // For example, export data to Excel
                      },
                      icon: Icon(Icons.book_outlined),
                      label: Text("Export To Excel"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return button; // Color when the button is pressed
                          }
                          return button; // Default color
                        }),
                      ))
                ]
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Monthly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_sharp),
            label: 'Yearly',
          ),
        ],
        currentIndex:
            currentIndex, // Set the current index of the selected item
        selectedItemColor: button, // Customize the selected item color
        unselectedItemColor: Colors.white, // Color for unselected item
        onTap: (int index) {
          // Handle navigation item tap
          // You can navigate to different screens based on the selected index
          // For example:
          if (index == 0) {
            setState(() {
              expenseweek = true;
              expenseMonth = false;
              expenseyear = false;
              expensename = "Week";
              currentIndex = index;
            });
          } else if (index == 1) {
            setState(() {
              expenseweek = false;
              expenseMonth = true;
              expenseyear = false;
              expensename = "Month";
              currentIndex = index;
            });
          } else if (index == 2) {
            setState(() {
              expenseweek = false;
              expenseMonth = false;
              expenseyear = true;
              expensename = "Year";
              currentIndex = index;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
            color: const Color.fromARGB(255, 51, 50, 50),
            child: Column(
              children: <Widget>[
                TabBar(
                  indicator: BoxDecoration(color: Colors.grey[600]),
                  indicatorColor: white,
                  unselectedLabelColor: white,
                  controller: _tabController,
                  tabs: widget.outerTab == 'Budget'
                      ? const <Widget>[
                          Tab(text: 'Overview'),
                        ]
                      : const <Widget>[
                          Tab(text: 'Overview'),
                          Tab(text: 'Reports'),
                        ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // Overview Tab
                      Card(
                        child: Center(
                          child: widget.outerTab == 'Expenses'
                              ? buildExpenseOverview()
                              : widget.outerTab == 'Incomes' &&
                                      _tabController.index == 0
                                  ? buildIncomeOverview()
                                  : widget.outerTab == 'Budget' &&
                                          _tabController.index == 0
                                      ? buildBudgetReport()
                                      : Container(),
                        ),
                      ),

                      // Specifications Tab
                      Card(
                        margin: const EdgeInsets.all(16.0),
                        child: Center(
                          child: widget.outerTab == 'Expenses'
                              ? buildExpenseReport()
                              : widget.outerTab == 'Incomes'
                                  ? buildIncomeReport()
                                  : Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
