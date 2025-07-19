class BahanBakuInventoryBatch {
  final int id;
  final int rawMaterialId;

  final String soruceType;
  final int? soruceId;
  final double quantityIn;
  final double quantityRemaining;
  final double unitCost;
  final DateTime entryDateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  BahanBakuInventoryBatch({
    required this.id,
    required this.rawMaterialId,
    required this.soruceType,
    this.soruceId,
    required this.quantityIn,
    required this.quantityRemaining,
    required this.unitCost,
    required this.entryDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BahanBakuInventoryBatch.fromJson(Map<String, dynamic> json) {
    print('parsing batches');

    try {
      return BahanBakuInventoryBatch(
        id: json['id'],
        rawMaterialId: json['raw_material_id'],
        soruceType: json['source_type'],
        soruceId: json['source_id'] ?? null,
        quantityIn: double.tryParse(json['quantity_in']) ?? 0,
        quantityRemaining: double.tryParse(json['quantity_remaining']) ?? 0,
        unitCost: double.tryParse(json['unit_cost']) ?? 0,
        entryDateTime: DateTime.parse(json['entry_datetime']),
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
      'raw_material_id': rawMaterialId,
      'source_type': soruceType,
      'source_id': soruceId,
      'quantity_in': quantityIn,
      'quantity_remaining': quantityRemaining,
      'unit_cost': unitCost,
      'entry_date': entryDateTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
