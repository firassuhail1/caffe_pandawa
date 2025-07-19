import 'dart:convert';
import 'dart:io';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

final Services services = Services();

class ProductServices {
  Future<List<Product>> fetchProducts(String tipe) async {
    final headers = await services.getAuthHeaders();

    if (tipe == "for-list") headers["TIPE"] = "for-list";
    if (tipe == "for-kasir") headers["TIPE"] = "for-kasir";

    final response = await http.get(
      Uri.parse("${services.baseUrl}/products"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<Product> loadedProducts = (jsonData['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();

      return loadedProducts;
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<Product> getProduct(String id) async {
    final headers = await services.getAuthHeaders();
    final url = Uri.parse("${services.baseUrl}/products/$id");

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      return Product.fromJson(jsonData['data']);
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<Map<String, dynamic>> getProductFromSku(String kodeProduk) async {
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

  Future<List<Product>> getProducibleProducts() async {
    try {
      final baseUrl = Services().baseUrl;
      final headers = await Services().getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/products/producible'),
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = (data['data'] as List)
            .map((item) => Product.fromJson(item))
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

  Future<bool> addProduct({
    required String kodeProduk,
    required String namaProduk,
    required String hargaProduk,
    required String stock,
    required String jmlProdukPerBundling,
    required bool status,
    File? image,
  }) async {
    final headers = await services.getAuthHeaders();
    try {
      var uri = Uri.parse('${services.baseUrl}/products');
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan data form biasa
      request.fields['kode_product'] = kodeProduk;
      request.fields['nama_product'] = namaProduk;
      request.fields['harga'] = hargaProduk.replaceAll('.', '');
      request.fields['stock'] = stock.replaceAll('.', '');
      request.fields['jml_product_per_bundling'] =
          jmlProdukPerBundling.replaceAll('.', '');
      request.fields['status'] = status ? '1' : '0';

      // Tambahkan file jika ada
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: image.path.split('/').last,
        ));
      }

      // Tambahkan headers jika perlu
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // final responseBody = json.decode(response.body);
        print("Berhasil: ${response.body}");
        // bisa gunakan responseBody untuk feedback
        return true;
      } else {
        print("Gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> editProduct({
    required int id,
    required String namaProduk,
    required String kodeProduk,
    required String hargaProduk,
    required String stock,
    required String hpp,
    required String hargaProdukBundling,
    required String jmlProdukPerBundling,
    required bool status,
    File? image,
  }) async {
    final headers = await services.getAuthHeaders();

    try {
      var uri = Uri.parse('${services.baseUrl}/products/$id');
      var request = http.MultipartRequest('POST', uri);

      // kebutuhan method untuk rute resources
      request.fields['_method'] = 'PUT'; // <--- penting untuk Laravel!

      // Tambahkan data form biasa
      request.fields['nama_product'] = namaProduk;
      request.fields['kode_product'] = kodeProduk;
      request.fields['harga'] = hargaProduk.replaceAll('.', '');
      request.fields['stock'] = stock.replaceAll('.', '');
      request.fields['harga_asli_product'] = hpp.replaceAll('.', '');
      request.fields['harga_jual_product_bundling'] =
          hargaProdukBundling.replaceAll('.', '');
      request.fields['jml_product_per_bundling'] =
          jmlProdukPerBundling.replaceAll('.', '');
      request.fields['status'] = status ? '1' : '0';

      // Tambahkan file jika ada
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: image.path.split('/').last,
        ));
      }

      // Tambahkan headers jika perlu
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // final responseBody = json.decode(response.body);
        print("Berhasil: ${response.body}");
        // bisa gunakan responseBody untuk feedback
        return true;
      } else {
        print("Gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final headers = await services.getAuthHeaders();

    final response = await http.delete(
      Uri.parse('${services.baseUrl}/products/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return {'success': true, 'message': jsonResponse['message']};
    } else {
      return {'success': false};
    }
  }

  Future<bool> editStatusProduct(int id, bool status) async {
    final headers = await services.getAuthHeaders();

    final response = await http.put(
      Uri.parse('${services.baseUrl}/products/$id'),
      body: jsonEncode({
        'id': id,
        'status': status,
      }),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
