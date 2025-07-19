import 'dart:convert';
import 'package:caffe_pandawa/models/Purchase.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class PembelianServices {
  final Services services = Services();

  Future<List<Purchase>> getDataPembelian(
      String period, DateTime? startDate, DateTime? endDate) async {
    final headers = await services.getAuthHeaders();

    try {
      final response = await http.get(
        Uri.parse(
            "${services.baseUrl}/get-data-pembelian?period=$period&&start_date=$startDate&&end_date=$endDate"),
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List<Purchase> loadedProducts = (jsonData['data'] as List)
            .map((json) => Purchase.fromJson(json))
            .toList();

        return loadedProducts;
      } else {
        throw Exception("Failed to load data pembelian");
      }
    } catch (e) {
      print(e);
      throw Exception("Failed to load data pembelian");
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductForPembelian() async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/get-product-for-pembelian"),
      headers: headers,
    );

    print('ini adalah produk yg producible');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<Map<String, dynamic>> loadedProducts =
          (jsonData['data'] as List)
              .map((json) => Map<String, dynamic>.from(json))
              .toList();

      return loadedProducts;
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<bool> saveProduct(
    DateTime purchaseDate,
    String invoiceNumber,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) async {
    final headers = await Services().getAuthHeaders();

    print("items : $items");
    try {
      final response = await http.post(
        Uri.parse('${Services().baseUrl}/buat-pembelian'),
        body: jsonEncode({
          'purchase_date': purchaseDate.toIso8601String(),
          'invoice_number': invoiceNumber,
          'total_amount': totalAmount,
          'items': items,
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
}
