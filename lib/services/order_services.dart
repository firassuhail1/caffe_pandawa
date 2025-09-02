// lib/services/order_service.dart
import 'dart:convert';
import 'package:caffe_pandawa/models/Order.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final Services services = Services();

  Future<http.Response> createOrder(Map<String, dynamic> orderData) async {
    final url = Uri.parse('${services.baseUrl}/orders');
    final headers = await services.getAuthHeaders();
    final body = json.encode(orderData);

    try {
      final response = await http.post(url, headers: headers, body: body);

      return response;
    } catch (e) {
      print(e);
      throw Exception('Gagal membuat pesanan, coba lagi.');
    }
  }

  Future<String> checkPaymentStatus(orderNumber) async {
    final response = await http.get(Uri.parse(
        '${services.baseUrl}/webhook/check-payment-status?order_number=$orderNumber'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['status'] == 'paid') {
        // Redirect ke halaman sukses
        return "paid";
      } else if (data['status'] == 'pending') {
        return 'pending';
      }
    }

    return "cancelled";
  }

  Future<List<Order>> fetchPendingOrders() async {
    final response = await http
        .get(Uri.parse('${services.baseUrl}/orders?status_pembayaran=paid'));

    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return (data['data'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } else {
      throw Exception('Gagal memuat pesanan.');
    }
  }

  Future<http.Response> getOrderDetail(String orderNumber) async {
    final headers = await services.getAuthHeaders();

    final response = await http.get(
      Uri.parse('${services.baseUrl}/orders/$orderNumber'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Gagal memuat pesanan.');
    }
  }

  // Fungsi untuk update status order
  Future<http.Response> updateOrderStatus(
      String orderId, String newStatus) async {
    final headers = await services.getAuthHeaders();

    final url = Uri.parse('${services.baseUrl}/orders/$orderId/status');

    final body = json.encode({'status_pesanan': newStatus});

    return http.put(url, headers: headers, body: body);
  }

  // DELETE: Menghapus order
  Future<http.Response> deleteOrder(int orderId) async {
    final url = Uri.parse('${services.baseUrl}/orders/$orderId');
    return http.delete(url);
  }
}
