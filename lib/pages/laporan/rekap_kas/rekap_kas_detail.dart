// screens/rekap_kas_detail_screen.dart
import 'package:caffe_pandawa/models/CashierSession.dart';
import 'package:caffe_pandawa/pages/laporan/rekap_kas/arus_kas.dart';
import 'package:caffe_pandawa/pages/laporan/rekap_kas/daftar_transaksi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal, waktu, dan mata uang

class RekapKasDetail extends StatelessWidget {
  final CashierSession recap;

  const RekapKasDetail({Key? key, required this.recap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper untuk format mata uang
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    // Helper untuk format jam
    final formatTime = DateFormat('HH:mm');

    // Hitung total penjualan dari semua metode pembayaran
    final double totalAllSales = (recap.totalSalesCash ?? 0.0) +
        (recap.totalSalesEWallet ?? 0.0) +
        (recap.totalSalesTransferBank ?? 0.0) +
        (recap.totalSalesQris ?? 0.0) +
        (recap.totalSalesGerai ?? 0.0);

    // Hitung estimasi uang tutup kasir (jika shift sudah ditutup)
    double? expectedClosingCash;
    if (recap.status == 'closed') {
      expectedClosingCash = recap.startingCashAmount +
          (recap.totalSalesCash ?? 0.0) + // Penjualan tunai
          (recap.totalCashIn ?? 0.0) - // Pemasukan lain-lain
          (recap.totalCashOut ?? 0.0); // Pengeluaran lain-lain
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Rekap Kas'),
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Informasi Umum Shift ---
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nama Kasir', recap.user.nama),
                    _buildDetailRow(
                      'Buka Kasir',
                      '${DateFormat('EEEE, dd MMMM y', 'id_ID').format(recap.shiftStartTime)} ${formatTime.format(recap.shiftStartTime)}',
                    ),
                    _buildDetailRow(
                      'Tutup Kasir',
                      recap.shiftEndTime != null
                          ? '${DateFormat('EEEE, dd MMMM y', 'id_ID').format(recap.shiftEndTime!)} ${formatTime.format(recap.shiftEndTime!)}'
                          : 'Shift Belum Ditutup',
                    ),
                    _buildDetailRow('Status Shift', recap.status.toUpperCase()),
                  ],
                ),
              ),
            ),

            // --- Rekap Penjualan Produk ---
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rekap Penjualan Produk',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailRow('Total Transaksi Penjualan',
                        formatCurrency.format(totalAllSales)),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigasi ke halaman daftar produk terjual
                          print(
                              'Tombol "Lihat Daftar Produk Terjual" diklik untuk Shift ID: ${recap.id}');

                          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          //     content: Text(
                          //         'Fitur daftar produk terjual belum diimplementasikan.')));

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DaftarTransaksi(
                                transaksi: recap.transaksi,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Lihat Daftar Produk Terjual'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Detail Transaksi Penjualan (Pendapatan) ---
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Pendapatan Penjualan',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailRow('Penjualan Tunai',
                        formatCurrency.format(recap.totalSalesCash ?? 0.0)),
                    _buildDetailRow('Penjualan E-Wallet',
                        formatCurrency.format(recap.totalSalesEWallet ?? 0.0)),
                    _buildDetailRow(
                        'Penjualan Transfer Bank',
                        formatCurrency
                            .format(recap.totalSalesTransferBank ?? 0.0)),
                    _buildDetailRow('Penjualan QRIS',
                        formatCurrency.format(recap.totalSalesQris ?? 0.0)),
                    _buildDetailRow('Penjualan Gerai',
                        formatCurrency.format(recap.totalSalesGerai ?? 0.0)),
                  ],
                ),
              ),
            ),

            // --- Arus Kas (Di Luar Transaksi Penjualan) ---
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Arus Kas Non-Penjualan',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailRow('Uang Buka Kasir',
                        formatCurrency.format(recap.startingCashAmount)),
                    _buildDetailRow('Total Pemasukan Lain-lain',
                        formatCurrency.format(recap.totalCashIn ?? 0.0)),
                    _buildDetailRow('Total Pengeluaran Lain-lain',
                        formatCurrency.format(recap.totalCashOut ?? 0.0)),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigasi ke halaman daftar produk terjual
                          print(
                              'Tombol "Lihat Arus kas" diklik untuk Shift ID: ${recap}');

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ArusKas(
                                cashMovement: recap.cashMovement,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Lihat Arus Kas'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Rekonsiliasi Kas ---
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Penerimaan Aktual di Kasir',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                    ),
                    const Divider(height: 20, thickness: 1),
                    if (recap.status == 'closed') ...[
                      _buildDetailRow(
                          'Tunai',
                          recap.endingCashAmount != null
                              ? formatCurrency.format(recap.endingCashAmount!)
                              : 'N/A'),
                      _buildDetailRow(
                          'Non-Tunai',
                          recap.endingCashAmount != null
                              ? formatCurrency.format(0)
                              : 'N/A'),
                    ] else ...[
                      const Text(
                        'Shift ini masih Berstatus OPEN. Rekonsiliasi kas akan tersedia setelah shift ditutup.',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rekap',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                    ),
                    const Divider(height: 20, thickness: 1),
                    if (recap.status == 'closed') ...[
                      _buildDetailRow(
                          'Penerimaan Sistem',
                          expectedClosingCash != null
                              ? formatCurrency.format(expectedClosingCash)
                              : 'N/A'),
                      _buildDetailRow(
                        'Selisih Kas',
                        recap.formattedCashDifference,
                        valueColor: recap.cashDifferenceColor,
                        isBoldValue: true,
                      ),
                    ] else ...[
                      const Text(
                        'Shift ini masih Berstatus OPEN. Rekonsiliasi kas akan tersedia setelah shift ditutup.',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat baris detail
  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
