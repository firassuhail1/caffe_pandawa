import 'dart:convert';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class EOQServices {
  final Services services = Services();

  Future<List<Map<String, dynamic>>> fetchRawMaterialsForEOQ() async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/get-product-for-pembelian"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return (jsonData['data'] as List)
          .map((json) => Map<String, dynamic>.from(json))
          .toList();
    } else {
      throw Exception("Gagal mengambil bahan baku untuk EOQ");
    }
  }

  Future<bool> saveEOQSetting(Map<String, dynamic> data) async {
    final headers = await services.getAuthHeaders();
    final response = await http.post(
      Uri.parse("${services.baseUrl}/eoq-settings"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Gagal menyimpan EOQ: ${response.body}");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllEOQ() async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/all-eoq"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return (jsonData['data'] as List)
          .map((json) => Map<String, dynamic>.from(json))
          .toList();
    } else {
      throw Exception("Gagal mengambil data EOQ");
    }
  }

  Future<Map<String, dynamic>> calculateEOQ(int rawMaterialId) async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/calculate-eoq/$rawMaterialId"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Map<String, dynamic>.from(jsonData['data']);
    } else {
      throw Exception("Gagal menghitung ulang EOQ");
    }
  }
}
