import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caffe_pandawa/models/Transaksi.dart';
import 'package:caffe_pandawa/models/TransaksiItem.dart';

class TransaksiDetail extends StatefulWidget {
  final Transaksi transaksi;

  const TransaksiDetail({
    Key? key,
    required this.transaksi,
  }) : super(key: key);

  @override
  _TransaksiDetailState createState() => _TransaksiDetailState();
}

class _TransaksiDetailState extends State<TransaksiDetail> {
  final Color primaryColor = const Color(0xFF00BCD4); // Cyan color
  final Color backgroundColor = Colors.white;
  final Color accentColor = const Color(0xFF0097A7); // Darker cyan
  final Color textColor = const Color(0xFF424242);
  final Color lightGreyColor = const Color(0xFFEEEEEE);

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final dateFormatter = DateFormat('dd MMM yyyy, HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildTransactionInfo(),
              const SizedBox(height: 16),
              _buildItemList(),
              const SizedBox(height: 16),
              _buildPriceSummary(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 36,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice #${widget.transaksi.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${currencyFormatter.format(widget.transaksi.totalBayar)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            title: 'Tanggal Transaksi',
            value: dateFormatter.format(widget.transaksi.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.transaksi.daftarBarang.length} item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildItemHeaderRow(),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.transaksi.daftarBarang.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: lightGreyColor,
            ),
            itemBuilder: (context, index) {
              final item = widget.transaksi.daftarBarang[index];
              return _buildItemRow(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightGreyColor.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: lightGreyColor),
          bottom: BorderSide(color: lightGreyColor),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24), // Width for the number column
          Expanded(
            flex: 3,
            child: Text(
              'Item',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Harga',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Total',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(TransaksiItem item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              item.namaProduct,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormatter.format(item.harga),
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              currencyFormatter.format(item.totalHarga),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem(
            title: 'Total Pembelian',
            value: currencyFormatter.format(widget.transaksi.totalBayar),
            isTotal: false,
          ),
          Divider(height: 1, thickness: 1, color: lightGreyColor),
          _buildSummaryItem(
            title: 'Jumlah Bayar',
            value: currencyFormatter.format(widget.transaksi.jumlahBayar),
            isTotal: false,
          ),
          Divider(height: 1, thickness: 1, color: lightGreyColor),
          _buildSummaryItem(
            title: 'Kembalian',
            value: currencyFormatter.format(widget.transaksi.kembalian),
            isTotal: true,
            valueColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required bool isTotal,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isTotal ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: isTotal ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: isTotal
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Fungsi untuk mencetak receipt
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.print),
              label: const Text(
                'Cetak Receipt',
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
}
