class notedata {
  final int note_id;
  final String title;
  final double amount;
  final String discription;
  final String type;
  final String date;
  final String created_date;
  final int user_id;

  notedata(
      {required this.note_id,
      required this.title,
      required this.amount,
      required this.discription,
      required this.type,
      required this.date,
      required this.created_date,
      required this.user_id});

  factory notedata.fromJson(Map<String, dynamic> json) {
    return notedata(
      note_id: json['id'],
      title: json['title'],
      amount: json['amount'],
      discription: json['discription'],
      type: json['type'],
      date: json['date'],
      created_date: json['created_date'],
      user_id: json['user'],
    );
  }
}

class noteamount {
  final double ramount;
  final double pamount;
//  "receivable_amount": 0.0,
//         "payable_amount": 0.0
  noteamount({required this.ramount, required this.pamount});
  factory noteamount.fromJson(Map<String, dynamic> json) {
    return noteamount(
        ramount: json['receivable_amount'], pamount: json['payable_amount']);
  }
}
// id": 1,
//             "title": "Muzi",
//             "amount": 5000.0,
//             "discription": "Paisale machikne",
//             "type": "receivable",
//             "date": "2023-07-19",
//             "created_date": "2023-07-19",
//             "user": 9