import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/CartItems.dart';
import 'package:caffe_pandawa/pages/kasir/kasir.dart';
import 'package:caffe_pandawa/services/transaksi_services.dart';

class Pembayaran extends StatefulWidget {
  final List<CartItems>? cartItems;
  final double totalAmount;

  const Pembayaran({
    Key? key,
    this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PembayaranState createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  final TransaksiServices services = TransaksiServices();
  final TextEditingController _cashController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  double _cashAmount = 0;
  double _changeAmount = 0;
  bool _isPaymentValid = false;
  bool _processingPayment = false;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  double bulatkanKeAtas(double nominal, double kelipatan) {
    return ((nominal + kelipatan - 1) ~/ kelipatan) * kelipatan;
  }

  void _calculateChange() {
    if (_cashController.text.isEmpty) {
      setState(() {
        _cashAmount = 0;
        _changeAmount = 0;
        _isPaymentValid = false;
      });
      return;
    }

    String cleanText = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    double cashAmount = double.tryParse(cleanText) ?? 0;

    setState(() {
      _cashAmount = cashAmount;
      _changeAmount = cashAmount - widget.totalAmount;
      _isPaymentValid = cashAmount >= widget.totalAmount;
    });
  }

  void _setPaymentAmount(double amount) {
    _cashController.text = formatter(double.parse(amount.toStringAsFixed(0)));
    _calculateChange();
  }

  void _completePayment() async {
    if (!_isPaymentValid) return;

    setState(() {
      _processingPayment = true;
    });

    final result = await services.pembayaran(
        widget.cartItems, widget.totalAmount, _cashAmount, _changeAmount);

    if (result) {
      await Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        messageText: const Text(
          'Berhasil melakukan transaksi',
          style: const TextStyle(color: Colors.white),
        ),
      ).show(context);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => Kasir(),
        ),
        (route) => route.isFirst,
      );
    } else {
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        messageText: Text(
          'Gagal melakukan transaksi',
          style: const TextStyle(color: Colors.white),
        ),
      ).show(context);

      setState(() {
        _processingPayment = false;
      });
    }
  }

  Widget _buildQuickAmountButton(double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade50,
          foregroundColor: Colors.brown.shade800,
          side: BorderSide(color: Colors.brown.shade300),
        ),
        onPressed: () => _setPaymentAmount(amount),
        child: Text(_currencyFormat.format(amount)),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryRow(
              label: 'Total Belanja',
              value: _currencyFormat.format(widget.totalAmount),
              valueColor: Colors.black,
            ),
            const Divider(height: 24),
            SummaryRow(
              label: 'Uang Diterima',
              value:
                  _cashAmount > 0 ? _currencyFormat.format(_cashAmount) : '-',
              valueColor: Colors.black,
            ),
            const SizedBox(height: 12),
            SummaryRow(
              label: 'Kembalian',
              value:
                  _cashAmount > 0 ? _currencyFormat.format(_changeAmount) : '-',
              valueColor: _changeAmount >= 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(widget.totalAmount),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Masukkan Jumlah Uang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _cashController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                            trailingSymbol:
                                '', // Bisa pakai 'Rp' kalau ingin simbol
                          ),
                        ],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.payments_outlined,
                              color: Colors.brown.shade700),
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                              color: Colors.brown.shade700, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.brown.shade700, width: 2),
                          ),
                          hintText: 'Jumlah uang tunai',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nominal Cepat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown.shade100,
                                      foregroundColor: Colors.brown.shade800,
                                      side: BorderSide(
                                          color: Colors.brown.shade400),
                                    ),
                                    onPressed: () =>
                                        _setPaymentAmount(widget.totalAmount),
                                    child: const Text('Uang Pas'),
                                  ),
                                ),
                                _buildQuickAmountButton(20000),
                                _buildQuickAmountButton(50000),
                                _buildQuickAmountButton(100000),
                              ],
                            ),
                            Row(
                              children: [
                                _buildQuickAmountButton(
                                    bulatkanKeAtas(widget.totalAmount, 5000)),
                                _buildQuickAmountButton(
                                    bulatkanKeAtas(widget.totalAmount, 50000)),
                                _buildQuickAmountButton(
                                    bulatkanKeAtas(widget.totalAmount, 100000)),
                                _buildQuickAmountButton(bulatkanKeAtas(
                                    widget.totalAmount, 1000000)),
                              ],
                            )
                          ],
                        ),
                      ),
                      _buildPaymentSummary(),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPaymentValid
                                ? Colors.brown.shade700
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _isPaymentValid ? _completePayment : null,
                          child: _processingPayment
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Proses Pembayaran',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      if (!_isPaymentValid && _cashAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Jumlah uang kurang dari total belanja',
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final FontWeight fontWeight;

  const SummaryRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor = Colors.black,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}
