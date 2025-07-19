import 'package:caffe_pandawa/models/CashierSession.dart';
import 'package:caffe_pandawa/pages/laporan/rekap_kas/rekap_kas_detail.dart';
import 'package:caffe_pandawa/services/cashier_session_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu

// Asumsikan Anda punya halaman detailnya, misalnya:
// import 'cashier_recap_detail_screen.dart';

class RekapKas extends StatefulWidget {
  const RekapKas({Key? key}) : super(key: key);

  @override
  State<RekapKas> createState() => _RekapKasState();
}

class _RekapKasState extends State<RekapKas> {
  final CashierSessionServices cashierSessionServices =
      CashierSessionServices();

  // Data simulasi. Dalam aplikasi nyata, ini akan diambil dari API.
  // Pastikan data simulasi sesuai dengan format JSON dari backend Anda
  // Terutama jika Anda memiliki relasi user untuk mendapatkan cashierName.
  // final List<CashierSession> _recapData = [
  //   CashierSession(
  //     id: 1,
  //     userId: 101,
  //     shiftStartTime: DateTime(2025, 5, 28, 8, 0, 0),
  //     shiftEndTime: DateTime(2025, 5, 28, 16, 0, 0),
  //     startingCashAmount: 500000.0,
  //     endingCashAmount: 1550000.0,
  //     totalSalesCash: 1000000.0,
  //     totalSalesEWallet: 200000.0,
  //     totalSalesTransferBank: 50000.0,
  //     totalSalesQris: 100000.0,
  //     totalSalesGerai: 0.0,
  //     totalCashIn: 1200000.0,
  //     totalCashOut: 150000.0,
  //     notes: 'Shift pagi berjalan lancar',
  //     cashDifference: 0.0,
  //     status: 'closed',
  //     createdAt: DateTime(2025, 5, 28, 16, 5, 0),
  //     updatedAt: DateTime(2025, 5, 28, 16, 5, 0),
  //     cashierName: 'Budi Santoso', // Diasumsikan dari data user terkait
  //   ),
  //   CashierSession(
  //     id: 2,
  //     userId: 102,
  //     shiftStartTime: DateTime(2025, 5, 29, 9, 0, 0), // Hari ini
  //     shiftEndTime: DateTime(2025, 5, 29, 17, 0, 0),
  //     startingCashAmount: 300000.0,
  //     endingCashAmount: 1590000.0,
  //     totalSalesCash: 1200000.0,
  //     totalSalesEWallet: 100000.0,
  //     totalSalesTransferBank: 0.0,
  //     totalSalesQris: 50000.0,
  //     totalSalesGerai: 0.0,
  //     totalCashIn: 1350000.0,
  //     totalCashOut: 200000.0,
  //     notes: 'Ada selisih Rp 10.000',
  //     cashDifference: -10000.0, // Defisit
  //     status: 'closed',
  //     createdAt: DateTime(2025, 5, 29, 17, 5, 0),
  //     updatedAt: DateTime(2025, 5, 29, 17, 5, 0),
  //     cashierName: 'Ani Suryani',
  //   ),
  //   CashierSession(
  //     id: 3,
  //     userId: 101, // Kasir Budi lagi, shift sore
  //     shiftStartTime: DateTime(2025, 5, 29, 17, 0, 0), // Hari ini
  //     shiftEndTime: null, // Masih open
  //     startingCashAmount: 400000.0,
  //     endingCashAmount: null,
  //     totalSalesCash: null,
  //     totalSalesEWallet: null,
  //     totalSalesTransferBank: null,
  //     totalSalesQris: null,
  //     totalSalesGerai: null,
  //     totalCashIn: null,
  //     totalCashOut: null,
  //     notes: null,
  //     cashDifference: null,
  //     status: 'open',
  //     createdAt: DateTime(2025, 5, 29, 17, 0, 0),
  //     updatedAt: DateTime(2025, 5, 29, 17, 0, 0),
  //     cashierName: 'Budi Santoso',
  //   ),
  //   CashierSession(
  //     id: 5,
  //     userId: 105,
  //     shiftStartTime: DateTime(2025, 4, 28, 8, 0, 0),
  //     shiftEndTime: DateTime(2025, 4, 28, 16, 0, 0),
  //     startingCashAmount: 500000.0,
  //     endingCashAmount: 1550000.0,
  //     totalSalesCash: 1000000.0,
  //     totalSalesEWallet: 200000.0,
  //     totalSalesTransferBank: 50000.0,
  //     totalSalesQris: 100000.0,
  //     totalSalesGerai: 0.0,
  //     totalCashIn: 1200000.0,
  //     totalCashOut: 150000.0,
  //     notes: 'Shift pagi berjalan lancar',
  //     cashDifference: 0.0,
  //     status: 'closed',
  //     createdAt: DateTime(2025, 4, 28, 16, 5, 0),
  //     updatedAt: DateTime(2025, 4, 28, 16, 5, 0),
  //     cashierName: 'Budi Sanotoso', // Diasumsikan dari data user terkait
  //   ),
  // ];

