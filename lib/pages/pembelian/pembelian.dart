import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/Purchase.dart';
import 'package:caffe_pandawa/pages/pembelian/detail_pembelian.dart';
import 'package:caffe_pandawa/pages/pembelian/pembelian_form.dart';
import 'package:caffe_pandawa/services/pembelian_services.dart';
import 'package:intl/intl.dart';

enum FilterPeriod { daily, weekly, monthly, yearly, custom }

class Pembelian extends StatefulWidget {
  const Pembelian({super.key});

  @override
  State<Pembelian> createState() => _PembelianState();
}

class _PembelianState extends State<Pembelian> {
  List<Purchase> dataPembelian = [];
  List<Purchase> filteredPembelian = [];

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  final TextEditingController searchController = TextEditingController();

  // Filter variables
  FilterPeriod selectedPeriod = FilterPeriod.monthly;
  DateTime? customStartDate;
  DateTime? customEndDate;

  // Theme colors
  static const Color primaryColor = Colors.brown;
  static const Color primaryLight = Color(0xFFE0F7FA);
  static const Color backgroundColor = Colors.white;
  static const Color successColor = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    loadData();
  }

  void loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
    }

    try {
      final result = await PembelianServices()
          .getDataPembelian(selectedPeriod.name, null, null);

      if (mounted) {
        setState(() {
          dataPembelian = result;
          filteredPembelian = dataPembelian;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Gagal memuat data pembelian: ${e.toString()}';
        });
      }
    }
  }

  void _applyFilters() async {
    List<Purchase> filtered = dataPembelian;

    // Apply search filter
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      filtered = filtered.where((purchase) {
        final invoiceNumber = purchase.invoiceNumber.toLowerCase();

        if (invoiceNumber.contains(query)) {
          return true;
        }
        return false;
      }).toList();
    }

    // // Apply period filter
    // filtered = await _filterByPeriod();

    setState(() {
      filteredPembelian = filtered;
      isLoading = false;
    });
  }

  Future<List<Purchase>> _filterByPeriod() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
    }

    try {
      final result = await PembelianServices().getDataPembelian(
          selectedPeriod.name, customStartDate, customEndDate);
      setState(() {
        isLoading = false;
      });

      return result;
    } catch (e) {
      return [];
    }
  }

  void _filterPembelian(String query) {
    _applyFilters();
  }

  void _onPeriodChanged(FilterPeriod period) async {
    List<Purchase> filtered;

    setState(() {
      selectedPeriod = period;
      if (selectedPeriod.name == 'custom') _selectCustomDateRange();
      if (period != FilterPeriod.custom) {
        customStartDate = null;
        customEndDate = null;
      }
    });

    filtered = await _filterByPeriod();
    setState(() {
      filteredPembelian = filtered;
      isLoading = false;
    });
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      List<Purchase> filtered = dataPembelian;

      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
        selectedPeriod = FilterPeriod.custom;
      });

      // Apply period filter
      filtered = await _filterByPeriod();

      setState(() {
        filteredPembelian = filtered;
        isLoading = false;
      });
    }
  }

  String _getPeriodDisplayText() {
    switch (selectedPeriod) {
      case FilterPeriod.daily:
        return 'Hari Ini';
      case FilterPeriod.weekly:
        return 'Minggu Ini';
      case FilterPeriod.monthly:
        return 'Bulan Ini';
      case FilterPeriod.yearly:
        return 'Tahun Ini';
      case FilterPeriod.custom:
        if (customStartDate != null && customEndDate != null) {
          return '${_formatDate(customStartDate!)} - ${_formatDate(customEndDate!)}';
        }
        return 'Custom';
      default:
        return 'Bulan Ini';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _refreshData() async {
    loadData();
  }

  void _navigateToForm() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => const PembelianForm(),
      ),
    )
        .then((_) {
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: _buildBody(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Data Pembelian',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter',
        ),
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, sestate) {
            return AlertDialog(
              title: const Text('Filter Periode'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption(FilterPeriod.daily, 'Hari Ini'),
                  _buildFilterOption(FilterPeriod.weekly, 'Minggu Ini'),
                  _buildFilterOption(FilterPeriod.monthly, 'Bulan Ini'),
                  _buildFilterOption(FilterPeriod.yearly, 'Tahun Ini'),
                  _buildFilterOption(FilterPeriod.custom, 'Custom'),
                  if (selectedPeriod == FilterPeriod.custom) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _selectCustomDateRange();
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text('Pilih Tanggal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(FilterPeriod period, String title) {
    return RadioListTile<FilterPeriod>(
      title: Text(title),
      value: period,
      groupValue: selectedPeriod,
      activeColor: primaryColor,
      onChanged: (FilterPeriod? value) {
        if (value != null) {
          Navigator.pop(context);
          _onPeriodChanged(value);
        }
      },
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: primaryColor,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          _buildFilterChip(),
          _buildSearchSection(),
          _buildContent(),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Periode: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          _getPeriodDisplayText(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                          const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: const BoxDecoration(
        color: primaryColor,
      ),
      child: _buildStatsCard(),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Total Nilai',
            shortFormatter(
                double.tryParse(_calculateTotalValue().replaceAll('.', '')) ??
                    0),
            Icons.attach_money,
            successColor,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            'Total Pembelian',
            '${filteredPembelian.length}',
            Icons.shopping_cart,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalValue() {
    if (filteredPembelian.isEmpty) return 'Rp 0';

    double total = filteredPembelian.fold(
        0, (sum, purchase) => sum + purchase.totalAmount);
    return formatter(total);
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(6),
      color: backgroundColor,
      child: TextField(
        controller: searchController,
        onChanged: _filterPembelian,
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nama supplier...',
          prefixIcon: const Icon(Icons.search, color: primaryColor),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear, color: Colors.grey),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (filteredPembelian.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPembelianList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data pembelian...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              searchController.text.isNotEmpty ||
                      selectedPeriod != FilterPeriod.monthly
                  ? 'Tidak ada hasil yang ditemukan'
                  : 'Belum ada data pembelian',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchController.text.isNotEmpty ||
                      selectedPeriod != FilterPeriod.monthly
                  ? 'Coba ubah filter atau kata kunci pencarian'
                  : 'Mulai buat pembelian pertama Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (searchController.text.isEmpty &&
                selectedPeriod == FilterPeriod.monthly)
              ElevatedButton.icon(
                onPressed: _navigateToForm,
                icon: const Icon(Icons.add),
                label: const Text('Buat Pembelian'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPembelianList() {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPembelian.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final purchase = filteredPembelian[index];
        return _buildPembelianCard(purchase, index);
      },
    );
  }

  Widget _buildPembelianCard(Purchase purchase, int index) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailPembelian(purchase: purchase),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(DateFormat('dd MMMM yyyy', 'id_ID')
                      .format(purchase.purchaseDate)),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        color: successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Total Pembelian:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rp${formatter(purchase.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pembelian #${purchase.invoiceNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToForm,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.add),
      label: const Text(
        'Buat Pembelian',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
