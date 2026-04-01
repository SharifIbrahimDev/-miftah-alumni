class MonthlyContribution {
  final int id;
  final int userId;
  final String userName;
  final double amount;
  final String month;
  final String status;
  final String recordedByName;
  final DateTime createdAt;

  MonthlyContribution({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.month,
    required this.status,
    required this.recordedByName,
    required this.createdAt,
  });

  bool get isPaid => status == 'paid';

  factory MonthlyContribution.fromJson(Map<String, dynamic> json) {
    return MonthlyContribution(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user']['name'],
      amount: double.parse(json['amount'].toString()),
      month: json['month'],
      status: json['status'],
      recordedByName: json['recorder']['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Project {
  final int id;
  final String name;
  final String description;
  final double targetAmount;
  final double raisedAmount;
  final int createdBy;
  final String createdByName;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.raisedAmount,
    required this.createdBy,
    required this.createdByName,
  });

  double get progress => raisedAmount / targetAmount;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetAmount: double.parse(json['target_amount'].toString()),
      raisedAmount: double.parse(json['total_contributed']?.toString() ?? '0'),
      createdBy: json['created_by'],
      createdByName: json['creator']['name'],
    );
  }
}

class Expense {
  final int id;
  final String description;
  final double amount;
  final String category;
  final String recordedByName;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.recordedByName,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: double.parse(json['amount'].toString()),
      category: json['category'],
      recordedByName: json['recorder']?['name'] ?? 'System',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
