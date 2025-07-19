import 'dart:io';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/pages/akun/akun.dart';
import 'package:caffe_pandawa/pages/beranda/beranda.dart';
import 'package:caffe_pandawa/pages/kasir/kasir.dart';
import 'package:caffe_pandawa/pages/laporan/laporan.dart';
import 'package:caffe_pandawa/pages/produk/produk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _pages = [
    Beranda(),
    Laporan(),
    Container(),
    Produk(),
    Akun(),
  ];

  int _selectedTabBottom = 0;

  // Mengubah halaman yang aktif di bottom navigation bar
  void _onBottomTabTapped(int index) {
    if (index == 2) {
      // Index 2 adalah Kasir
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Kasir(),
        ),
      );
      return; // Jangan ubah _selectedTabBottom agar tidak berpindah tab
    }

    setState(() {
      _selectedTabBottom = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          final bool shouldPop = await _showBackDialog(context) ?? false;
          if (context.mounted && shouldPop) {
            Navigator.pop(context, result);
          }
        },
        child: _pages[_selectedTabBottom],
      ), // Menampilkan halaman jika data berhasil diambil
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.brown,
      currentIndex: _selectedTabBottom,
      onTap: _onBottomTabTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Laporan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calculate, color: Colors.black), label: 'Kasir'),
        BottomNavigationBarItem(
            icon: Icon(Icons.breakfast_dining), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ],
    );
  }

  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.brown[700],
                  size: 50,
                ),
                const SizedBox(height: 20),
                Text(
                  'Peringatan!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apakah anda yakin ingin keluar dari aplikasi ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.brown[700]!, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          exit(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
}
