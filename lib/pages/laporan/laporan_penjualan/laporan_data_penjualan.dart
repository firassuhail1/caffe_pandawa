import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/services/laporan_penjualan_services.dart';
import 'package:intl/intl.dart';

class LaporanDataPenjualan extends StatefulWidget {
  const LaporanDataPenjualan({super.key});

  @override
  State<LaporanDataPenjualan> createState() => _LaporanDataPenjualanState();
}

class _LaporanDataPenjualanState extends State<LaporanDataPenjualan> {
  // Data untuk dropdown period
  List<Map<String, dynamic>> periods = [
    {'value': 'daily', 'label': 'Harian'},
    {'value': 'weekly', 'label': 'Mingguan'},
    {'value': 'monthly', 'label': 'Bulanan'},
    {'value': 'yearly', 'label': 'Tahunan'},
    {'value': 'custom', 'label': 'Atur Tanggal'},
  ];

  String? selectedPeriod = "monthly";
  int? selectedOutlet;
  DateTime? startDate;
  DateTime? endDate;
  bool showCustomDateRange = false;
  int? pickedOutlet;

  double totalPenjualan = 0;
  List<Map<String, dynamic>> dataPenjualan = [];
  List<Map<String, dynamic>> dataRingkasan = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchDataPenjualan('monthly', null, null);
  }

  Future<void> _fetchDataPenjualan(
      String period, DateTime? startDate, DateTime? endDate) async {
    final result = await LaporanPenjualanServices()
        .laporanPenjualan(period, startDate, endDate);

    if (result['success']) {
      final convertedData = (result['data_penjualan'] as List)
          .map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e),
          )
          .toList();

      setState(() {
        totalPenjualan = result['total_penjualan'];
        dataPenjualan = convertedData;
        dataRingkasan = result['data_ringkasan'];
      });
    }
  }

  // Function untuk format currency
  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Function untuk memilih tanggal
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      print(startDate);
      print(endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown[600]!, Colors.brown[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dashboard Penjualan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp${formatter(totalPenjualan)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total Penjualan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filter Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Laporan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // // Dropdown Outlet
                // DropdownButtonFormField<int?>(
                //   decoration: InputDecoration(
                //     labelText: 'Pilih Outlet',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     prefixIcon: const Icon(Icons.calendar_today),
                //   ),
                //   value: selectedOutlet,
                //   items: [
                //     DropdownMenuItem<int?>(
                //       value: null, // Atur value khusus untuk 'All', misal -1
                //       child: Text('Semua Outlet'),
                //     ),
                //     ...outlets.map((outlet) {
                //       return DropdownMenuItem<int>(
                //         value: outlet.id,
                //         child: Text(outlet.outletName),
                //       );
                //     }).toList(),
                //   ],
                //   onChanged: (int? value) {
                //     setState(() {
                //       selectedOutlet = value;
                //       print(selectedOutlet);
                //     });
                //   },
                // ),
                // const SizedBox(height: 16),

                // Dropdown Period
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Period',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  value: selectedPeriod,
                  items: periods.map((period) {
                    return DropdownMenuItem<String>(
                      value: period['value'],
                      child: Text(period['label']),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedPeriod = value;
                      showCustomDateRange = value == 'custom';

                      if (value != 'custom') {
                        startDate = null;
                        endDate = null;
                      }
                    });
                  },
                ),

                // Custom Date Range (muncul jika pilih custom)
                if (showCustomDateRange) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    startDate != null
                                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                        : 'Dari Tanggal',
                                    style: TextStyle(
                                      color: startDate != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    endDate != null
                                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                        : 'Sampai Tanggal',
                                    style: TextStyle(
                                      color: endDate != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Button Generate Report
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _fetchDataPenjualan(
                          selectedPeriod ?? "monthly", startDate, endDate);

                      if (selectedOutlet != null) {
                        setState(() {
                          pickedOutlet = selectedOutlet;
                        });
                      } else {
                        setState(() {
                          pickedOutlet = null;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Generate Laporan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Table Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Data Penjualan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...dataRingkasan.map(
                    (e) {
                      return Padding(
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Outlet : ${outlets.firstWhere((element) => element.id == e['outlet_id']).outletName}',
                              //   style: TextStyle(),
                              // ),
                              Text(
                                'Total Transaksi : ${e['jumlah_transaksi']}',
                                style: TextStyle(),
                              ),
                              Text(
                                'Total Penjualan : Rp${formatter(double.parse(e['total_penjualan']))}',
                                style: TextStyle(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey[100]),
                      columns: const [
                        DataColumn(
                            label: Text('Tanggal',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Outlet',
                        //         style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Produk',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Qty',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Harga',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: dataPenjualan.expand((transaksi) {
                        final createdAt =
                            DateTime.parse(transaksi['created_at']);
                        final tanggal = DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(createdAt);
                        // final outlet = transaksi['outlet_id'];
                        // final outletMap = {
                        //   for (var o in outlets) o.id: o.outletName,
                        // };

                        final daftarBarang = transaksi['daftar_barang']
                            as List<Map<String, dynamic>>;

                        return daftarBarang.map((barang) {
                          return DataRow(cells: [
                            DataCell(Text(tanggal)),
                            // DataCell(Text(
                            //     outletMap[outlet] ?? 'Outlet tidak ditemukan')),
                            DataCell(Text(barang['nama_product'] ?? '')),
                            DataCell(Text('${barang['quantity']}')),
                            DataCell(Text(formatCurrency(barang['harga']))),
                            DataCell(Text(
                              formatCurrency(barang['totalHarga']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            )),
                          ]);
                        });
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Keseluruhan:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${formatter(totalPenjualan)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
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
}
