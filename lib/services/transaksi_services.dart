import 'dart:convert';
import 'package:caffe_pandawa/models/CartItems.dart';
import 'package:caffe_pandawa/models/Transaksi.dart';
import 'package:caffe_pandawa/services/auth_services.dart';
import 'package:caffe_pandawa/services/cashier_session_services.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

final Services services = Services();
final CashierSessionServices cashierSessionServices = CashierSessionServices();
final AuthServices authServices = AuthServices();

class TransaksiServices {
  Future<Map<String, dynamic>> fetchTransaksi() async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse('${services.baseUrl}/transaksi'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<dynamic> transaksiData = responseData['data'];
      final List<Transaksi> transaksiList =
          transaksiData.map((item) => Transaksi.fromJson(item)).toList();

      return {
        "success": true,
        "message": "Berhasil",
        "transaksiList": transaksiList,
      };
    } else {
      return {
        "success": false,
        "message": "Gagal memuat data transaksi",
      };
    }
  }

  Future<bool> pembayaran(List<CartItems>? cartItems, double totalAmout,
      double jumlahBayar, double kembalian) async {
    final headers = await services.getAuthHeaders();
    final cashierSession = await cashierSessionServices.getCashierSession();
    final user = await authServices.getUser();

    final url = Uri.parse('${services.baseUrl}/transaksi');

    final data = {
      "items": cartItems?.map((item) => item.toJson()).toList(),
      "cashier_session_id": cashierSession?["id"],
      "user_id": user.id,
      "total_bayar": totalAmout,
      "jumlah_bayar": jumlahBayar,
      "kembalian": kembalian
    };

    final response = await http.post(
      url,
      body: jsonEncode(data),
      headers: headers,
    );

    print(response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
