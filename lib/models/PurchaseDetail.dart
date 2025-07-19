class PurchaseDetail {
  final int id;
  final int purchaseId;
  final int itemId;
  final String itemType; // 'product' atau 'raw_material'
  final double quantity;
  final double unitCost;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> item;

  PurchaseDetail({
    required this.id,
    required this.purchaseId,
    required this.itemId,
    required this.itemType,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    required this.item,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    final itemTypeMap = {
      'App\\Models\\Tenant\\Product': 'Produk Jadi',
      'App\\Models\\Tenant\\RawMaterial': 'Bahan Baku',
    };

    Map<String, dynamic> data = {
      'nama': json['item']['name'],
      'unit_of_measure': json['item']['unit_of_measure'],
      'item_type': itemTypeMap[json['item_type']] ?? 'Tipe Tidak Dikenal',
    };

    return PurchaseDetail(
      id: json['id'],
      purchaseId: json['purchase_id'],
      itemId: json['item_id'],
      itemType: json['item_type'],
      quantity: double.parse(json['quantity']),
      unitCost: double.parse(json['unit_cost']),
      subtotal: double.parse(json['subtotal']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      item: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'item_id': itemId,
      'item_type': itemType,
      'quantity': quantity,
      'unit_cost': unitCost,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
