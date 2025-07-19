import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EOQDetail extends StatefulWidget {
  final Map<String, dynamic> eoqData;

  const EOQDetail({Key? key, required this.eoqData}) : super(key: key);

  @override
  _EOQDetailState createState() => _EOQDetailState();
}

class _EOQDetailState extends State<EOQDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eoq = widget.eoqData;
    final String materialName =
        eoq['raw_material_name'].toString().capitalize();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      appBar: AppBar(
        title: Text(
          materialName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Overview", icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: "Analisis", icon: Icon(Icons.analytics, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final eoq = widget.eoqData;
    final double calculatedEOQ = (eoq['eoq'] as num?)?.toDouble() ?? 0.0;
    final double annualDemand =
        (eoq['annual_demand'] as num?)?.toDouble() ?? 0.0;
    final double orderCost = (eoq['order_cost'] as num?)?.toDouble() ?? 0.0;
    final double holdingCost = (eoq['holding_cost'] as num?)?.toDouble() ?? 0.0;
    final String unit = eoq['unit'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B4513),
                  const Color(0xFF8B4513).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.eoqData['raw_material_name']
                                  .toString()
                                  .capitalize(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Economic Order Quantity Analysis",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.trending_up,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "EOQ Optimal: ${calculatedEOQ.toStringAsFixed(2)} $unit",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Key Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildMetricCard(
                "Demand Tahunan",
                "${annualDemand.toStringAsFixed(0)} $unit",
                Icons.show_chart,
                const Color(0xFF2196F3),
              ),
              _buildMetricCard(
                "Biaya Pesan",
                "Rp ${NumberFormat('#,##0', 'id_ID').format(orderCost)}",
                Icons.shopping_cart,
                const Color(0xFF4CAF50),
              ),
              _buildMetricCard(
                "Biaya Simpan",
                "Rp ${NumberFormat('#,##0', 'id_ID').format(holdingCost)}",
                Icons.warehouse,
                const Color(0xFFFF9800),
              ),
              _buildMetricCard(
                "Frekuensi Order",
                "${annualDemand > 0 ? (annualDemand / calculatedEOQ).toStringAsFixed(1) : '0'}x/tahun",
                Icons.refresh,
                const Color(0xFF9C27B0),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Additional Info Card
          _buildInfoCard(),

          const SizedBox(height: 24),

          // Quick Analysis Card
          _buildQuickAnalysisCard(),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    final eoq = widget.eoqData;
    final double calculatedEOQ = (eoq['eoq'] as num?)?.toDouble() ?? 0.0;
    final double annualDemand =
        (eoq['annual_demand'] as num?)?.toDouble() ?? 0.0;
    final double orderCost = (eoq['order_cost'] as num?)?.toDouble() ?? 0.0;
    final double holdingCost = (eoq['holding_cost'] as num?)?.toDouble() ?? 0.0;
    final String unit = eoq['unit'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frequency Analysis
          _buildAnalysisCard(
            "Analisis Frekuensi Pemesanan",
            Icons.schedule,
            _buildFrequencyAnalysis(calculatedEOQ, annualDemand, unit),
          ),

          const SizedBox(height: 20),

          // Cost Analysis
          _buildAnalysisCard(
            "Analisis Biaya",
            Icons.attach_money,
            _buildCostAnalysis(
                calculatedEOQ, annualDemand, orderCost, holdingCost, unit),
          ),

          const SizedBox(height: 20),

          // Efficiency Analysis
          _buildAnalysisCard(
            "Analisis Efisiensi",
            Icons.trending_up,
            _buildEfficiencyAnalysis(
                calculatedEOQ, annualDemand, orderCost, holdingCost, unit),
          ),

          const SizedBox(height: 20),

          // Recommendations
          _buildAnalysisCard(
            "Rekomendasi & Peringatan",
            Icons.lightbulb,
            _buildRecommendations(
                calculatedEOQ, annualDemand, orderCost, holdingCost, unit),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF8B4513),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Informasi Tambahan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                "ID Bahan Baku", widget.eoqData['raw_material_id'].toString()),
            const SizedBox(height: 8),
            _buildInfoRow("Terakhir diperbarui",
                DateFormat('dd MMM yyyy').format(DateTime.now())),
            const SizedBox(height: 8),
            _buildInfoRow("Status", "Aktif"),
            const SizedBox(height: 8),
            _buildInfoRow("Satuan", widget.eoqData['unit'] ?? 'unit'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAnalysisCard() {
    final eoq = widget.eoqData;
    final double calculatedEOQ = (eoq['eoq'] as num?)?.toDouble() ?? 0.0;
    final double annualDemand =
        (eoq['annual_demand'] as num?)?.toDouble() ?? 0.0;
    // final double orderCost = (eoq['order_cost'] as num?)?.toDouble() ?? 0.0;
    // final double holdingCost = (eoq['holding_cost'] as num?)?.toDouble() ?? 0.0;
    final String unit = eoq['unit'] ?? '';

    // Calculate frequency
    String frequencyText = '';
    if (calculatedEOQ > 0 && annualDemand > 0) {
      final double ordersPerYear = annualDemand / calculatedEOQ;
      if (ordersPerYear >= 1.0) {
        frequencyText = '${ordersPerYear.toStringAsFixed(1)} kali per tahun';
      } else {
        final int months = (12 / ordersPerYear).round();
        frequencyText = 'Setiap ${months} bulan';
      }
    }

    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.insights,
                  color: Color(0xFF8B4513),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Analisis Cepat",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Dengan EOQ optimal ${calculatedEOQ.toStringAsFixed(2)} $unit, Anda dapat:",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildQuickAnalysisPoint("Memesan $frequencyText", Icons.schedule),
            const SizedBox(height: 4),
            _buildQuickAnalysisPoint(
                "Mengurangi biaya total inventory", Icons.savings),
            const SizedBox(height: 4),
            _buildQuickAnalysisPoint(
                "Mengoptimalkan pengelolaan stok", Icons.inventory),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAnalysisPoint(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF8B4513), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyAnalysis(
      double calculatedEOQ, double annualDemand, String unit) {
    String frequencyInfo = '';
    String detailedExplanation = '';

    if (calculatedEOQ > 0 && annualDemand > 0) {
      final double ordersPerYear = annualDemand / calculatedEOQ;
      final int daysBetweenOrders = (365 / ordersPerYear).round();

      if (ordersPerYear >= 1.0) {
        frequencyInfo =
            'Anda disarankan melakukan ${ordersPerYear.toStringAsFixed(1)} kali pemesanan per tahun.';
        detailedExplanation =
            'Ini berarti setiap ${daysBetweenOrders} hari sekali Anda perlu melakukan pemesanan.';
      } else {
        final double yearsPerOrder = 1 / ordersPerYear;
        final int totalMonths = (yearsPerOrder * 12).round();
        frequencyInfo =
            'Anda disarankan memesan sekali setiap ${totalMonths} bulan.';
        detailedExplanation =
            'Pemesanan jarang diperlukan karena EOQ mencukupi untuk waktu yang lama.';
      }
    } else {
      frequencyInfo = 'Perhitungan frekuensi tidak tersedia.';
      detailedExplanation = 'Pastikan data demand dan EOQ valid.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            frequencyInfo,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detailedExplanation,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Dengan EOQ ${calculatedEOQ.toStringAsFixed(2)} $unit, Anda dapat mengoptimalkan frekuensi pemesanan dan mengurangi total biaya inventory.",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCostAnalysis(double calculatedEOQ, double annualDemand,
      double orderCost, double holdingCost, String unit) {
    final double totalOrderingCost =
        annualDemand > 0 ? (annualDemand / calculatedEOQ) * orderCost : 0;
    final double totalHoldingCost = calculatedEOQ * holdingCost / 2;
    final double totalCost = totalOrderingCost + totalHoldingCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCostRow("Total Biaya Pemesanan/Tahun", totalOrderingCost,
            const Color(0xFF4CAF50)),
        const SizedBox(height: 8),
        _buildCostRow("Total Biaya Penyimpanan/Tahun", totalHoldingCost,
            const Color(0xFFFF9800)),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildCostRow(
            "Total Biaya Keseluruhan/Tahun", totalCost, const Color(0xFF8B4513),
            isTotal: true),
        const SizedBox(height: 16),

        // Cost breakdown explanation
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Breakdown Biaya:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "• Biaya pemesanan: ${totalCost > 0 ? ((totalOrderingCost / totalCost) * 100).toStringAsFixed(1) : '0'}% dari total biaya",
                style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 4),
              Text(
                "• Biaya penyimpanan: ${totalCost > 0 ? ((totalHoldingCost / totalCost) * 100).toStringAsFixed(1) : '0'}% dari total biaya",
                style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 8),
              const Text(
                "EOQ optimal dicapai ketika kedua biaya seimbang.",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5D4037),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyAnalysis(double calculatedEOQ, double annualDemand,
      double orderCost, double holdingCost, String unit) {
    final double averageInventory = calculatedEOQ / 2;
    final double inventoryTurnover =
        annualDemand > 0 ? annualDemand / averageInventory : 0;
    final double daysOfSupply =
        averageInventory > 0 ? (365 * averageInventory) / annualDemand : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEfficiencyRow("Rata-rata Inventory",
            "${averageInventory.toStringAsFixed(2)} $unit"),
        const SizedBox(height: 8),
        _buildEfficiencyRow("Inventory Turnover",
            "${inventoryTurnover.toStringAsFixed(2)}x per tahun"),
        const SizedBox(height: 8),
        _buildEfficiencyRow(
            "Days of Supply", "${daysOfSupply.toStringAsFixed(0)} hari"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Interpretasi Efisiensi:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                inventoryTurnover > 6
                    ? "• Turnover tinggi: Efisiensi inventory baik"
                    : inventoryTurnover > 2
                        ? "• Turnover sedang: Efisiensi inventory cukup baik"
                        : "• Turnover rendah: Pertimbangkan untuk mengurangi stok",
                style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 4),
              Text(
                daysOfSupply < 60
                    ? "• Days of supply rendah: Risiko stockout, pertimbangkan safety stock"
                    : daysOfSupply < 180
                        ? "• Days of supply optimal: Keseimbangan yang baik"
                        : "• Days of supply tinggi: Risiko kadaluwarsa atau biaya penyimpanan berlebih",
                style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, double cost, Color color,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF5D4037),
          ),
        ),
        Text(
          "Rp ${NumberFormat('#,##0', 'id_ID').format(cost)}",
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(double calculatedEOQ, double annualDemand,
      double orderCost, double holdingCost, String unit) {
    List<String> recommendations = [];
    List<String> warnings = [];

    // Generate recommendations based on EOQ analysis
    final double ordersPerYear =
        annualDemand > 0 ? annualDemand / calculatedEOQ : 0;
    final double averageInventory = calculatedEOQ / 2;
    final double inventoryTurnover =
        annualDemand > 0 ? annualDemand / averageInventory : 0;
    final double daysOfSupply =
        averageInventory > 0 ? (365 * averageInventory) / annualDemand : 0;

    // Recommendations based on order frequency
    if (ordersPerYear > 12) {
      recommendations.add(
          "Frekuensi pemesanan sangat tinggi (${ordersPerYear.toStringAsFixed(1)}x/tahun). Pertimbangkan untuk mengurangi biaya pemesanan atau meningkatkan EOQ.");
    } else if (ordersPerYear < 2) {
      recommendations.add(
          "Frekuensi pemesanan rendah (${ordersPerYear.toStringAsFixed(1)}x/tahun). Pastikan kualitas bahan baku tetap terjaga dengan penyimpanan yang lama.");
    } else {
      recommendations.add(
          "Frekuensi pemesanan optimal (${ordersPerYear.toStringAsFixed(1)}x/tahun). Pertahankan pola pemesanan ini.");
    }

    // Recommendations based on inventory turnover
    if (inventoryTurnover > 12) {
      recommendations.add(
          "Inventory turnover tinggi. Pertimbangkan safety stock untuk menghindari stockout.");
    } else if (inventoryTurnover < 4) {
      warnings.add(
          "Inventory turnover rendah. Risiko barang kadaluwarsa atau biaya penyimpanan berlebih.");
    }

    // Recommendations based on days of supply
    if (daysOfSupply < 30) {
      warnings.add(
          "Days of supply rendah (${daysOfSupply.toStringAsFixed(0)} hari). Risiko stockout tinggi.");
    } else if (daysOfSupply > 180) {
      warnings.add(
          "Days of supply tinggi (${daysOfSupply.toStringAsFixed(0)} hari). Risiko kadaluwarsa atau biaya penyimpanan berlebih.");
    }

    // Cost-based recommendations
    final double totalOrderingCost =
        annualDemand > 0 ? (annualDemand / calculatedEOQ) * orderCost : 0;
    final double totalHoldingCost = calculatedEOQ * holdingCost / 2;
    final double costDifference = (totalOrderingCost - totalHoldingCost).abs();
    final double totalCost = totalOrderingCost + totalHoldingCost;

    if (costDifference > (totalCost * 0.1)) {
      recommendations.add(
          "Biaya pemesanan dan penyimpanan tidak seimbang. Evaluasi ulang parameter biaya.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recommendations.isNotEmpty) ...[
          const Text(
            "Rekomendasi:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF5D4037)),
                      ),
                    ),
                  ],
                ),
              )),
        ],

        if (recommendations.isNotEmpty && warnings.isNotEmpty)
          const SizedBox(height: 16),

        if (warnings.isNotEmpty) ...[
          const Text(
            "Peringatan:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5722),
            ),
          ),
          const SizedBox(height: 8),
          ...warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning,
                        color: Color(0xFFFF5722), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF5D4037)),
                      ),
                    ),
                  ],
                ),
              )),
        ],

        if (recommendations.isEmpty && warnings.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.thumb_up, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Analisis EOQ menunjukkan parameter yang optimal. Pertahankan strategi inventory saat ini.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Additional insights
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tips Optimasi:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "• Review EOQ secara berkala (3-6 bulan) untuk menyesuaikan dengan perubahan demand",
                style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 4),
              const Text(
                "• Pertimbangkan diskon kuantitas dari supplier saat menentukan order quantity",
                style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 4),
              const Text(
                "• Monitor lead time supplier untuk menentukan reorder point yang tepat",
                style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 4),
              const Text(
                "• Pertimbangkan seasonal demand dalam perhitungan EOQ",
                style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
