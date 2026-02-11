class Transaction {
  final String id;
  final double amount;
  final String merchant;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String status;
  final String? receiptUrl;
  final bool isRecurring;
  final bool isAutoDetected; // True if detected from SMS
  final String? referenceNumber; // SMS transaction reference
  final double? confidenceScore; // AI categorization confidence (0-1)

  Transaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.status = 'completed',
    this.receiptUrl,
    this.isRecurring = false,
    this.isAutoDetected = false,
    this.referenceNumber,
    this.confidenceScore,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      merchant: json['merchant'] ?? 'Unknown',
      category: json['category'] ?? 'Others',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? 'Other',
      status: json['status'] ?? 'completed',
      receiptUrl: json['receiptUrl'],
      isRecurring: json['isRecurring'] ?? false,
      isAutoDetected: json['isAutoDetected'] ?? false,
      referenceNumber: json['referenceNumber'],
      confidenceScore: (json['confidenceScore'] is num) ? (json['confidenceScore'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'receiptUrl': receiptUrl,
      'isRecurring': isRecurring,
      'isAutoDetected': isAutoDetected,
      'referenceNumber': referenceNumber,
      'confidenceScore': confidenceScore,
    };
  }
}