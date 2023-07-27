import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:advisor_ui/json/day_month.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:advisor_ui/widget/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 
import '../api_data/statsdata.dart';


class StatsPage extends StatefulWidget {
  final String accessToken;
   final List<double> dataPoints = [20, 30, 50];
  StatsPage({required this.accessToken});
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime currentDate = DateTime.now(); // Get the current date
  List<DateTime> visibleDates = [];
  List<PieChartSectionData> sections = [];
  List<income> incomes = [];
  List<expense> expenses = [];
  int activeDay = 3;
  Timer? timer;
  bool showAvg = false;
  double totalIncome = 0.0;

  Color _getincomeCategoryColor(String categoryName) {
  // Define a color mapping based on category name
  Map<String, Color> categoryColors = {
    'Allowance': Colors.blue,
    'Salary': Colors.green,
    'Others': Colors.red,
    // Add more categories as needed
  };

  // Return the corresponding color for each category
  // If the category is not found in the map, return a default color
  return categoryColors[categoryName] ?? Colors.grey;
}

 Color _getexpenseCategoryColor(String categoryName) {
  // Define a color mapping based on category name
  Map<String, Color> categoryColors = {
    'Allowance': Colors.blue,
    'Salary': Colors.green,
    'Others': Colors.red,
    // Add more categories as needed
  };

  // Return the corresponding color for each category
  // If the category is not found in the map, return a default color
  return categoryColors[categoryName] ?? Colors.grey;
}

  void goToPreviousDates() {
    setState(() {
      currentDate = currentDate.subtract(Duration(days: 30));
    });
  }

  void goToFutureDates() {
    setState(() {
      currentDate = currentDate.add(Duration(days: 30));
    });
  }


  void updateVisibleDates() {
    visibleDates.clear();
    for (int i = 0; i < 4; i++) {
      DateTime date = currentDate.add(Duration(days: i));
      visibleDates.add(date);
    }
  }
void initState() {
  super.initState();
  for (int i = 0; i < 30; i++) {
    DateTime date = currentDate.add(Duration(days: i));
    visibleDates.add(date);
  }
  // Timer.periodic(Duration(seconds: 1), (_) =>  fetchIncomes(widget.accessToken));
  fetchIncomes(widget.accessToken);
  // Fetch initial data
}

Future<void> fetchIncomes(String accessToken) async {
  final url = 'http://10.0.2.2:8000/income/income/';

  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $accessToken',
  });

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final categoriesData = jsonData['results'];

    if (categoriesData != null) {
      // Calculate total income
      double totalIncome = 0;
      List<income> fetchedIncomes = [];

      for (var categoryData in categoriesData) {
        final incomeItem = income.fromJson(categoryData);
        totalIncome += incomeItem.amount;
        fetchedIncomes.add(incomeItem); // Add income item to the list
      }

      // Create a single data point for total income
      final totalIncomeData = PieChartSectionData(
        value: totalIncome,
        color: Colors.blue, // Set color for total income
        title: 'Total Income',
        radius: 100,
      );

      setState(() {
        sections = [totalIncomeData];
        incomes = fetchedIncomes; 
        totalIncome = totalIncome;// Update the incomes list
      });
    }
  } else {
    throw Exception('Failed to fetch incomes. Status code: ${response.statusCode}');
  }
}

