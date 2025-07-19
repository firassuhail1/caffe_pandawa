import 'package:caffe_pandawa/pages/laporan/laporan_keuangan/laporan_keuangan.dart';
import 'package:caffe_pandawa/pages/laporan/rekap_kas/rekap_kas.dart';
import 'package:flutter/material.dart';

class Laporan extends StatefulWidget {
  const Laporan({super.key});

  @override
  State<Laporan> createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
        title: Text('Laporan'),
      ),
      body: SingleChildScrollView(
        // Padding agar konten tidak terlalu menempel di tepi layar
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Menggunakan CrossAxisAlignment.start agar item list rata kiri
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Laporan Keuangan ---
            Card(
              margin: const EdgeInsets.only(bottom: 12.0), // Jarak antar Card
              elevation: 2, // Efek bayangan Card
              child: ListTile(
                leading: const Icon(Icons.receipt_long,
                    color: Colors.blue), // Ikon yang relevan
                title: const Text(
                  'Laporan Keuangan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios), // Ikon panah ke kanan
                onTap: () {
                  // Tambahkan navigasi atau logika lain di sini
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LaporanKeuangan()));
                },
              ),
            ),
            // --- Rekap Kas ---
            Card(
              margin: const EdgeInsets.only(bottom: 12.0), // Jarak antar Card
              elevation: 2, // Efek bayangan Card
              child: ListTile(
                leading: const Icon(Icons.receipt_long,
                    color: Colors.blue), // Ikon yang relevan
                title: const Text(
                  'Rekap Kas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios), // Ikon panah ke kanan
                onTap: () {
                  // Tambahkan navigasi atau logika lain di sini
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RekapKas()));
                },
              ),
            ),
            // Anda bisa menambahkan item list lain di sini
            Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text(
                  'Pengaturan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  print('Pengaturan diklik');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
