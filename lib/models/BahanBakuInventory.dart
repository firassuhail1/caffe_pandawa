class BahanBakuInventory {
  final int id;
  final String locationType;
  final double costPrice;
  final double stock;
  final double minStockAlert;
  final double? stockAllocated;
  final DateTime createdAt;
  final DateTime updatedAt;

  BahanBakuInventory({
    required this.id,
    required this.locationType,
    required this.costPrice,
    required this.stock,
    required this.minStockAlert,
    required this.stockAllocated,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BahanBakuInventory.fromJson(Map<String, dynamic> json) {
    print('parsing bahan baku inventory');

    try {
      return BahanBakuInventory(
        id: json['id'] ?? 0,
        locationType: json['location_type'] ?? "",
        costPrice: double.parse(json['cost_price']),
        stock: double.parse(json['current_stock']),
        minStockAlert: double.parse(json['min_stock_alert']),
        stockAllocated: json['quantity_allocated'] != null
            ? double.parse(json['quantity_allocated'].toString())
            : 0,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    } catch (e, stackTrace) {
      print(stackTrace);
      throw Exception(e);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'raw_material_id': bahanBaku.id,
      'location_type': locationType,
      'cost_price': costPrice,
      'current_stock': stock,
      'quantity_allocated': stockAllocated,
      'min_stock_alert': minStockAlert,
    };
  }
}
