import 'dart:convert';

import 'package:caffe_pandawa/models/Order.dart';
import 'package:caffe_pandawa/services/order_services.dart';
import 'package:flutter/foundation.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  Order? _selectedOrder;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  Order? get selectedOrder => _selectedOrder;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await OrderService().fetchPendingOrders();
    } catch (e) {
      print('Error fetching orders: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getOrderDetail(String orderNumber) async {
    _isLoading = true;
    notifyListeners();
    // Ambil detail order dari API
    final response = await OrderService().getOrderDetail(orderNumber);
    final responseData = json.decode(response.body);

    _selectedOrder = Order.fromJson(responseData['data']);

    try {
      _orders = await OrderService().fetchPendingOrders();
    } catch (e) {
      print('Error fetching orders: $e');
    }

    _isLoading = false;

    notifyListeners();
  }

  void selectOrder(Order? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearSelection() {
    _selectedOrder = null;
    notifyListeners();
  }
}
