// models/cashier_recap.dart
import 'package:caffe_pandawa/models/CashMovement.dart';
import 'package:caffe_pandawa/models/Transaksi.dart';
import 'package:caffe_pandawa/models/User.dart';
import 'package:flutter/material.dart'; // Untuk Color
import 'package:intl/intl.dart'; // Untuk format mata uang

class CashierSession {
  final int id; // ID dari database (int)
  final User user; // Foreign ID ke user
  final List<Transaksi>? transaksi; // Foreign ID ke transaksi
  final List<CashMovement>? cashMovement; // Foreign ID ke transaksi
  final DateTime shiftStartTime;
  final DateTime? shiftEndTime; // Nullable
  final double startingCashAmount;
  final double? endingCashAmount; // Nullable
  final double? totalSalesCash; // Nullable
  final double? totalSalesEWallet; // Nullable
  final double? totalSalesTransferBank; // Nullable
  final double? totalSalesQris; // Nullable
  final double? totalSalesGerai; // Nullable
  final double? totalCashIn; // Nullable
  final double? totalCashOut; // Nullable
  final String? notes; // Nullable
  final double? cashDifference; // Nullable
  final String status; // 'open', 'closed', 'abandoned'
  final DateTime createdAt;
  final DateTime updatedAt;

  CashierSession({
    required this.id,
    required this.user,
    this.transaksi,
    this.cashMovement,
    required this.shiftStartTime,
    this.shiftEndTime,
    required this.startingCashAmount,
    this.endingCashAmount,
    this.totalSalesCash,
    this.totalSalesEWallet,
    this.totalSalesTransferBank,
    this.totalSalesQris,
    this.totalSalesGerai,
    this.totalCashIn,
    this.totalCashOut,
    this.notes,
    this.cashDifference,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor untuk membuat objek CashierSession dari JSON (Map)
  factory CashierSession.fromJson(Map<String, dynamic> json) {
    // Helper untuk mengkonversi string DateTime menjadi DateTime? (nullable)
    DateTime? parseDateTime(String? dateTimeString) {
      if (dateTimeString == null) return null;
      return DateTime.parse(dateTimeString)
          .toLocal(); // Pastikan toLocal() jika server kirim UTC
    }

    // Helper untuk mengkonversi string atau int/double ke double?
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return null;
    }

    final List<dynamic>? transaksiJson =
        json['transaksi']; // Ambil data transaksi dari JSON
    final List<dynamic>? cashMovementJson =
        json['cash_movement']; // Ambil data transaksi dari JSON

    return CashierSession(
      id: json['id'] as int,
      user: User.fromJson(json['user']),
      transaksi: transaksiJson !=
              null // Cek apakah data transaksi ada dan tidak null
          ? transaksiJson
              .map((tJson) => Transaksi.fromJson(tJson as Map<String, dynamic>))
              .toList()
          : null, // Jika null, properti transactions juga null
      cashMovement: cashMovementJson !=
              null // Cek apakah data transaksi ada dan tidak null
          ? cashMovementJson
              .map((tJson) =>
                  CashMovement.fromJson(tJson as Map<String, dynamic>))
              .toList()
          : null, // Jika null, properti cash movement juga null
      shiftStartTime:
          DateTime.parse(json['shift_start_time'] as String).toLocal(),
      shiftEndTime: parseDateTime(json['shift_end_time'] as String?),
      startingCashAmount: parseDouble(json['starting_cash_amount']) ?? 0.0,
      endingCashAmount: parseDouble(json['ending_cash_amount']),
      totalSalesCash: parseDouble(json['total_sales_cash']),
      totalSalesEWallet: parseDouble(json['total_sales_e_wallet']),
      totalSalesTransferBank: parseDouble(json['total_sales_transfer_bank']),
      totalSalesQris: parseDouble(json['total_sales_qris']),
      totalSalesGerai: parseDouble(json['total_sales_gerai']),
      totalCashIn: parseDouble(json['total_cash_in']),
      totalCashOut: parseDouble(json['total_cash_out']),
      notes: json['notes'] as String?,
      cashDifference: parseDouble(json['cash_difference']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  // Getter untuk selisih dalam format mata uang
  String get formattedCashDifference {
    if (cashDifference == null) return 'Rp0';
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(cashDifference!.abs());
  }

  // Getter untuk warna selisih
  Color get cashDifferenceColor {
    if (cashDifference == null) return Colors.grey;
    if (cashDifference! > 0) {
      return Colors.green; // Surplus
    } else if (cashDifference! < 0) {
      return Colors.red; // Defisit
    } else {
      return Colors.grey; // Sesuai
    }
  }

  // Getter untuk mendapatkan tanggal shift (tanpa waktu)
  DateTime get shiftDateOnly =>
      DateTime(shiftStartTime.year, shiftStartTime.month, shiftStartTime.day);
}
