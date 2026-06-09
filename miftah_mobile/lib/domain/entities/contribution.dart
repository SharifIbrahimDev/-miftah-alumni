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
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      userName: json['user']?['name'] ?? 'Unknown',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
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
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0.0,
      raisedAmount: double.tryParse(json['contributions_sum_amount']?.toString() ?? '0') ?? 0.0,
      createdBy: int.tryParse(json['created_by']?.toString() ?? '0') ?? 0,
      createdByName: json['creator']?['name'] ?? 'Unknown',
    );
  }
}

class Expense {
  final int id;
  final String description;
  final double amount;
  final String type;
  final String recordedByName;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.recordedByName,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      type: json['type'] ?? 'debit',
      recordedByName: json['recorder']?['name'] ?? 'System',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ProjectContribution {
  final int id;
  final int projectId;
  final int userId;
  final String userName;
  final double amount;
  final DateTime createdAt;

  ProjectContribution({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.createdAt,
  });

  factory ProjectContribution.fromJson(Map<String, dynamic> json) {
    return ProjectContribution(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user']?['name'] ?? 'Unknown User',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class PaymentClaim {
  final int id;
  final int userId;
  final String userName;
  final double amount;
  final String type; // 'monthly' or 'project'
  final String referenceId; // month (e.g. 'JAN 2026') or projectId
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  PaymentClaim({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.type,
    required this.referenceId,
    required this.status,
    required this.createdAt,
  });

  factory PaymentClaim.fromJson(Map<String, dynamic> json) {
    return PaymentClaim(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user']?['name'] ?? 'Unknown User',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? 'monthly',
      referenceId: json['reference_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
