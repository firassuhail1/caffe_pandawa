import 'package:caffe_pandawa/pages/laporan/laporan_penjualan/laporan_data_penjualan.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/services/laporan_penjualan_services.dart';

class LaporanKeuangan extends StatefulWidget {
  const LaporanKeuangan({super.key});

  @override
  State<LaporanKeuangan> createState() => _LaporanKeuanganState();
}

class _LaporanKeuanganState extends State<LaporanKeuangan> {
  double labaKotor = 0;
  double totalPenjualan = 0;
  int totalTransaksi = 0;
  String? selectedPeriod = "monthly";
  DateTime? startDate;
  DateTime? endDate;
  bool showCustomDateRange = false;
  bool isLoading = false;

  // Rigid color scheme - more formal and stark
  static const Color primaryDark = Colors.brown;
  static const Color accentGray = Colors.brown;
  static const Color borderGray = Color(0xFFCCCCCC);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);

  List<Map<String, dynamic>> periods = [
    {'value': 'daily', 'label': 'HARI INI', 'icon': Icons.today},
    {'value': 'weekly', 'label': 'MINGGU INI', 'icon': Icons.view_week},
    {'value': 'monthly', 'label': 'BULAN INI', 'icon': Icons.calendar_month},
    {'value': 'yearly', 'label': 'TAHUN INI', 'icon': Icons.calendar_month},
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchLabaKotor("monthly"),
      _fetchTotalPenjualan('monthly'),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      if (startDate != null && endDate != null) {
        _fetchCustomRangeData();
      }
    }
  }

  Future<void> _fetchCustomRangeData() async {
    if (startDate == null || endDate == null) return;
    setState(() => isLoading = true);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() => isLoading = false);
  }

  Future<void> _fetchLabaKotor(String period) async {
    final result = await LaporanPenjualanServices().getLabaKotor(period);
    if (result['success'] && mounted) {
      setState(() {
        labaKotor = result['laba_kotor'];
      });
    }
  }

  Future<void> _fetchTotalPenjualan(String period) async {
    final result =
        await LaporanPenjualanServices().laporanTotalPenjualan(period);
    if (result['success'] && mounted) {
      setState(() {
        totalPenjualan = result['total_penjualan'];
        totalTransaksi = result['total_transaksi'];
      });
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with stark background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentGray,
              border: Border(bottom: BorderSide(color: borderGray)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          // Content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDateSelector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: showCustomDateRange ? null : 0,
      child: showCustomDateRange
          ? Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderGray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentGray,
                          border: Border(bottom: BorderSide(color: borderGray)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'RENTANG TANGGAL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDateSelector(
                                label: 'DARI TANGGAL',
                                date: startDate,
                                onTap: () => _selectDate(context, true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateSelector(
                                label: 'SAMPAI TANGGAL',
                                date: endDate,
                                onTap: () => _selectDate(context, false),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundGray,
          border: Border.all(color: borderGray),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                        : 'PILIH TANGGAL',
                    style: TextStyle(
                      fontSize: 12,
                      color: date != null ? textPrimary : textSecondary,
                      fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text(
          'LAPORAN KEUANGAN',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentGray,
                        border: Border(bottom: BorderSide(color: borderGray)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'FILTER PERIODE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'PILIH PERIODE',
                          labelStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: borderGray),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: borderGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide:
                                BorderSide(color: primaryDark, width: 2),
                          ),
                          prefixIcon:
                              Icon(Icons.calendar_today, color: textSecondary),
                          filled: true,
                          fillColor: backgroundGray,
                        ),
                        value: selectedPeriod,
                        items: periods.map((period) {
                          return DropdownMenuItem<String>(
                            value: period['value'],
                            child: Row(
                              children: [
                                Icon(period['icon'],
                                    size: 16, color: textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  period['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) async {
                          setState(() {
                            selectedPeriod = value;
                            showCustomDateRange = value == 'custom';
                            if (value != 'custom') {
                              startDate = null;
                              endDate = null;
                            }
                          });

                          if (selectedPeriod != 'custom') {
                            setState(() => isLoading = true);
                            await Future.wait([
                              _fetchLabaKotor(selectedPeriod ?? "monthly"),
                              _fetchTotalPenjualan(selectedPeriod ?? "monthly"),
                            ]);
                            setState(() => isLoading = false);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Custom Date Range
              _buildCustomDateSelector(),

              const SizedBox(height: 16),

              // Statistics Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildStatCard(
                    title: 'Laba Kotor',
                    value: 'Rp ${formatter(labaKotor)}',
                    icon: Icons.trending_up,
                    color: primaryDark,
                  ),
                  // _buildStatCard(
                  //   title: 'Laba Bersih',
                  //   value: 'Rp 0',
                  //   icon: Icons.account_balance_wallet,
                  //   color: primaryDark,
                  // ),
                ],
              ),

              const SizedBox(height: 16),

              // Sales Data Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentGray,
                        border: Border(bottom: BorderSide(color: borderGray)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.point_of_sale,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'DATA PENJUALAN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (isLoading)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Total Sales
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundGray,
                              border: Border.all(color: borderGray),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL PENJUALAN',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp${formatter(totalPenjualan)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryDark,
                                    border: Border.all(color: borderGray),
                                  ),
                                  child: Text(
                                    '$totalTransaksi TRANSAKSI',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // View Details Button
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LaporanDataPenjualan(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderGray),
                                color: backgroundGray,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.visibility,
                                          color: textSecondary, size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'LIHAT DETAIL PENJUALAN',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward,
                                      color: textSecondary, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
