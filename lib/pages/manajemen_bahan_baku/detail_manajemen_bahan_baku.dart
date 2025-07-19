import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/models/BahanBakuInventory.dart';

class DetailManajemenBahanBaku extends StatefulWidget {
  final BahanBaku bahanBaku;

  const DetailManajemenBahanBaku({Key? key, required this.bahanBaku})
      : super(key: key);

  @override
  State<DetailManajemenBahanBaku> createState() =>
      _DetailManajemenBahanBakuState();
}

class _DetailManajemenBahanBakuState extends State<DetailManajemenBahanBaku>
    with TickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.cyan,
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
                    // Navigasi ke halaman edit Bahan Baku
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
                          Text('Duplikat Bahan Baku'),
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
                          Text('Arsipkan Bahan Baku'),
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
                          Text('Hapus Bahan Baku'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Header Section
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProductHeader(),
                    SizedBox(height: 20),
                    _buildQuickStats(),
                  ],
                ),
              ),
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
                    Tab(text: 'Inventori'),
                    Tab(text: 'Riwayat'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: Column(
          children: [
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(),
                  _buildInventoryTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: widget.bahanBaku.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.bahanBaku.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  ),
                )
              : _buildImagePlaceholder(),
        ),

        SizedBox(width: 16),

        // Product Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bahanBaku.namaBahanBaku.capitalize(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              if (widget.bahanBaku.kodeBahanBaku != null)
                Text(
                  'Kode: ${widget.bahanBaku.kodeBahanBaku}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.bahanBaku.isActive
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.bahanBaku.isActive
                            ? Colors.green[200]!
                            : Colors.red[200]!,
                      ),
                    ),
                    child: Text(
                      widget.bahanBaku.isActive ? 'Aktif' : 'Tidak Aktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.bahanBaku.isActive
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                  ),
                  // SizedBox(width: 8),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue[50],
                  //     borderRadius: BorderRadius.circular(6),
                  //     border: Border.all(color: Colors.blue[200]!),
                  //   ),
                  //   child: Text(
                  //     widget.bahanBaku.productType == "is_producible"
                  //         ? "Bahan Baku Sendiri"
                  //         : widget.bahanBaku.productType == "single"
                  //             ? "Bahan Baku Tunggal"
                  //             : "Bahan Baku Bundling",
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.blue[700],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Icon(
      Icons.inventory_2_outlined,
      size: 40,
      color: Colors.grey[400],
    );
  }

  Widget _buildQuickStats() {
    double totalStock = (widget.bahanBaku.bahanBakuInventory)
        .fold(0, (sum, inv) => sum + inv.stock);
    int availableOutlets = widget.bahanBaku.bahanBakuInventory
        // .where((inv) => inv.isAvailableInOutlet)
        .where((inv) => inv.locationType != 'main_warehouse')
        .length;

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.inventory_outlined,
          title: 'Total Stok',
          value: '${totalStock.toInt()} ${widget.bahanBaku.unitOfMeasure}',
          color: Colors.blue,
        ),
        SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.store_outlined,
          title: 'Outlet Tersedia',
          value: '$availableOutlets Outlet',
          color: Colors.green,
        ),
        // SizedBox(width: 12),
        // _buildStatCard(
        //   icon: Icons.attach_money_outlined,
        //   title: 'Harga Default',
        //   value: 'Rp${formatter(widget.product.defaultSellingPrice)}.000',
        //   color: Colors.orange,
        // ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Informasi Dasar', [
            _buildInfoRow(
                'Nama Bahan Baku', widget.bahanBaku.namaBahanBaku.capitalize()),
            if (widget.bahanBaku.kodeBahanBaku != null)
              _buildInfoRow('Kode Bahan Baku', widget.bahanBaku.kodeBahanBaku!),
            _buildInfoRow('Satuan', widget.bahanBaku.unitOfMeasure),
            _buildInfoRow(
              'Harga Jual Standart',
              'Rp${formatter(widget.bahanBaku.standartCostPrice)}',
            ),
          ]),
          SizedBox(height: 24),
          _buildInfoSection('Detail Tambahan', [
            _buildInfoRow(
                'Status', widget.bahanBaku.isActive ? 'Aktif' : 'Tidak Aktif'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: widget.bahanBaku.bahanBakuInventory.length,
      itemBuilder: (context, index) {
        final inventory = widget.bahanBaku.bahanBakuInventory[index];
        return _buildInventoryCard(inventory);
      },
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Riwayat Stok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fitur riwayat akan segera tersedia',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(BahanBakuInventory inventory) {
    bool isLowStock = inventory.stock <= inventory.minStockAlert;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInventoryInfo(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stok Saat Ini',
                    value: '${formatter(inventory.stock)}',
                    color: isLowStock ? Colors.red : Colors.blue,
                    showWarning: isLowStock,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInventoryInfo(
                    icon: Icons.warning_outlined,
                    label: 'Min. Stok',
                    value: '${formatter(inventory.minStockAlert)}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInventoryInfo(
                    icon: Icons.category,
                    label: 'Stok terkunci untuk\nproduksi',
                    value: formatter(inventory.stockAllocated),
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInventoryInfo(
                    icon: Icons.trending_down_outlined,
                    label: 'HPP (Harga Asli)\n',
                    value: 'Rp${formatter(inventory.costPrice)}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Terakhir diperbarui: ${DateFormat('dd/MM/yyyy HH:mm').format(inventory.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showWarning = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              if (showWarning) ...[
                SizedBox(width: 4),
                Icon(Icons.warning, size: 14, color: Colors.red),
              ],
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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
