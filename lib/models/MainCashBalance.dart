class MainCashBalance {
  final int id;
  final String accountName;
  final String accountType;
  final double currentBalance;
  final String currency;
  final String? notes; // Nullable
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MainCashBalance({
    required this.id,
    required this.accountName,
    required this.accountType,
    required this.currentBalance,
    required this.currency,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MainCashBalance.fromJson(Map<String, dynamic> json) {
    return MainCashBalance(
      id: json['id'] as int,
      accountName: json['account_name'] as String,
      accountType: json['account_type'],
      currentBalance:
          double.tryParse(json['current_balance']) ?? 0, // Pastikan double
      currency: json['currency'],
      notes: json['notes'], // Dapat berupa null
      isActive: json['is_active'] == 1 ? true : false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  // Metode untuk mengonversi kembali ke JSON (opsional, jika Anda perlu mengirim data ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_name': accountName,
      'account_type': accountType,
      'current_balance': currentBalance,
      'currency': currency,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
