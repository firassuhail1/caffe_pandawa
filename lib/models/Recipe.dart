import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/models/RecipeIngredient.dart';

class Recipe {
  final int? id;
  final int productId;
  final String? name;
  final String? description;
  final bool isActive; // is_active
  final Product? product; // Untuk eager loading dari Laravel
  final List<RecipeIngredient>? ingredients; // Untuk eager loading dari Laravel
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    this.id,
    required this.productId,
    this.name,
    this.description,
    required this.isActive,
    this.product, // nullable karena tidak selalu di-load
    this.ingredients, // nullable karena tidak selalu di-load
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    print('Parsing Recipe');

    try {
      List<RecipeIngredient>? ingredientsList;
      if (json['ingredients'] != null) {
        ingredientsList = (json['ingredients'] as List)
            .map((i) => RecipeIngredient.fromJson(i))
            .toList();
      } else {
        ingredientsList = null;
      }

      return Recipe(
        id: json['id'],
        productId: json['product_id'],
        name: json['name'],
        description: json['description'],
        isActive: json['is_active'] == 1 ||
            json['is_active'] == true, // Handle boolean from int or bool
        ingredients: ingredientsList,
        product:
            json['product'] != null ? Product.fromJson(json['product']) : null,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    } catch (e, stackTrace) {
      print("Error parsing Recipe: $e");
      print("Stack trace: $stackTrace");
      throw e;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'description': description,
      'is_active': isActive,
      'product': product?.toJson(), // Kirim toJson jika tidak null
      'ingredients':
          ingredients?.map((i) => i.toJson()).toList(), // Kirim list toJson
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