Future<void> fetchexpense(String accessToken) async {
  final url = 'http://10.0.2.2:8000/expenses/expenses/';

  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $accessToken',
  });

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final categoriesData = jsonData['results'];

    if (categoriesData != null) {
      // Calculate total income
      double totalIncome = 0;
      List<income> fetchedIncomes = [];

      for (var categoryData in categoriesData) {
        final incomeItem = income.fromJson(categoryData);
        totalIncome += incomeItem.amount;
        fetchedIncomes.add(incomeItem); // Add income item to the list
      }

      // Create a single data point for total income
      final totalIncomeData = PieChartSectionData(
        value: totalIncome,
        color: Colors.blue, // Set color for total income
        title: 'Total Income',
        radius: 100,
      );

      setState(() {
        sections = [totalIncomeData];
        incomes = fetchedIncomes; 
        totalIncome = totalIncome;// Update the incomes list
      });
    }
  } else {
    throw Exception('Failed to fetch incomes. Status code: ${response.statusCode}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;

    List expenses = [
      {
        "icon": Icons.arrow_back,
        "color": blue,
        "label": "Income",
        "cost": "\$6593.75"
      },
      {
        "icon": Icons.arrow_forward,
        "color": red,
        "label": "Expense",
        "cost": "\$2645.50"
      }
    ];
     double totalSum = widget.dataPoints.reduce((value, element) => value + element);


   List<PieChartSectionData> newSections = incomes.map((income) {
  final percentage = income.amount / totalSum;
  final color = _getincomeCategoryColor(income.category_name); // Set color based on category name

  return PieChartSectionData(
    value: percentage,
    color: color,
    title: '${income.category_name}\n${percentage.toStringAsFixed(2)}%',
    radius: 100,
  );
}).toList();




setState(() {
  sections = newSections;
});


    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: black, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 10,
                blurRadius: 3,
                // changes position of shadow
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 50, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed:(){}, icon: Icon(Icons.menu_sharp)),
                      Text(
                        "Stats",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: white),
                      ),
                      Icon(AntDesign.search1, color: white,)
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      
                      IconButton(
                  onPressed: goToPreviousDates,
                  icon: Icon(Icons.arrow_back,color:white),
                ),
                Text(
                   DateFormat(' MMMM, y').format(currentDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
                IconButton(
                  onPressed: goToFutureDates,
                  icon: Icon(Icons.arrow_forward,color: white,),
                ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  // Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: List.generate(visibleDates.length, (index) {
                  //     final DateFormat yearFormat = DateFormat('y'); // Format the day abbreviation
                  //     final DateFormat monthFormat = DateFormat('MMM');

                  //     DateTime date = visibleDates[index];
                  //       bool isCurrentDate = date.day == currentDate.day &&
                  //           date.month == currentDate.month &&
                  //           date.year == currentDate.year;
                  //       return GestureDetector(
                  //         onTap: () {
                  //           setState(() {
                  //             String currentDate = DateFormat('y-M-d').format(date);
                  //           print(currentDate);
                  //             activeDay = index;
                  //           });
                  //         },
                  //         child: Container(
                  //           width: (MediaQuery.of(context).size.width - 40) / 6,
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                 yearFormat.format(visibleDates[index]),
                  //                 style: TextStyle(fontSize: 10),
                  //               ),
                  //               SizedBox(
                  //                 height: 10,
                  //               ),
                  //               Container(
                  //                 decoration: BoxDecoration(
                  //                     color: activeDay == index
                  //                         ? primary
                  //                         : black.withOpacity(0.02),
                  //                     borderRadius: BorderRadius.circular(5),
                  //                     border: Border.all(
                  //                         color: activeDay == index
                  //                             ? primary
                  //                             : black.withOpacity(0.1))),
                  //                 child: Padding(
                  //                   padding: const EdgeInsets.only(
                  //                       left: 12, right: 12, top: 7, bottom: 7),
                  //                   child: Text(
                  //                    monthFormat.format(visibleDates[index]),
                  //                     style: TextStyle(
                  //                         fontSize: 10,
                  //                         fontWeight: FontWeight.w600,
                  //                         color: activeDay == index
                  //                             ? white
                  //                             : black),
                  //                   ),
                  //                 ),
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     }))
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              // color: Colors.grey[850],
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                  color: grey,
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
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Net balance",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "\$2446.90",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: (size.width - 20),
                        height: 150,
                        child: LineChart(
                          mainData(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Wrap(
              spacing: 20,
              children: List.generate(expenses.length, (index) {
                return Container(
                
                  width: (size.width - 60) / 2,
                  height: 170,
                  decoration: BoxDecoration(
                      color: grey,
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
                              color: expenses[index]['color']),
                          child: Center(
                              child: Icon(
                            expenses[index]['icon'],
                            color: white,
                          )),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expenses[index]['label'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Color(0xff67727d)),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              expenses[index]['cost'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              })),
              const SizedBox(height: 30),
            Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 290,
              decoration: BoxDecoration(
                  color: grey,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 50,
                      blurRadius: 3,
                      // changes position of shadow
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Net Income",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Color(0xff67727d)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "\$${totalIncome.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: -15,
                      child: Container(
                        width: (size.width - 20),
                        height: 350,
                        child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 0,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                    ))
                  ],
                ),
              ),
            ),
          ),
              
           SizedBox(
            height: 120,
          ), 
        ],
      ),
    );
  }
}
