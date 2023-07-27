class expense {
  final String date;
  final String startDate;
  final String endDate;
  final String category;
  final double amount;

  expense({
    required this.date,
    required this.startDate,
    required this.endDate,
    required this.category, 
    required this.amount,
  });

  factory expense.fromJson(Map<String, dynamic> json) {
    return expense(
      date:json['Date'].toString(),
      startDate: json['Start Date'].toString(),
      endDate:json['End Date'].toString(),
      category: json['exCategory'],
      amount: json['amount'],
    );
  }
}

class weekexpense {
  final String date;
  final String startDate;
  final String endDate;
  final String category;
  final double amount;

  weekexpense({
    required this.date,
    required this.startDate,
    required this.endDate,
    required this.category, 
    required this.amount,
  });

  factory weekexpense.fromJson(Map<String, dynamic> json) {
    return weekexpense(
      date:json['Date'].toString(),
      startDate: json['Start Date'].toString(),
      endDate:json['End Date'].toString(),
      category: json['exCategory'],
      amount: json['amount'],
    );
  }
}

class yearexpense {
  final String date;
  final String category;
  final double amount;

  yearexpense({
    required this.date,
    required this.category, 
    required this.amount,
  });

  factory yearexpense.fromJson(Map<String, dynamic> json) {
    return yearexpense(
      date:json['Date'].toString(),
      category: json['exCategory'],
      amount: json['amount'],
    );
  }
}
