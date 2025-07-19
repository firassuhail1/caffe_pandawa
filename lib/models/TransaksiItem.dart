class TransaksiItem {
  final String namaProduct;
  final int harga;
  final int quantity;
  final int totalHarga;

  TransaksiItem({
    required this.namaProduct,
    required this.harga,
    required this.quantity,
    required this.totalHarga,
  });

  factory TransaksiItem.fromJson(Map<String, dynamic> json) {
    return TransaksiItem(
      namaProduct: json['nama_product'],
      harga: json['harga'],
      quantity: json['quantity'],
      totalHarga: json['totalHarga'],
    );
  }
}
