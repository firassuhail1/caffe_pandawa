import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/models/BahanBakuInventoryBatch.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/widgets/detail_bahan_baku_widget.dart';
import 'package:caffe_pandawa/services/bahan_baku_services.dart';

class DetailBahanBaku extends StatefulWidget {
  final BahanBaku bahanBaku;

  const DetailBahanBaku({super.key, required this.bahanBaku});

  @override
  State<DetailBahanBaku> createState() => _DetailBahanBakuState();
}

class _DetailBahanBakuState extends State<DetailBahanBaku>
    with TickerProviderStateMixin {
  final BahanBakuServices services = BahanBakuServices();

  late TabController _tabController;
  bool isLoadingBatches = false;

  late BahanBaku data;
  List<BahanBakuInventoryBatch> batches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed to 2 tabs
    data = widget.bahanBaku;

    fetchBatches();
  }

  void fetchBatches() async {
    setState(() {
      isLoadingBatches = true;
    });

    try {
      // Assuming you have a method to fetch batches
      // final result = await services.getProductBatches(data.id, outlet?.id);
      // For now, using mock data structure
      setState(() {
        // batches = result;
        isLoadingBatches = false;
      });
    } catch (e) {
      setState(() {
        isLoadingBatches = false;
      });
    }
  }

  // void getProduct(int identifier) async {
  //   final result = await services.getBahanBaku(identifier);
  //   print("result : $result");
  //   setState(() {
  //     data = result;
  //   });
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pop(context, true);
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                floating: false,
                expandedHeight: 0,
                title: const Text(
                  'Detail Bahan Baku',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined),
                    onPressed: () {
                      // Navigasi ke halaman edit produk
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // Handle menu actions
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text('Duplikat Produk'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(
                              Icons.archive_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text('Arsipkan Produk'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text('Hapus Produk'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Product Image Header
              SliverToBoxAdapter(
                child: imageHeader(data),
              ),

              // Sticky TabBar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue[600],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.blue[600],
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Informasi'),
                      Tab(text: 'Riwayat'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(),
              _buildBatchTab(widget.bahanBaku),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   decoration: const BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black12,
      //         blurRadius: 10,
      //         offset: Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: bottomMenu(context, data, () {
      //     setState(() {
      //       getProduct(data.id);
      //     });
      //   }),
      // ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Text(
              data.namaBahanBaku.capitalize(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // Product Code
            if (data.kodeBahanBaku != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      'Kode: ',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      data.kodeBahanBaku!,
                      style: TextStyle(
                        color: Colors.brown[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Price Section
            priceSection(data, 0),
            SizedBox(height: 20),
            // Stock and Bundling Info
            // stockAndBundlingInfo(data),
            SizedBox(height: 24),
            // Description
            // descriptionProduct(data),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchTab(BahanBaku bahanBaku) {
    batches = bahanBaku.bahanBakuInventoryBatch;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content
            if (isLoadingBatches)
              _buildLoadingState()
            else if (batches.isEmpty)
              _buildEmptyState()
            else
              _buildBatchContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data batch...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.brown.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Batch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada batch inventory untuk produk ini.\nTambahkan batch pertama Anda untuk memulai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Add batch functionality
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Batch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchContent() {
    return Column(
      children: [
        // Quick Stats
        _buildQuickStats(widget.bahanBaku),

        const SizedBox(height: 24),

        // Batch List
        _buildBatchList(),

        const SizedBox(height: 24),

        // Detailed Summary
        _buildDetailedSummary(),
      ],
    );
  }

  Widget _buildQuickStats(BahanBaku bahanBaku) {
    // final inventory = bahanBaku.bahanBakuInventory;

    final totalBatches = batches.length;
    final totalRemaining =
        batches.fold(0.0, (sum, batch) => sum + batch.quantityRemaining);
    // final lowStockBatches = batches
    //     .where((batch) => batch.quantityRemaining / inventory < 0.2)
    //     .length;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Total Batch', '$totalBatches',
                Icons.layers_rounded, Colors.brown)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Total Sisa',
                '${totalRemaining.toStringAsFixed(0)}',
                Icons.inventory_rounded,
                Colors.green)),
        const SizedBox(width: 12),
        // Expanded(
        //     child: _buildStatCard('Stok Rendah', '$lowStockBatches',
        //         Icons.warning_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_rounded, color: Colors.brown.shade600, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Daftar Batch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...batches.map((batch) => _buildModernBatchCard(batch)).toList(),
      ],
    );
  }

  Widget _buildModernBatchCard(BahanBakuInventoryBatch batch) {
    // final remainingPercentage =
    //     (batch.quantityRemaining / batch.quantityIn) * 100;
    // final isLowStock = remainingPercentage < 20;
    // final isMediumStock = remainingPercentage < 50 && remainingPercentage >= 20;

    // Color stockColor = isLowStock
    //     ? Colors.red
    //     : (isMediumStock ? Colors.orange : Colors.green);
    // Color sourceColor = _getSourceColor(batch.sourceType);
    // IconData sourceIcon = _getSourceIcon(batch.sourceType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // sourceColor.withOpacity(0.1),
                  // sourceColor.withOpacity(0.05)
                  Colors.red,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // color: sourceColor.withOpacity(0.2),
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.checklist, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSourceDisplayName("sourceType"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Batch #${batch.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${100.toStringAsFixed(1)}%',
                    // '${remainingPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sisa Stok',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${batch.quantityRemaining.toStringAsFixed(0)} / ${batch.quantityRemaining.toStringAsFixed(0)} ${widget.bahanBaku.unitOfMeasure}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value:
                            batch.quantityRemaining / batch.quantityRemaining,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        'Tanggal Masuk',
                        '${batch.entryDateTime.day}/${batch.entryDateTime.month}/${batch.entryDateTime.year}',
                        Icons.calendar_today_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        'Unit Cost',
                        'Rp${formatter(batch.unitCost)}',
                        Icons.monetization_on_rounded,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        'Total Value',
                        'Rp${formatter(batch.quantityRemaining * batch.unitCost)}',
                        Icons.account_balance_wallet_rounded,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        'Status',
                        // isLowStock
                        //     ? 'Stok Rendah'
                        //     : (isMediumStock ? 'Stok Sedang' : 'Stok Aman'),
                        'Stok Rendah',
                        Icons.info_rounded,
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                // if (batch.notes != null && batch.notes!.isNotEmpty) ...[
                //   const SizedBox(height: 12),
                //   Container(
                //     width: double.infinity,
                //     padding: const EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       color: Colors.grey.shade50,
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(color: Colors.grey.shade200),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Icon(Icons.notes_rounded,
                //                 size: 16, color: Colors.grey.shade600),
                //             const SizedBox(width: 6),
                //             Text(
                //               'Catatan',
                //               style: TextStyle(
                //                 fontSize: 12,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.grey.shade600,
                //               ),
                //             ),
                //           ],
                //         ),
                //         const SizedBox(height: 4),
                //         Text(
                //           batch.notes!,
                //           style: const TextStyle(
                //             fontSize: 14,
                //             color: Colors.black87,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
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
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSummary() {
    if (batches.isEmpty) return const SizedBox.shrink();

    final totalQuantityIn =
        batches.fold(0.0, (sum, batch) => sum + batch.quantityRemaining);
    final totalQuantityRemaining =
        batches.fold(0.0, (sum, batch) => sum + batch.quantityRemaining);
    final totalValue = batches.fold(
        0.0, (sum, batch) => sum + (batch.quantityRemaining * batch.unitCost));
    final avgUnitCost =
        batches.fold(0.0, (sum, batch) => sum + batch.unitCost) /
            batches.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.summarize_rounded,
                    color: Colors.brown.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ringkasan Batch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: [
              _buildSummaryCard('Total Masuk', formatter(totalQuantityIn),
                  Icons.input_rounded, Colors.blue),
              _buildSummaryCard('Total Sisa', formatter(totalQuantityRemaining),
                  Icons.inventory_rounded, Colors.green),
              _buildSummaryCard(
                  'Nilai Total',
                  'Rp${shortFormatter(totalValue)}',
                  Icons.monetization_on_rounded,
                  Colors.purple),
              _buildSummaryCard(
                  'Rata-rata Cost',
                  'Rp${shortFormatter(avgUnitCost)}',
                  Icons.calculate_rounded,
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSourceColor(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'production':
        return Colors.blue;
      case 'purchase':
        return Colors.green;
      case 'transfer_in':
        return Colors.orange;
      case 'initial_stock':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSourceIcon(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'production':
        return Icons.precision_manufacturing;
      case 'purchase':
        return Icons.shopping_cart;
      case 'transfer_in':
        return Icons.move_to_inbox;
      case 'initial_stock':
        return Icons.inventory_2;
      default:
        return Icons.help_outline;
    }
  }

  String _getSourceDisplayName(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'production':
        return 'Produksi';
      case 'purchase':
        return 'Pembelian';
      case 'transfer_in':
        return 'Transfer Masuk';
      case 'initial_stock':
        return 'Stok Awal';
      default:
        return sourceType;
    }
  }
}

// Custom delegate for sticky TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
