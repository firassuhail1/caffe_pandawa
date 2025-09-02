class OrderItem {
  final int id;
  final int orderId;
  final int? productId;
  final String productName;
  final String? sku;
  final int qty;
  final double unitPrice;
  final double discount;
  final double tax;
  final double totalPrice;
  final String? notes;

  OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.sku,
    required this.qty,
    required this.unitPrice,
    required this.discount,
    required this.tax,
    required this.totalPrice,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    print('parsing order item');

    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      sku: json['sku'],
      qty: json['qty'],
      unitPrice: double.parse(json['unit_price'].toString()),
      discount: double.parse(json['discount'].toString()),
      tax: double.parse(json['tax'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      notes: json['notes'],
    );
  }
}
