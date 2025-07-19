import 'dart:convert';
import 'package:caffe_pandawa/models/CashierSession.dart';
import 'package:caffe_pandawa/services/auth_services.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CashierSessionServices {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final Services services = Services();
  final AuthServices authServices = AuthServices();

  static const String _cashierSessionKey = '_cashier_session';

  /// Fungsi untuk menyimpan data sesi kasir ke FlutterSecureStorage
  Future<void> _saveCashierSession(Map<String, dynamic> sessionData) async {
    await storage.write(
      key: _cashierSessionKey,
      value: jsonEncode(sessionData), // Simpan sebagai string JSON
    );
    print('Cashier session saved to secure storage: $sessionData');
  }

  /// Fungsi untuk mengambil data sesi kasir dari FlutterSecureStorage
  Future<Map<String, dynamic>?> getCashierSession() async {
    String? sessionJson = await storage.read(key: _cashierSessionKey);
    if (sessionJson != null && sessionJson.isNotEmpty) {
      try {
        return jsonDecode(sessionJson);
      } catch (e) {
        print('Error decoding cashier session from storage: $e');
        return null;
      }
    }
    return null;
  }

  /// Fungsi untuk menghapus data sesi kasir dari FlutterSecureStorage (saat shift ditutup atau logout)
  Future<void> deleteCashierSession() async {
    await storage.delete(key: _cashierSessionKey);
    print('Cashier session deleted from secure storage.');
  }

  // Fungsi `startingCashAmount` yang sudah dimodifikasi
  Future<Map<String, dynamic>> startCashier(String startingCashAmount) async {
    final headers = await services.getAuthHeaders();
    final user = await authServices.getUser();

    var url = Uri.parse('${services.baseUrl}/cashier-session');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'user_id': user.id,
          'starting_cash_amount': startingCashAmount,
        }),
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 200 OK atau 201 Created
        Map<String, dynamic> responseData = json.decode(response.body);

        print(responseData['data']);
        // Pastikan ada data sesi kasir yang dikembalikan dari backend
        if (responseData['data'] != null &&
            responseData['data']['id'] != null) {
          // *** SIMPAN DATA SESI KASIR KE SECURE STORAGE DI SINI ***
          await _saveCashierSession(responseData['data']);
          return {
            'success': true,
            'message': 'Berhasil melakukan buka kasir.',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': 'Respons dari server tidak valid (data sesi kosong).'
          };
        }
      } else {
        // Tangani error dari server (misal: validasi gagal, user sudah ada sesi aktif)
        String errorMessage =
            'Gagal melakukan buka kasir. Status: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage =
                errorData['message']; // Ambil pesan error dari backend jika ada
          }
        } catch (e) {
          // ignore
        }
        print(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Error during startingCashAmount API call: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> endCashier(
      int cashierSessionId, String endingCashAmount) async {
    final headers = await services.getAuthHeaders();
    final cashier_session = await getCashierSession();

    var url = Uri.parse(
        '${services.baseUrl}/cashier-session/${cashier_session?['id']}');

    try {
      final response = await http.delete(
        url,
        body: jsonEncode({
          'ending_cash_amount': endingCashAmount,
        }),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Berhasil melakukan tutup kasir.',
          'cash_difference': responseData['cash_difference'],
        };
      } else {
        print(response.body);
        return {'success': false};
      }
    } catch (e) {
      print('Error during startingCashAmount API call: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> cashIn(
      String cashIn, String description, String type) async {
    final headers = await services.getAuthHeaders();
    final user = await authServices.getUser();
    final cashier_session = await getCashierSession();

    var url = Uri.parse('${services.baseUrl}/cash-movement');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'cashier_session_id': cashier_session?['id'],
          'user_id': user.id,
          'type': type,
          'amount': cashIn,
          'description': description,
        }),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 200 OK atau 201 Created
        Map<String, dynamic> responseData = json.decode(response.body);

        return {
          'success': true,
          'message': 'Berhasil melakukan buka kasir.',
          'data': responseData['data'],
        };
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print('Error during startingCashAmount API call: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  Future<List<CashierSession>> fetchCashierSession() async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse("${services.baseUrl}/cashier-session"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<CashierSession> loadedCashierSessions =
          (jsonData['data'] as List)
              .map((json) => CashierSession.fromJson(json))
              .toList();

      return loadedCashierSessions;
    } else {
      throw Exception("Failed to load CashierSessions");
    }
  }
}
