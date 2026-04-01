class TransactionRecord {
  final int id;
  final String type; // credit, debit
  final double amount;
  final String description;
  final String recordedByName;
  final DateTime createdAt;

  TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.recordedByName,
    required this.createdAt,
  });

  bool get isDebit => type == 'debit';
  bool get isCredit => type == 'credit';

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'],
      type: json['type'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      recordedByName: json['recorder']['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
