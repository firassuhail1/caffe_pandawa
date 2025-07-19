import 'dart:convert';
import 'package:caffe_pandawa/models/TransaksiItem.dart';

class Transaksi {
  final int id;
  final List<TransaksiItem> daftarBarang;
  final double totalBayar;
  final double jumlahBayar;
  final double kembalian;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaksi({
    required this.id,
    required this.daftarBarang,
    required this.totalBayar,
    required this.jumlahBayar,
    required this.kembalian,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    List<TransaksiItem> items = [];
    try {
      final List<dynamic> decodedItems = jsonDecode(json['daftar_barang']);
      items = decodedItems.map((item) => TransaksiItem.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing daftar_barang: $e');
    }

    return Transaksi(
      id: json['id'],
      daftarBarang: items,
      totalBayar: double.parse(json['total_amount']),
      jumlahBayar: double.tryParse(json['amount_paid']) ?? 0,
      kembalian: double.tryParse(json['change_amount']) ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
