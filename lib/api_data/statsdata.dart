class income {
  final int id;
  final int user_id;
  final int category_id;
  final String category_name;
  final String date;
  final double amount;
  final String note;
  // final String iconUrl;

  income({
    required this.id, 
    required this.user_id,
    required this.category_id,
    required this.category_name,
    required this.date,
    required this.amount,
    required this.note, 
    // required this.iconUrl
    });

  factory income.fromJson(Map<String, dynamic> json) {
    return income(
      id: json['id'],
      user_id:json['user'],
      category_id:json['incCategory'],
      category_name: json['incCategory_name'],
      date:json['created_Date'].toString(),
      amount:json['amount'],
      note:json["note"],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String iconUrl;

  Category({
    required this.id, 
    required this.name, 
    required this.iconUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      iconUrl: json['image_url'],
    );
  }
}

class expense {
  final int id;
  final int user;
  final String name;
  final String note;
  final double amount;
  final String date;
  final int category_id;
  final String category_name;
  // final String iconUrl;
//  "id": 1,
//  "user": 2,
//  "name": "Monthly rent",
//  "note": "monthly rent paid to the landlord.",
//  "amount": 15000.0,
//  "created_date": "2023-07-04",
//  "exCategory": null
  expense({
    required this.id,
  required this.user,
  required this.name,
  required this.note,
  required this.amount,
  required this.date,
  required this.category_id,
  required this.category_name,
    });

  factory expense.fromJson(Map<String, dynamic> json) {
    return expense(
      id: json['id'],
      user:json['user'],
      name: json['name'],
       note:json["note"],
      amount:json['amount'],
       date: json['created_date'] != null ? json['created_date'].toString() : '',
      category_id:json['exCategory'],
      category_name:json['exCategory_name']
     
    );
  }
}