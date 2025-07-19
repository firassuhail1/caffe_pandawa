import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/Transaksi.dart';
import 'package:caffe_pandawa/models/TransaksiItem.dart';
import 'package:caffe_pandawa/pages/beranda/transaksi/transaksi_detail.dart';

class TransaksiListView extends StatelessWidget {
  final List<Transaksi> transaksiList;

  const TransaksiListView({
    Key? key,
    required this.transaksiList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: transaksiList.length,
      itemBuilder: (context, index) {
        final transaksi = transaksiList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransaksiDetail(transaksi: transaksi),
              ),
            );
          },
          child: TransaksiCard(transaksi: transaksi),
        );
      },
    );
  }
}

class TransaksiCard extends StatelessWidget {
  final Transaksi transaksi;

  TransaksiCard({
    Key? key,
    required this.transaksi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(context),
          const Divider(height: 1),
          _buildCardContent(),
          const Divider(height: 1),
          _buildCardFooter(context),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID Transaksi: #${transaksi.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(transaksi.createdAt),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          // IconButton(
          //   icon: const Icon(Icons.print, color: Colors.white),
          //   // onPressed: () => _printReceipt(context),
          //   onPressed: () => null,
          //   tooltip: 'Cetak struk',
          // ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Produk:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...transaksi.daftarBarang.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(TransaksiItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              item.namaProduct,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${item.quantity} x ${formatter(item.harga)}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatter(item.totalHarga),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', transaksi.totalBayar),
          _buildPriceRow('Jumlah Bayar', transaksi.jumlahBayar),
          _buildPriceRow('Kembalian', transaksi.kembalian),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            formatter(amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Future<void> _printReceipt(BuildContext context) async {
  //   final pdf = pw.Document();

  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Center(
  //               child: pw.Text(
  //                 'STRUK PEMBAYARAN',
  //                 style: pw.TextStyle(
  //                   fontWeight: pw.FontWeight.bold,
  //                   fontSize: 18,
  //                 ),
  //               ),
  //             ),
  //             pw.SizedBox(height: 10),
  //             pw.Row(
  //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //               children: [
  //                 pw.Text('No. Transaksi: #${transaksi.id}'),
  //                 pw.Text(DateFormat('dd/MM/yyyy HH:mm')
  //                     .format(transaksi.createdAt)),
  //               ],
  //             ),
  //             pw.SizedBox(height: 15),
  //             pw.Divider(),
  //             pw.SizedBox(height: 10),
  //             pw.Text(
  //               'Daftar Produk:',
  //               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //             ),
  //             pw.SizedBox(height: 10),
  //             _buildProductTable(),
  //             pw.SizedBox(height: 10),
  //             pw.Divider(),
  //             pw.SizedBox(height: 10),
  //             _buildPriceRowPdf('Subtotal', transaksi.totalBayar),
  //             _buildPriceRowPdf('Jumlah Bayar', transaksi.jumlahBayar),
  //             _buildPriceRowPdf('Kembalian', transaksi.kembalian),
  //             pw.SizedBox(height: 20),
  //             pw.Center(
  //               child: pw.Text(
  //                 'Terima Kasih Atas Pembelian Anda',
  //                 style: pw.TextStyle(
  //                   fontStyle: pw.FontStyle.italic,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }

//   pw.Widget _buildProductTable() {
//     return pw.Table(
//       border: pw.TableBorder.all(width: 1, color: PdfColors.grey300),
//       children: [
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//           children: [
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.Text(
//                 'Produk',
//                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.Text(
//                 'Qty',
//                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 textAlign: pw.TextAlign.center,
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.Text(
//                 'Harga',
//                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 textAlign: pw.TextAlign.right,
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.Text(
//                 'Subtotal',
//                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 textAlign: pw.TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//         ...transaksi.daftarBarang
//             .map((item) => pw.TableRow(
//                   children: [
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(5),
//                       child: pw.Text(item.namaProduct),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(5),
//                       child: pw.Text(
//                         '${item.quantity}',
//                         textAlign: pw.TextAlign.center,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(5),
//                       child: pw.Text(
//                         formatter(item.harga),
//                         textAlign: pw.TextAlign.right,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(5),
//                       child: pw.Text(
//                         formatter(item.totalHarga),
//                         textAlign: pw.TextAlign.right,
//                       ),
//                     ),
//                   ],
//                 ))
//             .toList(),
//       ],
//     );
//   }

//   pw.Widget _buildPriceRowPdf(String label, int amount) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 5),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//           ),
//           pw.Text(
//             formatter(amount),
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
}

class TransaksiLoadingView extends StatelessWidget {
  const TransaksiLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data transaksi...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class TransaksiErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const TransaksiErrorView({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sedang ada perbaikan.',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: const Text(
              'Coba lagi',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransaksiEmptyView extends StatelessWidget {
  const TransaksiEmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            color: Colors.grey[400],
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi ditemukan',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada transaksi yang dilakukan atau\ncoba gunakan filter pencarian yang berbeda',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
