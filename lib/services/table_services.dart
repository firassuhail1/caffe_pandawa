// lib/services/table_service.dart
import 'dart:convert';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class TableService {
  final Services services = Services();

  // READ: Mengambil daftar meja
  Future<List<dynamic>> fetchTables() async {
    final response = await http.get(Uri.parse('${services.baseUrl}/tables'));
    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat meja');
    }
  }

  // CREATE: Menambah meja baru
  Future<http.Response> createTable(String tableNumber) async {
    final url = Uri.parse('${services.baseUrl}/tables');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'table_number': tableNumber,
    });
    return http.post(url, headers: headers, body: body);
  }

  // UPDATE: Mengupdate meja
  Future<http.Response> updateTable(int tableId, String newTableNumber) async {
    final url = Uri.parse('${services.baseUrl}/tables/$tableId');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'table_number': newTableNumber});
    return http.put(url, headers: headers, body: body);
  }

  // DELETE: Menghapus meja
  Future<http.Response> deleteTable(int tableId) async {
    final url = Uri.parse('${services.baseUrl}/tables/$tableId');
    return http.delete(url);
  }
}
