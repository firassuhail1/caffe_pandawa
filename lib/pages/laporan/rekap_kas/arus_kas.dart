import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan sudah ada di pubspec.yaml
import 'package:caffe_pandawa/models/CashMovement.dart'; // Sesuaikan path jika berbeda

class ArusKas extends StatefulWidget {
  final List<CashMovement>? cashMovement;

  const ArusKas({super.key, required this.cashMovement});

  @override
  State<ArusKas> createState() => _ArusKasState();
}

class _ArusKasState extends State<ArusKas> {
  @override
  Widget build(BuildContext context) {
    // Cek apakah data cashMovement null atau kosong
    if (widget.cashMovement == null || widget.cashMovement!.isEmpty) {
      return Scaffold(
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Tidak ada pergerakan kas tambahan.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final List<CashMovement> sortedCashMovements =
        List.from(widget.cashMovement!);
    sortedCashMovements.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Gunakan ListView.builder untuk efisiensi jika daftar panjang
    return Scaffold(
      appBar: AppBar(
        title: Text('Arus Kas'),
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        shrinkWrap:
            true, // Penting jika ini berada di dalam SingleChildScrollView
        physics:
            const NeverScrollableScrollPhysics(), // Agar tidak scroll sendiri jika parent sudah scrollable
        itemCount: sortedCashMovements.length,
        itemBuilder: (context, index) {
          final movement = sortedCashMovements[index];
          final formatTime = DateFormat('HH:mm'); // Untuk format jam

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ikon Tipe Pergerakan
                  Icon(
                    movement.typeIcon,
                    color: movement.typeColor,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  // Deskripsi dan Waktu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movement.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('dd MMMM y', 'id_ID').format(movement.createdAt)} ${formatTime.format(movement.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Jumlah (Amount)
                  Column(
                    children: [
                      Text(
                        '${movement.typePrefix}${movement.formattedAmount}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: movement.typeColor,
                        ),
                      ),
                      Text(movement.user.nama),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
