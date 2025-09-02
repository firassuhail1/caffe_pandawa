import 'dart:convert';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class MenuService {
  final Services services = Services();

  Future<List<Product>> fetchMenu() async {
    final headers = await services.getAuthHeaders();

    headers['TIPE'] = 'for-kasir';

    final response = await http.get(
      Uri.parse('${services.baseUrl}/menu'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      print(response.body);

      throw Exception(response.body);
    }
  }
}
