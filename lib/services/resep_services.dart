import 'dart:convert';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/models/Recipe.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class ResepServices {
  static Future<List<Recipe>> getRecipes() async {
    try {
      final baseUrl = Services().baseUrl;
      final headers = await Services().getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/recipes'),
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = (data['data'] as List)
            .map((item) => Recipe.fromJson(item))
            .toList();

        return responseData;
      } else {
        throw Exception('Error status code');
      }
    } catch (e) {
      print(e);
      throw Exception('kesalahan server');
    }
  }

  static Future<List<BahanBaku>> getRawMaterials() async {
    try {
      final baseUrl = Services().baseUrl;
      final headers = await Services().getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/bahan-baku'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = (data['data'] as List)
            .map((item) => BahanBaku.fromJson(item))
            .toList();

        return responseData;
      } else {
        throw Exception('Error status code');
      }
    } catch (e) {
      print(e);
      throw Exception('kesalahan server');
    }
  }

  static Future<bool> createRecipe(Recipe recipe) async {
    final headers = await Services().getAuthHeaders();

    try {
      final response = await http.post(
        Uri.parse('${Services().baseUrl}/recipes'),
        body: jsonEncode(recipe),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      print(e);
      throw Exception('kesalahan server');
    }
  }

  static Future<bool> updateRecipe(int recipeId, Recipe recipe) async {
    final headers = await Services().getAuthHeaders();
    print("resep id : $recipeId");
    print("resep : $recipe");
    try {
      final response = await http.put(
        Uri.parse('${Services().baseUrl}/recipes/$recipeId'),
        body: jsonEncode(recipe),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      print(e);
      throw Exception('kesalahan server');
    }
  }
}
