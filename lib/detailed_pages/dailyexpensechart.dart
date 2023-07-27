import 'package:flutter/material.dart';
import 'package:advisor_ui/detailed_data/dailyexpense.dart';
class IncomeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  IncomeChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
    );
  }
List<charts.Series<Income, String>> _createSampleData() {
  final data = [
    Income('Category 1', 5000),
    Income('Category 2', 3000),
    Income('Category 3', 2000),
    Income('Category 4', 4000),
  ];

  return [
    charts.Series<Income, String>(
      id: 'Incomes',
      domainFn: (Income income, _) => income.category,
      measureFn: (Income income, _) => income.amount,
      data: data,
    )
  ];
}


}
class Income {
  final String category;
  final int amount;

  Income(this.category, this.amount);
}

