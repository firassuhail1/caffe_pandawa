import 'dart:convert';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class BahanBakuServices {
  final Services services = Services();

  Future<List<BahanBaku>> fetchBahanBaku() async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/bahan-baku"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<BahanBaku> loadedProducts = (jsonData['data'] as List)
          .map((json) => BahanBaku.fromJson(json))
          .toList();

      return loadedProducts;
    } else {
      throw Exception("Failed to load bahan baku");
    }
  }

  Future<Map<String, dynamic>> getBahanBakuFromSku(String kodeProduk) async {
    final headers = await services.getAuthHeaders();
    final url = Uri.parse("${services.baseUrl}/sku/$kodeProduk");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (jsonData["data"] != null) {
        return {
          "success": true,
          "kodeProduk": jsonData["data"]["kode_product"],
          "namaProduk": jsonData["data"]["nama_product"],
        };
      } else {
        return {
          "success": false,
        };
      }
    } else {
      return {
        "success": false,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getBahanBaku(int id) async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/bahan-baku/$id"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonData);

      final List<Map<String, dynamic>> loadedBahanBaku =
          (jsonData['data'] as List)
              .map((json) => Map<String, dynamic>.from(json))
              .toList();

      return loadedBahanBaku;
    } else {
      throw Exception("Failed to load bahan baku");
    }
  }

  Future<bool> addBahanBaku(String? kodeProduk, String nama, String satuanUkur,
      double HPP, int minStockAlert, int? outletId, double stock) async {
    final headers = await Services().getAuthHeaders();

    try {
      final response = await http.post(
        Uri.parse('${Services().baseUrl}/bahan-baku'),
        body: jsonEncode({
          'sku': kodeProduk,
          'nama': nama,
          'stock': stock,
          'unit_of_measure': satuanUkur,
          'standart_cost_price': HPP,
          'min_stock_alert': minStockAlert,
          'outlet_id': outletId,
        }),
        headers: headers,
      );

      print(response.body);

      if (response.statusCode == 200) {
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

  Future<bool> editBahanBaku(int id, String? kodeProduk, String nama,
      String satuanUkur, double hargaPembelian, int minStockAlert) async {
    final headers = await Services().getAuthHeaders();

    try {
      final response = await http.put(
        Uri.parse('${Services().baseUrl}/bahan-baku/$id'),
        body: jsonEncode({
          'sku': kodeProduk,
          'nama': nama,
          'unit_of_measure': satuanUkur,
          'cost_price': hargaPembelian,
          'min_stock_alert': minStockAlert,
        }),
        headers: headers,
      );

      if (response.statusCode == 200) {
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

  Future<Map<String, dynamic>> deleteBahanBaku(int id) async {
    final headers = await services.getAuthHeaders();

    final response = await http.delete(
      Uri.parse('${services.baseUrl}/bahan-baku/$id'),
      headers: headers,
    );

    final jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': jsonResponse['message']};
    } else {
      return {'success': false, 'message': jsonResponse['message']};
    }
  }
}
