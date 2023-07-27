import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../detailed_data/dailyexpense.dart';
import '../detailed_data/detailedincome.dart';

//  List<weekexpense> weekexpenses = [];
//   List<expense> monthexpense = [];
//   List<yearexpense> yearexpenses = [];

  // List<WeekIncome> weekincome = [];
  // List<MonthIncome> monthincome = [];
  // List<YearIncome> yearincome = [];
Future<void> exportincomeweekdataToCsv( List<WeekIncome> weekincomes ) async {
 List<List<dynamic>> rows = [];

  // Add the "Weekly Report" heading with starting and ending dates
  for(var data in weekincomes){
  rows.add(['Weekly Report', data.startDate, data.endDate]);
  }
  rows.add([]); // Add an empty row for spacing

  // Add CSV header row (column names)
  rows.add(['Serial No.''Category Name', 'Category Total']);

  // Add data rows
  for (int i = 0; i < weekincomes.length; i++) {
    var data = weekincomes[i];
    rows.add([i + 1, data.category, data.amount]);
  }

  // Get the application's documents directory to save the CSV file
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String csvFilePath = '${appDocumentsDirectory.path}/week_income_report.csv';

  // Convert data to CSV format and save it to a file
  File csvFile = File(csvFilePath);
  String csvData = const ListToCsvConverter().convert(rows);
  await csvFile.writeAsString(csvData);

  print('CSV file saved at: $csvFilePath');
}


Future<void> exportweekexpensedataToCsv( List<weekexpense> weekexpenses ) async {
 List<List<dynamic>> rows = [];

  // Add the "Weekly Report" heading with starting and ending dates
  for(var data in weekexpenses){
  rows.add(['Weekly Report', data.date]);
  }
  rows.add([]); // Add an empty row for spacing

  // Add CSV header row (column names)
  rows.add(['Serial No.''Category Name', 'Category Total']);

  // Add data rows
  for (int i = 0; i < weekexpenses.length; i++) {
    var data = weekexpenses[i];
    rows.add([i + 1, data.category, data.amount]);
  }

  // Get the application's documents directory to save the CSV file
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String csvFilePath = '${appDocumentsDirectory.path}/WeekExpense_report.csv';

  // Convert data to CSV format and save it to a file
  File csvFile = File(csvFilePath);
  String csvData = const ListToCsvConverter().convert(rows);
  await csvFile.writeAsString(csvData);

  print('CSV file saved at: $csvFilePath');
}


Future<void> exportmonthexpensedataToCsv(List<expense> monthexpense) async {
  List<List<dynamic>> rows = [];

  // Add the "Weekly Report" heading with starting and ending dates
  for (var data in monthexpense) {
    rows.add(['Weekly Report', data.startDate, data.endDate]);
  }
  rows.add([]); // Add an empty row for spacing

  // Add CSV header row (column names)
  rows.add(['Serial No.', 'Category Name', 'Category Total']);

  // Add data rows
  for (int i = 0; i < monthexpense.length; i++) {
    var data = monthexpense[i];
    rows.add([i + 1, data.category, data.amount]);
  }

  // Get the external storage directory to save the CSV file
  Directory? externalDir = await getExternalStorageDirectory();
  if (externalDir == null) {
    print('External storage directory not available.');
    return;
  }
  
  String csvFilePath = '${externalDir.path}/month_expense_report.csv';

  // Convert data to CSV format and save it to a file
  File csvFile = File(csvFilePath);
  String csvData = const ListToCsvConverter().convert(rows);
  await csvFile.writeAsString(csvData);

  print('CSV file saved at: $csvFilePath');
}