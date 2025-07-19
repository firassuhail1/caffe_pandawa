import 'package:caffe_pandawa/models/PurchaseDetail.dart';

class Purchase {
  final int id;
  final DateTime purchaseDate;
  final String invoiceNumber;
  final double totalAmount;
  final String paymentStatus; // 'lunas' atau 'due_date'
  final DateTime? dueDate;
  final String? notes;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<PurchaseDetail> purchaseDetail;

  Purchase({
    required this.id,
    required this.purchaseDate,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.paymentStatus,
    this.dueDate,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.purchaseDetail,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    List<PurchaseDetail> items = [];
    try {
      final List<dynamic> decodedItems = json['purchase_details'];
      items =
          decodedItems.map((item) => PurchaseDetail.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing purchase_details: $e');
    }

    return Purchase(
      id: json['id'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      invoiceNumber: json['invoice_number'] ?? "",
      totalAmount: double.parse(json['total_amount']),
      paymentStatus: json['payment_status'],
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      notes: json['notes'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      purchaseDetail: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_date': purchaseDate.toIso8601String(),
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'due_date': dueDate?.toIso8601String(),
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
