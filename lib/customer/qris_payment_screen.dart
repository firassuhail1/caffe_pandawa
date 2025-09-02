import 'dart:async';
import 'dart:ui' as ui;
import 'package:caffe_pandawa/customer/cart_screen.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/services/order_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:caffe_pandawa/providers/cart_provider.dart';
import 'package:intl/intl.dart';

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

class QRISPaymentScreen extends StatefulWidget {
  final CartProvider cart;
  final String orderId;
  final PaymentMethod paymentMethod;
  final double grossAmount;
  final String qrString;
  final String tableNumber;
  final String customerName;
  final String customerPhone;
  final DateTime expiryTime;

  const QRISPaymentScreen({
    Key? key,
    required this.cart,
    required this.orderId,
    required this.paymentMethod,
    required this.grossAmount,
    required this.qrString,
    required this.tableNumber,
    required this.customerName,
    required this.customerPhone,
    required this.expiryTime,
  }) : super(key: key);

  @override
  State<QRISPaymentScreen> createState() => _QRISPaymentScreenState();
}

class _QRISPaymentScreenState extends State<QRISPaymentScreen> {
  final GlobalKey _qrKey = GlobalKey();
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  String statusText = "Menunggu pembayaran...";
  bool isPaymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _startCountdown();
    _startPaymentStatusChecker();
  }

  void _updateRemainingTime() {
    print('masuk ke update remaining time');
    setState(() {
      _timeRemaining = widget.expiryTime.difference(DateTime.now());
      if (_timeRemaining.isNegative) {
        _timeRemaining = Duration.zero;
        statusText = "Pembayaran expired";
      }
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print('countdown proses, masuk ke update remaining time');
      _updateRemainingTime();
      if (_timeRemaining.isNegative) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          statusText = "Pembayaran expired";
        });
      }
    });
  }

  void _startPaymentStatusChecker() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (isPaymentCompleted || _timeRemaining.isNegative) {
        timer.cancel();
        return;
      }

      try {
        String result = await OrderService().checkPaymentStatus(widget.orderId);

        if (!mounted) return;

        // For demo purposes, uncomment the following to test payment completion:
        if (result == 'paid') {
          setState(() {
            statusText = "Pembayaran berhasil";
          });

          _onPaymentSuccess();
          timer.cancel();
        } else if (result == "failed" || result == "expired") {
          // Jika pembayaran gagal atau expired
          setState(() {
            statusText = "Pembayaran gagal atau expired";
          });
          timer.cancel();
        } else {
          // Jika status masih pending, update teks status
          setState(() {
            statusText = _timeRemaining.inSeconds > 0
                ? "Menunggu pembayaran..."
                : "Pembayaran expired";
          });
        }

        setState(() {
          statusText = _timeRemaining.inSeconds > 0
              ? "Menunggu pembayaran..."
              : "Pembayaran expired";
        });
      } catch (e) {
        setState(() {
          statusText = "Gagal memeriksa status pembayaran";
        });
      }
    });
  }

  void _onPaymentSuccess() {
    setState(() {
      isPaymentCompleted = true;
      statusText = "Pembayaran berhasil!";
    });

    // Show order confirmation
    _showOrderConfirmation();
  }

  void _showOrderConfirmation() {
    final cartCopy = List.from(widget.cart.items.values);
    widget.cart.clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OrderConfirmationDialog(
          orderId: widget.orderId,
          tableNumber: widget.tableNumber,
          customerName: widget.customerName,
          customerPhone: widget.customerPhone,
          cartItems: cartCopy,
          totalAmount: widget.grossAmount,
          paymentMethod: widget.paymentMethod,
        );
      },
    );
  }

  void _copyQRCode() {
    Clipboard.setData(ClipboardData(text: widget.qrString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Kode QR disalin ke clipboard"),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveQRCode() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        String fileName =
            'qris_payment_${DateTime.now().millisecondsSinceEpoch}.png';

        final SaveResult result = await SaverGallery.saveImage(
          pngBytes,
          quality: 100,
          fileName: fileName,
          androidRelativePath: "Pictures/Caffe Pandawa QR",
          skipIfExists: false,
        );

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("QR Code berhasil disimpan ke galeri!"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text("Gagal menyimpan QR Code: $e"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String get formattedTime {
    if (_timeRemaining.inSeconds <= 0) return "Expired";

    int hours = _timeRemaining.inHours;
    int minutes = _timeRemaining.inMinutes % 60;
    int seconds = _timeRemaining.inSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Color get statusColor {
    if (isPaymentCompleted) return Colors.green;
    if (_timeRemaining.isNegative) return Colors.red;
    if (_timeRemaining.inMinutes <= 5) return Colors.orange;
    return AppColors.primary;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Pembayaran QRIS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!isPaymentCompleted) {
              _showCancelConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Information
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      isPaymentCompleted
                          ? Icons.check_circle
                          : _timeRemaining.isNegative
                              ? Icons.error
                              : Icons.access_time,
                      color: statusColor,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // QR Code Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Scan QR Code untuk Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondary),
                        ),
                        child: QrImageView(
                          data: widget.qrString,
                          version: QrVersions.auto,
                          size: 250.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyQRCode,
                            icon: Icon(Icons.copy, size: 18),
                            label: Text('Copy'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: BorderSide(color: AppColors.accent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saveQRCode,
                            icon: Icon(Icons.download, size: 18),
                            label: Text('Simpan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: BorderSide(color: AppColors.accent),
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

              SizedBox(height: 20),

              // Payment Details
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('No. Pesanan', widget.orderId),
                    _buildDetailRow('Meja', widget.tableNumber),
                    _buildDetailRow('Total Pembayaran',
                        'Rp ${NumberFormat('#,###', 'id_ID').format(widget.grossAmount)}'),
                    _buildDetailRow(
                        'Batas Waktu',
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(widget.expiryTime)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Countdown Timer
              if (!_timeRemaining.isNegative && !isPaymentCompleted)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _timeRemaining.inMinutes <= 5
                        ? Colors.red.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _timeRemaining.inMinutes <= 5
                          ? Colors.red.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sisa Waktu Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _timeRemaining.inMinutes <= 5
                              ? Colors.red
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 20),

              // Instructions
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInstruction('Buka aplikasi pembayaran digital Anda'),
                    _buildInstruction('Pilih menu Scan QR atau QRIS'),
                    _buildInstruction('Arahkan kamera ke QR Code di atas'),
                    _buildInstruction(
                        'Periksa detail pembayaran dan konfirmasi'),
                    _buildInstruction('Pembayaran akan terverifikasi otomatis'),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Action Button
              if (!isPaymentCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _timeRemaining.isNegative
                        ? null
                        : () {
                            // Manual confirmation for testing
                            _onPaymentSuccess();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _timeRemaining.isNegative
                          ? 'Pembayaran Expired'
                          : 'Saya Sudah Bayar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
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

  Widget _buildInstruction(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Batalkan Pembayaran?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin membatalkan pembayaran ini? Pesanan Anda akan dibatalkan.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tidak',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to cart
              },
              child: Text(
                'Ya, Batalkan',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Order Confirmation Dialog (reuse from your existing code)
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
        String fileName =
            'caffe_pandawa_receipt_${DateTime.now().millisecondsSinceEpoch}.png';

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
                      child: Text(
                          'Bukti pembayaran berhasil disimpan ke galeri!')),
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
              Expanded(child: Text('Gagal menyimpan bukti pembayaran: $e')),
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
                  Icon(Icons.check_circle, color: Colors.white, size: 48),
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
                        SizedBox(height: 16),
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
                              'Rp ${formatter(widget.totalAmount)}',
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
                                    ? 'Pembayaran QRIS berhasil dikonfirmasi'
                                    : 'Silakan bayar di kasir saat pesanan siap',
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
                        Navigator.pop(context); // Go back to cart screen
                        Navigator.pop(context, true); // Go back to menu
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
