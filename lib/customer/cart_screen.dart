// lib/screens/cart_screen.dart
import 'package:caffe_pandawa/customer/qris_payment_screen.dart';
import 'package:caffe_pandawa/providers/cart_provider.dart';
import 'package:caffe_pandawa/services/order_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:saver_gallery/saver_gallery.dart';

// Color constants for brown theme
class AppColors {
  static const Color primary = Color(0xFF8B4513);
  static const Color primaryDark = Color(0xFF654321);
  static const Color secondary = Color(0xFFD2B48C);
  static const Color background = Color(0xFFF5F5DC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFCD853F);
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF5D4037);
}

enum PaymentMethod { cash, qris }

class CartScreen extends StatefulWidget {
  final String tableNumber;
  CartScreen({required this.tableNumber});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _showCustomerInfoDialog(
      BuildContext context, CartProvider cart) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Informasi Customer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama *',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 2),
                          ),
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppColors.accent),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'No. HP (Optional)',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 2),
                          ),
                          prefixIcon: Icon(Icons.phone_outlined,
                              color: AppColors.accent),
                          hintText: 'Contoh: 08123456789',
                          hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text('Batal'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.secondary),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(dialogContext);
                            _showPaymentMethodDialog(context, cart);
                          }
                        },
                        child: Text('Lanjutkan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentMethodDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pilih Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // QRIS Payment Option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _placeOrder(context, cart, PaymentMethod.qris);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.background,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.qr_code,
                              color: Colors.white, size: 28),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QRIS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Scan QR Code untuk pembayaran',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: AppColors.accent, size: 18),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Cash Payment Option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _placeOrder(context, cart, PaymentMethod.cash);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.background,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.money, color: Colors.white, size: 28),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Bayar tunai ke kasir',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: AppColors.accent, size: 18),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.secondary),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Updated _placeOrder method in cart_screen.dart

  Future<void> _placeOrder(BuildContext context, CartProvider cart,
      PaymentMethod paymentMethod) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Mengirim pesanan...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final orderItems = cart.items.values
          .map((item) => {
                'product_id': item.product.id,
                'qty': item.quantity,
              })
          .toList();

      final body = {
        'table_number': widget.tableNumber,
        'order_source': 'qr_table',
        'customer_name': _nameController.text.trim(),
        'customer_phone': _phoneController.text.trim(),
        'payment_method': paymentMethod == PaymentMethod.qris ? 'qris' : 'cash',
        'items': orderItems,
      };

      final response = await OrderService().createOrder(body);

      Navigator.pop(context); // Close loading dialog

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        String paymentType = responseData['payment_info']['payment_type'];
        String qrString = "";
        double grossAmount =
            double.parse(responseData['payment_info']['gross_amount']);

        // Parse expiry time from response
        DateTime expiryTime =
            DateTime.parse(responseData['payment_info']['expiry_time']);

        if (paymentType == 'qris') {
          qrString = responseData['payment_info']['qr_string'];
        }

        final orderId = responseData['order_number'] ?? 'N/A';

        print("qr string: $qrString");
        print("expiry time: $expiryTime");

        String nameCopy = _nameController.text.trim();
        String phoneCopy = _phoneController.text.trim();

        if (paymentMethod == PaymentMethod.qris) {
          // Navigate to QRIS payment screen instead of showing dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRISPaymentScreen(
                cart: cart,
                orderId: orderId,
                paymentMethod: paymentMethod,
                grossAmount: grossAmount,
                qrString: qrString,
                tableNumber: widget.tableNumber,
                customerName: nameCopy,
                customerPhone: phoneCopy,
                expiryTime: expiryTime,
              ),
            ),
          );
        } else {
          // For cash payment, show confirmation directly
          final cartCopy = List.from(cart.items.values);
          final totalAmount = cart.totalAmount;

          _showOrderConfirmation(
              context, cartCopy, totalAmount, orderId, paymentMethod);

          cart.clearCart();
        }

        // Clear form
        _nameController.clear();
        _phoneController.clear();
      } else {
        _showErrorDialog(context, 'Gagal mengirim pesanan. Silakan coba lagi.');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    }
  }

  void _showOrderConfirmation(BuildContext context, List<dynamic> cart,
      double totalAmount, String orderId, PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OrderConfirmationDialog(
          orderId: orderId,
          tableNumber: widget.tableNumber,
          customerName: _nameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          cartItems: cart,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Error',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: cart.itemCount == 0
          ? _buildEmptyCart()
          : _buildCartContent(cart, context),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.accent,
          ),
          SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan item dari menu',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartProvider cart, BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            children: [
              Icon(Icons.table_restaurant, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Meja: ${widget.tableNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (context, index) {
                final item = cart.items.values.toList()[index];
                return _buildCartItem(item, cart);
              },
            ),
          ),
        ),
        _buildOrderSummary(cart, context),
      ],
    );
  }

  Widget _buildCartItem(dynamic item, CartProvider cart) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_cafe,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.namaProduct,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp ${item.product.harga.toStringAsFixed(0)} / item',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Subtotal: Rp ${(item.product.harga * item.quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (item.quantity > 1) {
                            cart.updateQuantity(
                                item.product.id, item.quantity - 1);
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: item.quantity > 1
                                ? AppColors.accent
                                : AppColors.secondary.withOpacity(0.3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: item.quantity > 1
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cart.updateQuantity(
                              item.product.id, item.quantity + 1);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Remove Button
                GestureDetector(
                  onTap: () => cart.removeItem(item.product.id),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[600],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pesanan:',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Rp ${cart.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: cart.totalAmount > 0
                  ? () => _showCustomerInfoDialog(context, cart)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Pesan Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

// Order Confirmation Dialog
class OrderConfirmationDialog extends StatefulWidget {
  final String orderId;
  final String tableNumber;
  final String customerName;
  final String customerPhone;
  final List<dynamic> cartItems;
  final double totalAmount;
  final PaymentMethod paymentMethod;

  OrderConfirmationDialog({
    required this.orderId,
    required this.tableNumber,
    required this.customerName,
    required this.customerPhone,
    required this.cartItems,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  _OrderConfirmationDialogState createState() =>
      _OrderConfirmationDialogState();
}

class _OrderConfirmationDialogState extends State<OrderConfirmationDialog> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveOrderReceipt() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Generate filename with timestamp
        String fileName =
            'caffe_pandawa_receipt_${DateTime.now().millisecondsSinceEpoch}.png';

        // Save to gallery using saver_gallery
        final SaveResult result = await SaverGallery.saveImage(
          pngBytes,
          quality: 100,
          fileName: fileName,
          androidRelativePath: "Pictures/Caffe Pandawa Receipts",
          skipIfExists: false,
        );

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child:
                        Text('Bukti pembayaran berhasil disimpan ke galeri!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          throw Exception('Failed to save: ${result.errorMessage}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Gagal menyimpan bukti pembayaran: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pesanan Berhasil!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Receipt Content
            Expanded(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Caffe Pandawa",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Order Details
                        _buildDetailRow('No. Pesanan:', widget.orderId),
                        _buildDetailRow('Meja:', widget.tableNumber),
                        _buildDetailRow('Nama:', widget.customerName),
                        if (widget.customerPhone.isNotEmpty)
                          _buildDetailRow('No. HP:', widget.customerPhone),
                        _buildDetailRow(
                            'Tanggal:', _formatDate(DateTime.now())),
                        _buildDetailRow('Waktu:', _formatTime(DateTime.now())),
                        _buildDetailRow(
                            'Pembayaran:',
                            widget.paymentMethod == PaymentMethod.qris
                                ? 'QRIS'
                                : 'Cash'),

                        Divider(
                            color: AppColors.secondary,
                            thickness: 1,
                            height: 20),

                        // Items List
                        Text(
                          'Detail Pesanan: ${widget.cartItems.length} item',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = widget.cartItems[index];

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.namaProduct} (${item.quantity}x)',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${(item.product.harga * item.quantity).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        Divider(
                            color: AppColors.secondary,
                            thickness: 1,
                            height: 20),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Rp ${widget.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.paymentMethod == PaymentMethod.qris
                                    ? '✅ Pembayaran QRIS berhasil dikonfirmasi'
                                    : '💰 Silakan bayar di kasir saat pesanan siap',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Terima kasih atas pesanan Anda!\nMohon tunggu, pesanan sedang diproses.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveOrderReceipt,
                      icon: Icon(Icons.save_alt),
                      label: Text('Simpan Bukti Pembayaran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to menu
                      },
                      child: Text('Kembali ke Menu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
