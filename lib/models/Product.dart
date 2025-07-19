import 'package:flutter/material.dart';

class Product {
  final int id;
  final String? kodeProduct;
  final String namaProduct;
  final String? image;
  final double harga;
  final double stock;
  double? jmlProductPerBundling;
  String? keterangan;
  double? hargaAsliProduct;
  double? hargaAsliProductBundling;
  double? hargaJualProductBundling;
  double? hargaAsliSebelumnya;
  double? hargaJualSebelumnya;
  bool? status;

  // double? qtyDibeli;
  // double? totalHarga;

  TextEditingController qtyDibeliController;

  Product({
    required this.id,
    this.kodeProduct,
    required this.namaProduct,
    this.image,
    required this.harga,
    required this.stock,
    this.jmlProductPerBundling,
    this.keterangan,
    this.hargaAsliProduct,
    this.hargaAsliProductBundling,
    this.hargaJualProductBundling,
    this.hargaAsliSebelumnya,
    this.hargaJualSebelumnya,
    this.status,
    // this.qtyDibeli,
    // this.totalHarga,
  }) : qtyDibeliController = TextEditingController();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      kodeProduct: json['kode_product'],
      namaProduct: json['nama_product'] ?? "",
      image: json['image'],
      harga: (json['harga'] ?? 0.0).toDouble(),
      stock: (json['stock'] ?? 0.0).toDouble(),
      jmlProductPerBundling:
          (json['jml_product_per_bundling'] ?? 0.0).toDouble(),
      keterangan: json['keterangan'],
      hargaAsliProduct: json['harga_asli_product']?.toDouble(),
      hargaAsliProductBundling: json['harga_asli_product_bundling']?.toDouble(),
      hargaJualProductBundling: json['harga_jual_product_bundling']?.toDouble(),
      hargaAsliSebelumnya: json['harga_asli_sebelumnya']?.toDouble(),
      hargaJualSebelumnya: json['harga_jual_sebelumnya']?.toDouble(),
      status: json['status'] == 0 ? false : true,
      // qtyDibeli: (json['qty_dibeli'] ?? 1).toDouble(),
      // totalHarga: json['total_harga']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_product': kodeProduct,
      'nama_product': namaProduct,
      'image': image,
      'harga': harga,
      'stock': stock,
      'jml_isi_barang': jmlProductPerBundling,
      'keterangan': keterangan,
      // 'qty_dibeli': qtyDibeli,
      // 'total_harga': totalHarga,
      'harga_asli_product': hargaAsliProduct,
      'harga_asli_product_bundling': hargaAsliProductBundling,
      'harga_jual_product_bundling': hargaJualProductBundling,
      'harga_jual_sebelumnya': hargaJualSebelumnya,
      'harga_asli_sebelumnya': hargaAsliSebelumnya,
    };
  }
}
