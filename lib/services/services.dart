import 'dart:convert';

import 'package:caffe_pandawa/models/MainCashBalance.dart';
import 'package:caffe_pandawa/services/auth_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Services {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final AuthServices authServices = AuthServices();

  final String baseUrl = "https://944165fd4976.ngrok-free.app/api";

  Future<Map<String, String>> getAuthHeaders() async {
    String? authToken = await storage.read(key: '_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    print(authToken);

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  Future<MainCashBalance> fetchMainCashBalance() async {
    final headers = await getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/main-cash-balance'),
      headers: headers,
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    print(responseData);
    if (response.statusCode == 200) {
      final data = responseData['data'];

      return MainCashBalance.fromJson(data);
    } else {
      throw Exception('Error nih');
    }
  }

  Future<void> depositToMainCash(
      double amount, String description, int userId) async {
    final headers = await getAuthHeaders();

    try {
      final response = await http.post(
        // GANTI ENDPOINT SESUAI API LARAVEL ANDA!
        // Contoh: '/main-cash-balance/deposit' atau '/main-cash-movement'
        Uri.parse('$baseUrl/main-cash-movement'),
        headers: headers,
        body: jsonEncode({
          'transaction_type':
              'DEPOSIT', // Sesuai dengan enum atau tipe transaksi Anda
          'amount': amount,
          'description': description.isEmpty
              ? 'Deposit saldo'
              : description, // Pastikan deskripsi tidak kosong
          'main_cash_balance_id':
              1, // GANTI dengan ID main_cash_balance yang ingin diupdate

          'initiated_by_user_id': userId,
          'reference_id': userId,
        }),
      );

      print('Deposit Saldo Status Code: ${response.statusCode}');
      print('Deposit Saldo Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Deposit berhasil. Tidak perlu mengembalikan data jika hanya update.
        // Anda bisa mengembalikan boolean atau pesan sukses jika diperlukan.
      } else {
        String errorMessage =
            'Gagal menambah saldo. Status: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorJson = jsonDecode(response.body);
            errorMessage +=
                ' - ${errorJson['message'] ?? 'Kesalahan tidak diketahui'}';
          } catch (e) {
            errorMessage += ' - ${response.body}';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error deposit to main cash: $e');
      rethrow;
    }
  }
}
