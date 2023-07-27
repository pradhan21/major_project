class WeekIncome {
  final String startDate;
  final String endDate;
  final String category;
  final double amount;

   String toString() {
    return 'WeekIncome(category: $category, amount: $amount)';
  }
  WeekIncome({
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.amount,
  });

  factory WeekIncome.fromJson(Map<String, dynamic> json) {
    return WeekIncome(
      startDate: json['Start Date'].toString(),
      endDate: json['End Date'].toString(),
      category: json['incCategory'],
      amount: json['amount'],
    );
  }
}


class MonthIncome {
  final String startDate;
  final String endDate;
  final String category;
  final double amount;

  MonthIncome({
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.amount,
  });

  factory MonthIncome.fromJson(Map<String, dynamic> json) {
    return MonthIncome(
      startDate: json['Start Date'].toString(),
      endDate: json['End Date'].toString(),
      category: json['incCategory'],
      amount: json['amount'],
    );
  }
}

class YearIncome {
  final String startDate;
  final String endDate;
  final String category;
  final double amount;

  YearIncome({
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.amount,
  });

  factory YearIncome.fromJson(Map<String, dynamic> json) {
    return YearIncome(
      startDate: json['Start Date'].toString(),
      endDate: json['End Date'].toString(),
      category: json['incCategory'],
      amount: json['amount'],
    );
  }
}