  List<CashierSession> _recapData = [];
  bool isLoading = true;

  final Map<DateTime, List<CashierSession>> _groupedRecaps = {};

  @override
  void initState() {
    super.initState();
    _fetchRekapKas();
  }

  void _fetchRekapKas() async {
    final result = await cashierSessionServices.fetchCashierSession();

    setState(() {
      _recapData = result;
      isLoading = false;
    });

    if (!isLoading) _groupRecapsByDate();
  }

  void _groupRecapsByDate() {
    // Sort data dari yang terbaru ke terlama berdasarkan shiftStartTime
    _recapData.sort((a, b) => b.shiftStartTime.compareTo(a.shiftStartTime));

    for (var recap in _recapData) {
      // Menggunakan getter shiftDateOnly dari model
      final DateTime dateOnly = recap.shiftDateOnly;
      if (!_groupedRecaps.containsKey(dateOnly)) {
        _groupedRecaps[dateOnly] = [];
      }
      _groupedRecaps[dateOnly]!.add(recap);
    }

    print(_recapData);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.isAtSameMomentAs(today)) {
      return 'Hari Ini';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Kas'),
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _groupedRecaps.isEmpty
          ? const Center(child: Text('Belum ada data rekap kas.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _groupedRecaps.keys.map((date) {
                  final recapsForDate = _groupedRecaps[date]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 4.0),
                        child: Text(
                          _formatDateHeader(date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // List dari Card untuk setiap rekap di tanggal tersebut
                      ...recapsForDate.map((recap) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              print('Detail rekap kas ID: ${recap.id} diklik');
                              // Navigasi ke halaman detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RekapKasDetail(recap: recap),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        // Gunakan Expanded untuk teks nama kasir agar tidak overflow
                                        child: Text(
                                          'Kasir: ${recap.user.nama}', // Tampilkan N/A jika nama kasir null
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey),
                                          overflow: TextOverflow
                                              .ellipsis, // Tambah ellipsis jika terlalu panjang
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 10), // Sedikit jarak
                                      Text(
                                        // Tampilkan jam buka saja jika shift_end_time null
                                        recap.shiftEndTime == null
                                            ? '${DateFormat('HH:mm').format(recap.shiftStartTime)} - (Open)'
                                            : '${DateFormat('HH:mm').format(recap.shiftStartTime)} - ${DateFormat('HH:mm').format(recap.shiftEndTime!)}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Uang Buka Kasir: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(recap.startingCashAmount)}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87),
                                      ),
                                      // Tampilkan selisih hanya jika shift sudah ditutup
                                      if (recap.status == 'closed')
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Selisih:',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54),
                                            ),
                                            Text(
                                              recap.cashDifference == null
                                                  ? 'Rp0'
                                                  : recap
                                                      .formattedCashDifference,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    recap.cashDifferenceColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        const Text(
                                          'Status: Open',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20), // Jarak antar grup tanggal
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
