import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/pages/beranda/eoq/eoq_detail.dart';
import 'package:caffe_pandawa/pages/beranda/eoq/eoq_settings.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/services/eoq_services.dart';

class EOQAnalisis extends StatefulWidget {
  const EOQAnalisis({super.key});

  @override
  _EOQAnalisisState createState() => _EOQAnalisisState();
}

class _EOQAnalisisState extends State<EOQAnalisis> {
  final EOQServices _services = EOQServices();
  List<Map<String, dynamic>> _eoqList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final eoqData = await _services.fetchAllEOQ();
      setState(() {
        _eoqList = eoqData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $_errorMessage")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToEOQSetting([Map<String, dynamic>? existingData]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EOQSetting(existingData: existingData),
      ),
    );

    if (result == true) {
      _loadData(); // Refresh data setelah kembali dari setting
    }
  }

  void _navigateToEOQDetail(Map<String, dynamic> eoqData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EOQDetail(eoqData: eoqData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      appBar: AppBar(
        title: const Text("Analisis EOQ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B4513)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF8B4513),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B4513),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Economic Order Quantity",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Optimalisasi Pemesanan Bahan Baku ${DateTime.now().year}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    "Total Bahan Baku",
                                    "${_eoqList.length}",
                                    Icons.inventory_2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    "Tersetting",
                                    "${_eoqList.where((e) => e['eoq'] != null && e['eoq'] > 0).length}",
                                    Icons.check_circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Daftar Bahan Baku",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToEOQSetting(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Tambah EOQ"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _errorMessage.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : _eoqList.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Belum ada data EOQ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Tambahkan pengaturan EOQ untuk memulai analisis",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final eoq = _eoqList[index];
                                  return _buildEOQCard(eoq);
                                },
                                childCount: _eoqList.length,
                              ),
                            ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEOQCard(Map<String, dynamic> eoq) {
    final double calculatedEOQ = (eoq['eoq'] as num?)?.toDouble() ?? 0.0;
    final int annualDemand = (eoq['annual_demand'] as num?)?.toInt() ?? 0;
    final String unit = eoq['unit'] ?? '';
    final bool hasEOQ = calculatedEOQ > 0;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: hasEOQ ? () => _navigateToEOQDetail(eoq) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: hasEOQ
                            ? const Color(0xFF8B4513)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: hasEOQ ? Colors.white : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eoq['raw_material_name'].toString().capitalize(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasEOQ
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              hasEOQ ? "Tersetting" : "Belum Tersetting",
                              style: TextStyle(
                                fontSize: 12,
                                color: hasEOQ
                                    ? const Color(0xFF4CAF50)
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEOQSetting(eoq);
                        } else if (value == 'detail' && hasEOQ) {
                          _navigateToEOQDetail(eoq);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Setting'),
                            ],
                          ),
                        ),
                        if (hasEOQ)
                          const PopupMenuItem(
                            value: 'detail',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Lihat Detail'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (hasEOQ) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          "EOQ Optimal",
                          "${calculatedEOQ.toStringAsFixed(2)} $unit",
                          Icons.trending_up,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          "Demand/Tahun",
                          "${annualDemand.toStringAsFixed(0)} $unit",
                          Icons.show_chart,
                          const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Tap untuk melihat analisis lengkap",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        "Belum ada pengaturan EOQ",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }
}

// Import untuk halaman EOQ Setting dan EOQ Detail
// class EOQSetting extends StatefulWidget { ... }
// class EOQDetail extends StatefulWidget { ... }