import 'package:caffe_pandawa/models/OrderItem.dart';

class Order {
  final int id;
  final String orderNumber;
  final String? paymentMethod;
  final String statusPembayaran;
  final String statusPesanan;
  final double grandTotal;
  final String orderSource;
  final String? tableNumber;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    this.paymentMethod,
    required this.statusPembayaran,
    required this.statusPesanan,
    required this.grandTotal,
    required this.orderSource,
    this.tableNumber,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    print('parsing orders');

    var list = json['items'] as List;
    List<OrderItem> orderItemsList =
        list.map((i) => OrderItem.fromJson(i)).toList();

    print('end of parsing order item');

    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      paymentMethod: json['payment_method'],
      statusPembayaran: json['status_pembayaran'],
      statusPesanan: json['status_pesanan'],
      grandTotal: double.parse(json['grand_total']),
      orderSource: json['order_source'],
      tableNumber: json['table_number'],
      items: orderItemsList,
    );
  }
}
