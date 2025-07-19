import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/MainCashBalance.dart';
import 'package:caffe_pandawa/models/User.dart';
import 'package:caffe_pandawa/pages/beranda/eoq/eoq_analisis.dart';
import 'package:caffe_pandawa/pages/beranda/eoq/eoq_settings.dart';
import 'package:caffe_pandawa/pages/laporan/laporan_penjualan/laporan_data_penjualan.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/manajemen_bahan_baku.dart';
import 'package:caffe_pandawa/pages/manajemen_resep/manajemen_resep.dart';
import 'package:caffe_pandawa/pages/pembelian/pembelian.dart';
import 'package:caffe_pandawa/services/laporan_penjualan_services.dart';
import 'package:caffe_pandawa/services/services.dart';
import 'package:caffe_pandawa/services/transaksi_services.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/pages/produk/produk.dart';
import 'package:caffe_pandawa/pages/produk/tambah_produk.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final Services services = Services();

  // Controllers untuk dialog tambah saldo
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MainCashBalance? mainCashBalance;
  User? user;
  bool isLoading = true;
  String? errorMessage;

  double totalPenjualan = 0;
  int totalTransaksi = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchMainCashBalance();
    fetchTotalPenjualan('monthly');
  }

  void _fetchMainCashBalance() async {
    final getUser = await authServices.getUser();

    setState(() {
      user = getUser;
      isLoading = true; // Set loading state
      errorMessage = null; // Clear previous errors
    });
    try {
      final result = await services.fetchMainCashBalance(); // Panggil service
      setState(() {
        mainCashBalance = result;
        isLoading = false; // Data berhasil dimuat
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString(); // Tangkap error dan simpan pesan
        isLoading = false; // Berhenti loading
      });
      // Tampilkan error di UI (opsional, bisa juga di SnackBar/Dialog)
      print('Error di _fetchMainCashBalance: $e');
    }
  }

  void fetchTotalPenjualan(String period) async {
    final result =
        await LaporanPenjualanServices().laporanTotalPenjualan('monthly');

    if (result['success']) {
      if (!mounted) return;
      setState(() {
        totalPenjualan = result['total_penjualan'];
        totalTransaksi = result['total_transaksi'];
        print(totalPenjualan);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Fungsi yang akan dipanggil saat tombol "Tambah Saldo" di dialog ditekan ---
  void _handleDeposit() async {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(); // Tutup dialog setelah validasi

      // Parsing amount
      final double? amount =
          double.tryParse(_amountController.text.replaceAll('.', ''));
      final String description = _descriptionController.text.trim();

      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Jumlah harus angka positif dan valid.')));
        return;
      }

      setState(() {
        isLoading = true; // Tampilkan loading saat proses deposit
      });

      try {
        // Panggil service untuk melakukan deposit. Anda perlu membuat method ini di MainCashBalanceServices
        await services.depositToMainCash(amount, description, user!.id);

        // Setelah deposit berhasil, muat ulang saldo terbaru
        _fetchMainCashBalance();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo berhasil ditambahkan!')));
      } catch (e) {
        setState(() {
          isLoading = false; // Hentikan loading jika ada error
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah saldo: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Row(
          children: [
            const Text(
              'Caffe Pandawa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSaldoCard(),
          const SizedBox(height: 16),
          _buildGridMenu(),
          const SizedBox(height: 16),
          _buildPenjualanCard(),
        ],
      ),
    );
  }

  Widget _buildSaldoCard() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text('Error: $errorMessage'))
            : mainCashBalance == null
                ? const Center(child: Text('Data saldo tidak ditemukan.'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Saldo Saat Ini:',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _fetchMainCashBalance();
                                      },
                                      icon: Icon(Icons.refresh))
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                // Asumsi Anda punya helper currency formatter atau gunakan intl
                                formatter(mainCashBalance!.currentBalance),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Akun: ${mainCashBalance!.accountName}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Text(
                                'Tipe: ${mainCashBalance!.accountType.toUpperCase()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Text(
                                'Terakhir Diperbarui: ${DateFormat('dd MMMM y HH:mm', 'id_ID').format(mainCashBalance!.updatedAt)}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddBalanceDialog(context); // Panggil dialog
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 24),
                        label: const Text(
                          'Tambah Saldo',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.brown[800],
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  );
  }

  Widget _buildGridMenu() {
    final menuItems = [
      {
        'icon': Icons.local_mall,
        'label': 'Produk',
        'color': Colors.brown,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Produk(),
            ),
          );
        }
      },
      // {
      //   'icon': Icons.assignment,
      //   'label': 'Laporan',
      //   'color': Colors.brown,
      //   'onTap': () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (_) => TransaksiPage(),
      //       ),
      //     );
      //   }
      // },
      {
        'icon': Icons.add_to_photos,
        'label': 'Tambah',
        'color': Colors.brown,
        'onTap': () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TambahProduk(),
            ),
          );

          if (result) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Produk(),
              ),
            );
          }
        }
      },
      {
        'icon': Icons.settings,
        'label': 'Pengaturan',
        'color': Colors.brown,
        'onTap': () {
          print('pengaturan diklik');
        }
      },
      {
        'icon': Icons.construction,
        'label': 'Bahan Baku',
        'color': Colors.brown,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ManajemenBahanBaku(),
            ),
          );
        }
      },
      {
        'icon': Icons.shopping_cart,
        'label': 'Pembelian',
        'color': Colors.brown,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Pembelian(),
            ),
          );
        }
      },
      {
        'icon': Icons.receipt,
        'label': 'Kelola Resep',
        'color': Colors.brown,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ManajemenResep(),
            ),
          );
        }
      },
      {
        'icon': Icons.receipt,
        'label': 'EOQ Settings',
        'color': Colors.brown,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EOQSetting(),
            ),
          );
        }
      },
      {
        'icon': Icons.receipt,
        'label': 'EOQ Analisis',
        'color': Colors.brown,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EOQAnalisis(),
            ),
          );
        }
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildIconItem(
          menuItems[index]['icon'] as IconData,
          menuItems[index]['label'] as String,
          menuItems[index]['color'] as Color,
          menuItems[index]['onTap'] as VoidCallback?,
        );
      },
    );
  }

  Widget _buildPenjualanCard() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LaporanDataPenjualan(),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            // decoration: _boxDecoration(),
            decoration: BoxDecoration(
              border: Border.all(
                // Mengatur border
                color: Colors.blueGrey, // Warna border
                width: 0.2, // Ketebalan border
              ),
              borderRadius:
                  BorderRadius.circular(10), // Membuat border melengkung
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 30,
                        ),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Penjualan bulan ini',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Rp${formatter(totalPenjualan)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                // Text(
                                //   '▼0%',
                                //   style: TextStyle(
                                //     color: Colors.red,
                                //     fontSize: 14,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.teal,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Transaksi',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                totalTransaksi.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 4),
                              // Text(
                              //   '▼0%',
                              //   style: TextStyle(
                              //     color: Colors.red,
                              //     fontSize: 14,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40, // Sesuaikan tinggi dengan kontennya
                      child: VerticalDivider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    // SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Produk Terjual',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 4),
                                // Text(
                                //   '▼0%',
                                //   style: TextStyle(
                                //     color: Colors.red,
                                //     fontSize: 14,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIconItem(
      IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
    );
  }

  // --- Fungsi untuk menampilkan dialog ---
  void _showAddBalanceDialog(BuildContext context) {
    _amountController.clear(); // Bersihkan input sebelumnya
    _descriptionController.clear(); // Bersihkan input sebelumnya

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Tambah Saldo Kas Utama',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey, // Hubungkan form key
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Agar column tidak mengambil ruang lebih
                children: <Widget>[
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CurrencyInputFormatter(
                        thousandSeparator: ThousandSeparator.Period,
                        mantissaLength: 0,
                        trailingSymbol: '',
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Saldo (Rp)',
                      hintText: 'Cth: 1000000',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Masukkan jumlah yang valid (angka positif)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                      hintText: 'Cth: Deposit dari owner',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              onPressed: _handleDeposit, // Panggil fungsi penanganan deposit
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}
