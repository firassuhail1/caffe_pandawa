import 'package:caffe_pandawa/models/BahanBaku.dart';

class RecipeIngredient {
  final int? id;
  final int? recipeId;
  final int rawMaterialId;
  final double quantityNeeded; // quantity_needed
  final BahanBaku? rawMaterial; // Untuk eager loading dari Laravel
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeIngredient({
    this.id,
    this.recipeId,
    required this.rawMaterialId,
    required this.quantityNeeded,
    this.rawMaterial, // nullable karena tidak selalu di-load
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    print('Parsing Ingredient');

    return RecipeIngredient(
      id: json['id'],
      recipeId: json['recipe_id'],
      rawMaterialId: json['raw_material_id'],
      quantityNeeded: double.parse(json['quantity_needed']),
      rawMaterial: json['raw_material'] != null
          ? BahanBaku.fromJson(json['raw_material'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'raw_material_id': rawMaterialId,
      'quantity_needed': quantityNeeded,
      'raw_material': rawMaterial?.toJson(), // Kirim toJson jika tidak null
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
