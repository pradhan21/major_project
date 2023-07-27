class UserProfile {
  final String email;
  final String username;
  final String fName;
  final String lName;
  final String dateOfBirth;
  final String phone;

  UserProfile({
    required this.email,
    required this.username,
    required this.fName,
    required this.lName,
    required this.dateOfBirth,
    required this.phone,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'],
      username: json['username'],
      fName: json['fName'],
      lName: json['lName'],
      dateOfBirth: json['date_of_birth'],
      phone: json['phone'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String iconUrl;

  Category({required this.id, required this.name, required this.iconUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      iconUrl: json['image_url'],
    );
  }
}

class ExpCategory {
  final int id;
  final String name;
  final String iconUrl;

  ExpCategory({required this.id, required this.name, required this.iconUrl});

  factory ExpCategory.fromJson(Map<String, dynamic> json) {
    return ExpCategory(
      id: json['id'],
      name: json['name'],
      iconUrl: json['image_url'],
    );
  }
}

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
      user_id: json['user'],
      category_id: json['incCategory'],
      category_name: json['incCategory_name'],
      date: json['created_Date'].toString(),
      amount: json['amount'],
      note: json["note"],
    );
  }
}

class expense {
  final int id;
  final int user_id;
  final String name;
  final String note;
  final double amount;
  final String date;
  final int categoryid;
  final String categoryname;
  //"id": 4,
  // "user": 9,
  // "name": "asdasa",
  // "note": "sdasd",
  // "amount": 15000.0,
  // "created_date": "2023-07-07",
  // "exCategory": 32,
  // "exCategory_name": "Clothing"
  expense({
    required this.id,
    required this.user_id,
    required this.name,
    required this.note,
    required this.amount,
    required this.date,
    required this.categoryid,
    required this.categoryname,
  });

  factory expense.fromJson(Map<String, dynamic> json) {
    return expense(
      id: json['id'],
      user_id: json['user'],
      name: json['name'],
      note: json["note"],
      amount: json['amount'],
      date: json['created_date'].toString(),
      categoryid: json['exCategory'],
      categoryname: json['exCategory_name'],
    );
  }
}

class Limit {
  final int id;
  final double amount;
  final int categoryId;

  Limit({required this.id, required this.amount, required this.categoryId});

  factory Limit.fromJson(Map<String, dynamic> json) {
    return Limit(
      id: json['id'],
      amount: json['category_limit'],
      categoryId: json['expenses_Category'],
    );
  }
}

class Limits {
  final int id;
  final double amount;

  Limits({required this.id, required this.amount});

  factory Limits.fromJson(Map<String, dynamic> json) {
    return Limits(
      id: json['id'],
      amount: json['overall_limit'],
    );
  }
}
