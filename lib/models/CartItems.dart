import 'package:caffe_pandawa/models/Product.dart';

class CartItems {
  final Product product;
  double quantity; // Jumlah yang dibeli
  double? totalHarga;
  double? totalBayar;
  // double? uangDibayar = 0;
  // double? kembalian = 0;
  bool isPlusMinusInvisible;

  CartItems({
    required this.product,
    this.quantity = 1,
    required this.totalHarga,
    this.totalBayar,
    required this.isPlusMinusInvisible,
  });

  @override
  String toString() {
    return 'CartItems(product: ${product.namaProduct}, quantity: $quantity, total harga: $totalHarga , total bayar: $totalBayar, $isPlusMinusInvisible)';
  }

  double get totalPrice => product.harga * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
      'totalHarga': totalHarga,
    };
  }
}
