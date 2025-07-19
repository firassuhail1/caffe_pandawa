import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:caffe_pandawa/services/services.dart';

class LaporanPenjualanServices {
  final Services services = Services();

  Future<Map<String, dynamic>> getLabaKotor(String period) async {
    final headers = await services.getAuthHeaders();
    final String url = "${services.baseUrl}/get-laba-kotor?period=$period";

    try {
      final response = await http.get(
        Uri.parse('$url'),
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final laba_kotor = responseData['data'];
        final message = responseData['message'];

        return {
          'success': true,
          'message': message,
          'laba_kotor': double.tryParse(laba_kotor.toString()),
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil total penjualan',
      };
    } catch (e) {
      print(e);
      return {
        'success': true,
        'message': 'Gagal mengambil total penjualan',
      };
    }
  }

  Future<Map<String, dynamic>> laporanTotalPenjualan(String period) async {
    final headers = await services.getAuthHeaders();
    String url = "";

    url = "${services.baseUrl}/laporan-total-penjualan?period=$period";

    try {
      final response = await http.get(
        Uri.parse('$url'),
        headers: headers,
      );

      print(period);
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final total_penjualan = responseData['data']['total_sales'];
        final total_transaksi = responseData['data']['total_transaksi'];
        final message = responseData['message'];

        return {
          'success': true,
          'message': message,
          'total_penjualan': double.tryParse(total_penjualan.toString()),
          'total_transaksi': total_transaksi,
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil total penjualan',
      };
    } catch (e) {
      print(e);
      return {
        'success': true,
        'message': 'Gagal mengambil total penjualan',
      };
    }
  }

  Future<Map<String, dynamic>> laporanPenjualan(
      String period, DateTime? startDate, DateTime? endDate) async {
    final headers = await services.getAuthHeaders();
    String url = "";

    String? start_date = startDate.toString();
    String? end_date = endDate.toString();

    if (startDate == null) {
      start_date = "";
      end_date = "";
    }

    if (endDate == null) {
      end_date = "";
    }

    url =
        "${services.baseUrl}/laporan-penjualan?period=$period&&start_date=$start_date&&end_date=$end_date";

    try {
      final response = await http.get(
        Uri.parse('$url'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final total_penjualan = responseData['data']['total_sales'];
        final message = responseData['message'];

        final data_penjualan =
            (responseData['data']['data_penjualan'] as List).map((item) {
          final decodedDaftarBarang =
              jsonDecode(item['daftar_barang'] as String) as List<dynamic>;

          return {
            ...item,
            'daftar_barang': List<Map<String, dynamic>>.from(
              decodedDaftarBarang.map(
                (e) => Map<String, dynamic>.from(e),
              ),
            ),
          };
        }).toList();

        final data_ringkasan =
            (responseData['data']['data_ringkasan'] as List).map((item) {
          return {...item as Map<String, dynamic>};
        }).toList();

        print(message);
        print(total_penjualan);
        print(data_penjualan);
        print(data_ringkasan);
        return {
          'success': true,
          'message': message,
          'total_penjualan': double.tryParse(total_penjualan.toString()),
          'data_penjualan': data_penjualan,
          'data_ringkasan': data_ringkasan,
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil total penjualan',
      };
    } catch (e) {
      print(e);
      return {
        'success': true,
        'message': 'Gagal mengambil total penjualan',
      };
    }
  }
}
