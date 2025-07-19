import 'package:caffe_pandawa/models/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashMovement {
  final int id;
  final User user;
  final String type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  CashMovement({
    required this.id,
    required this.user,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashMovement.fromJson(Map<String, dynamic> json) {
    return CashMovement(
      id: json['id'],
      user: User.fromJson(json['user']),
      type: json['type'],
      amount: double.parse(json['amount']),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Getter untuk warna berdasarkan tipe
  Color get typeColor {
    return type != 'out' ? Colors.green : Colors.red;
  }

  // Getter untuk ikon berdasarkan tipe
  IconData get typeIcon {
    return type == 'out' ? Icons.arrow_circle_up : Icons.arrow_circle_down;
  }

  // Getter untuk prefix teks
  String get typePrefix {
    return type != 'out' ? '+' : '-';
  }

  // Getter untuk format mata uang
  String get formattedAmount {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }
}
