
// // "Month": "July",
//     "overall_limit": 20000.0,
//     "expenses_total": 18170.0,
//     "limit_diff": -1830.0,
//     "limit_exceeded_percent": 9.15,
//     "budget_status": "Under the budget"

class overalldata {
  final String month;
  final double overall_limit;
  final double overall_total;
  final double limit_left;
  final double limit_used;
  final double percent;
  final double limit_exceeded_by;
  final double limit_exceeded_percent;
  final String budget_status;
 
  overalldata({
    required this.month,
    required this.overall_limit,
    required this.overall_total,
    required this.budget_status,
    required this.limit_left,
    required this.percent,
    required this.limit_used,
    required this.limit_exceeded_by,
    required this.limit_exceeded_percent,
  });

  factory overalldata.fromJson(Map<String, dynamic> json) {
  return overalldata(
    month: json['Month'],
    overall_limit: (json['overall_limit'] as num?)?.toDouble() ?? 0.0,
    overall_total: (json['expenses_total'] as num?)?.toDouble() ?? 0.0,
    limit_left: (json['limit_Left'] as num?)?.toDouble() ?? 0.0,
    limit_used: (json['Limit_used'] as num?)?.toDouble() ?? 0.0,
    percent: (json['limit_used_percent'] as num?)?.toDouble() ?? 0.0,
    limit_exceeded_by: (json['limit_exceeded_by'] as num?)?.toDouble() ?? 0.0,
    limit_exceeded_percent: (json['limit_exceeded_percent'] as num?)?.toDouble() ?? 0.0,
    budget_status: json['budget_status'],
  );
}

}


class categorydata {
  final String month;
  final String category_name;
  final double category_limit;
  final double category_expenses_total;
  final double category_limit_Left;
  final double category_limit_used;
  final double category_limit_used_percent;
  final double category_limit_Exceeded;
  final double category_limit_exceeded_percent;
  final String budget_status;
 
  categorydata({
    required this.month,
    required this.category_name,
    required this.category_limit,
    required this.category_expenses_total,
    required this.category_limit_Left,
    required this.category_limit_used,
    required this.category_limit_used_percent,
    required this.category_limit_Exceeded,
    required this.category_limit_exceeded_percent,
    required this.budget_status,

  });

  factory categorydata.fromJson(Map<String, dynamic> json) {
  return categorydata(
    month: json['Month'],
    category_name: json['category_name'] ,
    category_limit: (json['category_limit'] as num?)?.toDouble() ?? 0.0,
    category_expenses_total: (json['category_expenses_total'] as num?)?.toDouble() ?? 0.0,
    category_limit_Left: (json['category_limit_Left'] as num?)?.toDouble() ?? 0.0,
    category_limit_used: (json['category_limit_used'] as num?)?.toDouble() ?? 0.0,
    category_limit_used_percent: (json['category_limit_used_percent'] as num?)?.toDouble() ?? 0.0,
    category_limit_Exceeded: (json['category_limit_Exceeded'] as num?)?.toDouble() ?? 0.0,
    category_limit_exceeded_percent: (json['category_limit_exceeded_percent'] as num?)?.toDouble() ?? 0.0,
    budget_status: json['budget_status'],
  );
}

}


class categorylimit {
  final int cat_id;
  final int user_id;
  final int? category_id;
  final String category_name;
  final double category_limit;


  categorylimit({required this.cat_id, required this.category_limit, required this.category_name,required this.user_id, required this.category_id });

  factory categorylimit.fromJson(Map<String, dynamic> json) {
    return categorylimit(
      cat_id: json['id'],
      user_id: json['user'],
      category_id: json['expenses_category'],
      category_name: json['exCategory_name'],
      category_limit: json['category_limit'], 
    );
  }
}

class overalllimit {
  final int cat_id;
  final int user_id;
  final double overall_limit;


  overalllimit({required this.cat_id, required this.user_id, required this.overall_limit });

  factory overalllimit.fromJson(Map<String, dynamic> json) {
    return overalllimit(
      cat_id: json['id'],
      user_id: json['user'],
      overall_limit: json['overall_limit'], 
    );
  }
}
