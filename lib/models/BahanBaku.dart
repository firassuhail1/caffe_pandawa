import 'package:caffe_pandawa/models/BahanBakuInventory.dart';
import 'package:caffe_pandawa/models/BahanBakuInventoryBatch.dart';

class BahanBaku {
  final int id;
  final String? kodeBahanBaku;
  final String namaBahanBaku;
  final String unitOfMeasure;
  final double standartCostPrice;

  final String? image;
  final bool isActive;

  final List<BahanBakuInventory> bahanBakuInventory;
  final List<BahanBakuInventoryBatch> bahanBakuInventoryBatch;

  BahanBaku({
    required this.id,
    this.kodeBahanBaku,
    required this.namaBahanBaku,
    required this.unitOfMeasure,
    required this.standartCostPrice,
    this.image,
    required this.isActive,
    required this.bahanBakuInventory,
    required this.bahanBakuInventoryBatch,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BahanBaku && runtimeType == other.runtimeType && id == other.id;

  factory BahanBaku.fromJson(Map<String, dynamic> json) {
    print('parsing bahan baku');

    List<BahanBakuInventory> items = [];
    try {
      final List<dynamic> decodedItems = json['inventories'];
      items = decodedItems
          .map((item) => BahanBakuInventory.fromJson(item))
          .toList();
    } catch (e) {
      print('Error parsing bahan baku inventories: $e');
    }

    List<BahanBakuInventoryBatch> item_batches = [];
    try {
      final List<dynamic> decodedItems = json['batches'];
      item_batches = decodedItems
          .map((item) => BahanBakuInventoryBatch.fromJson(item))
          .toList();
    } catch (e) {
      print('Error parsing bahan baku batches: $e');
    }

    return BahanBaku(
      id: json['id'] ?? 0,
      kodeBahanBaku: json['sku'],
      namaBahanBaku: json['nama'] ?? "",
      unitOfMeasure: json['unit_of_measure'] ?? "",
      standartCostPrice: double.parse(json['standart_cost_price']),

      image: json['image'],
      isActive: json['is_active'] == 1 ? true : false,
      bahanBakuInventory:
          items, // kenapa list, karna satu bahan baku bisa memiliki beberapa inventory dari beberapa outlet
      bahanBakuInventoryBatch: item_batches,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': kodeBahanBaku,
      'nama': namaBahanBaku,
      'unit_of_measure': unitOfMeasure,
      'standart_cost_price': standartCostPrice,
    };
  }
}
