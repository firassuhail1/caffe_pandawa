import 'dart:convert';
import 'package:caffe_pandawa/models/User.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
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

  final String baseUrl = "http://192.168.137.233:8000/api";

  Future<Map<String, dynamic>> register(
    String storeName,
    String ownerName,
    String jenisToko,
    String alamat,
    String noHp,
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/tenant");

    final response = await http.post(
      url,
      body: jsonEncode({
        'storeName': storeName,
        'ownerName': ownerName,
        'alamat': alamat,
        'noHp': noHp,
        'jenisToko': jenisToko,
        'email': email,
        'password': password,
      }),
      headers: {
        'Accept': 'application/json', // <-- Penting!
        'Content-Type': 'application/json', // Tentukan tipe konten
        // 'Authorization': 'Bearer your_access_token', // Contoh header otorisasi
      },
    );

    Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'],
        'kode_toko': responseData['tenant']['store_code'],
      };
    }

    return {
      'success': false,
      'errors': responseData['message'],
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: {
        'Accept': 'application/json', // <-- Penting!
        'Content-Type': 'application/json', // Tentukan tipe konten
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return {
        'success': true,
        'message': 'Berhasil masuk ke aplikasi.',
        'token': responseData['token_user'],
        'user': responseData['data'],
        'tenant': responseData['tenant'],
      };
    } else if (response.statusCode == 404) {
      return {
        'success': false,
        'message': 'Gagal masuk, periksa kode akses toko anda.'
      };
    } else {
      return {
        'success': false,
        'message': 'Gagal masuk, periksa email dan password anda.'
      };
    }
  }

  // Mengambil data user
  Future<User> getUser() async {
    final String? userJson = await storage.read(key: '_user');

    // Konversi String JSON kembali menjadi Map
    // return jsonDecode(userJson) as Map<String, dynamic>;
    return User.fromJson(jsonDecode(userJson!) as Map<String, dynamic>);
  }

  Future<bool> logout() async {
    final headers = await _getAuthHeaders();

    final url = Uri.parse('$baseUrl/logout');

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        // Logout sukses di server
        await storage.delete(key: '_token');

        print('Logout successful on server and client.');
        return true;
      } else {
        // Handle error jika server gagal mencabut token
        print(
            'Failed to logout on server: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during logout API call: $e');
      // Tangani error jaringan, dll.
      // Hapus token lokal sebagai fallback
      return false;
    }
  }
}
