import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/helpers/print_kot.dart';
import 'package:caffe_pandawa/models/Order.dart';
import 'package:caffe_pandawa/providers/order_provider.dart';
import 'package:caffe_pandawa/services/order_services.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderProvider()..fetchOrders(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Kasir Caffe Pandawa',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.brown[700],
          foregroundColor: Colors.white,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown[700]!, Colors.brown[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.grey[100],
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop Layout
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OrderListPanel(),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    flex: 2,
                    child: OrderDetailPanel(),
                  ),
                ],
              );
            } else {
              // Mobile Layout
              return MobileOrderView();
            }
          },
        ),
      ),
    );
  }
}

class MobileOrderView extends StatefulWidget {
  @override
  _MobileOrderViewState createState() => _MobileOrderViewState();
}

class _MobileOrderViewState extends State<MobileOrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Make TabController accessible to child widgets
  TabController get tabController => _tabController;

  // Handle back button press
  Future<bool> _onWillPop() async {
    // Jika sedang di tab detail (index 1), kembali ke tab pesanan (index 0)
    if (_tabController.index == 1) {
      _tabController.animateTo(0);
      return false; // Jangan keluar dari halaman
    }

    // Jika sudah di tab pesanan (index 0), izinkan keluar dari halaman
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return PopScope(
      canPop: false, // Jangan langsung keluar
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await _onWillPop();
        // final shouldPop = await _onWillPop();
        // if (shouldPop && context.mounted) {
        //   Navigator.of(context).pop();
        // }
      },

      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.brown[600],
              labelColor: Colors.brown[700],
              unselectedLabelColor: Colors.grey[600],
              tabs: [
                Tab(
                  icon: Icon(Icons.list_alt),
                  text: 'Pesanan',
                ),
                Tab(
                  icon: Icon(Icons.receipt_long),
                  text: 'Detail',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OrderListPanel(),
                orderProvider.selectedOrder != null
                    ? OrderDetailPanel()
                    : _buildSelectOrderMessage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectOrderMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Pilih pesanan terlebih dahulu',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kembali ke tab Pesanan untuk memilih',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderListPanel extends StatefulWidget {
  @override
  _OrderListPanelState createState() => _OrderListPanelState();
}

class _OrderListPanelState extends State<OrderListPanel>
    with SingleTickerProviderStateMixin {
  late TabController _filterTabController;
  String selectedStatus = 'pending'; // Default filter

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 2, vsync: this);

    // Listen to tab changes
    _filterTabController.addListener(() {
      if (_filterTabController.indexIsChanging) return;

      setState(() {
        selectedStatus =
            _filterTabController.index == 0 ? 'pending' : 'processing';
      });
    });
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredOrders(List<dynamic> orders) {
    return orders
        .where((order) =>
            order.statusPesanan.toLowerCase() == selectedStatus.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: true);

    if (orderProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat pesanan...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Filter orders based on selected status
    final filteredOrders = _getFilteredOrders(orderProvider.orders);

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with total count
          Text(
            'Daftar Pesanan (${orderProvider.orders.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 12),

          // Status Filter Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _filterTabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.brown[700],
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedStatus == 'pending'
                              ? Colors.orange[100]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Pending'),
                      ),
                      SizedBox(width: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${orderProvider.orders.where((o) => o.statusPesanan.toLowerCase() == 'pending').length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedStatus == 'processing'
                              ? Colors.blue[100]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Processing'),
                      ),
                      SizedBox(width: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${orderProvider.orders.where((o) => o.statusPesanan.toLowerCase() == 'processing').length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Filtered Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final isSelected =
                          orderProvider.selectedOrder?.id == order.id;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.brown[400]!, width: 2)
                              : Border.all(color: Colors.grey[200]!, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              orderProvider.selectOrder(order);
                              // Auto switch to detail tab on mobile
                              if (MediaQuery.of(context).size.width <= 800) {
                                // Find the ancestor TabController and switch to detail tab
                                final ancestorState =
                                    context.findAncestorStateOfType<
                                        _MobileOrderViewState>();
                                if (ancestorState != null) {
                                  ancestorState.tabController.animateTo(1);
                                }
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.brown[100]
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      Icons.receipt,
                                      color: isSelected
                                          ? Colors.brown[700]
                                          : Colors.grey[600],
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pesanan #${order.orderNumber}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            // Order Source Badge
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    order.orderSource == 'pos'
                                                        ? Colors.green[100]
                                                        : Colors.orange[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                order.orderSource.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      order.orderSource == 'pos'
                                                          ? Colors.green[700]
                                                          : Colors.orange[700],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            // Status Badge
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: order.statusPembayaran ==
                                                        'pending'
                                                    ? Colors.orange[100]
                                                    : Colors.blue[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                order.statusPembayaran
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      order.statusPembayaran ==
                                                              'pending'
                                                          ? Colors.orange[700]
                                                          : Colors.blue[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'Rp ${formatter(order.grandTotal)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.brown[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (order.tableNumber != null) ...[
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.table_restaurant,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Meja ${order.tableNumber}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: selectedStatus == 'pending'
                  ? Colors.orange[50]
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              selectedStatus == 'pending'
                  ? Icons.pending_actions
                  : Icons.hourglass_empty,
              size: 60,
              color: selectedStatus == 'pending'
                  ? Colors.orange[400]
                  : Colors.blue[400],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tidak ada pesanan ${selectedStatus}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            selectedStatus == 'pending'
                ? 'Pesanan pending akan muncul di sini'
                : 'Pesanan yang sedang diproses akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final selectedOrder = orderProvider.selectedOrder;

    if (selectedOrder == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24),
            Text(
              'Pilih pesanan untuk melihat detail',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Klik pesanan dari daftar di sebelah kiri',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (orderProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat pesanan...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Pesanan #${selectedOrder.orderNumber}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedOrder.orderSource == 'pos'
                              ? Colors.green[100]
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedOrder.orderSource.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selectedOrder.orderSource == 'pos'
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.money,
                        'Total: Rp ${formatter(selectedOrder.grandTotal)}',
                        Colors.brown[100]!,
                        Colors.brown[700]!,
                      ),
                      if (selectedOrder.tableNumber != null) ...[
                        SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.table_restaurant,
                          'Meja ${selectedOrder.tableNumber}',
                          Colors.blue[100]!,
                          Colors.blue[700]!,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoChip(
                    Icons.table_restaurant,
                    '${selectedOrder.statusPesanan}',
                    selectedOrder.statusPesanan == "pending"
                        ? Colors.orange[100]!
                        : Colors.blue[100]!,
                    selectedOrder.statusPesanan == "pending"
                        ? Colors.orange[700]!
                        : Colors.blue[700]!,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Items Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.brown[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.brown[400],
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Item Pesanan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                            letterSpacing: -0.2,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.brown[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${selectedOrder.items.length} item',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Items List - Fixed to use proper height constraints
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[100]!, width: 1),
                    ),
                    child: selectedOrder.items.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: [
                              // Use ListView with shrinkWrap and physics
                              ListView.separated(
                                shrinkWrap:
                                    true, // Important: allows ListView to size itself
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable inner scroll
                                padding: EdgeInsets.symmetric(vertical: 8),
                                itemCount: selectedOrder.items.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey[100],
                                  indent: 60,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final item = selectedOrder.items[index];
                                  return _buildOrderItem(item, index);
                                },
                              ),

                              // Total Section
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[25],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Keseluruhan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'Rp ${formatter(selectedOrder.grandTotal)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      selectedOrder.statusPesanan == "pending"
                          ? await _showProcessDialog(
                              context, selectedOrder, "processing")
                          : await _showProcessDialog(
                              context, selectedOrder, "selesai");
                    },
                    icon: Icon(Icons.payment, color: Colors.white),
                    label: Text(
                      selectedOrder.statusPesanan == "pending"
                          ? 'Proses & Cetak'
                          : "Selesai",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showCancelDialog(context, selectedOrder);
                    },
                    icon: Icon(Icons.cancel, color: Colors.white),
                    label: Text(
                      'Batalkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),

            // Add bottom padding to ensure content is not cut off
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProcessDialog(
      BuildContext context, Order order, String status) async {
    final parentContext = context; // simpan context dari parent

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.green[600]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Konfirmasi',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin memproses pesanan untuk pesanan #${order.orderNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);

                if (status == "processing") {
                  await _processOrder(parentContext, order, 'processing');
                } else {
                  await _processOrder(parentContext, order, 'finished');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
              child: Text('Proses', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processOrder(
      BuildContext context, Order order, String status) async {
    List<int> kotBytes = await Print.instance.printKOT(order);

    if (status == "processing") {
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (isConnected) {
        // flushbarMessage(context, 'Pesanan berhasil diproses dan KOT dicetak',
        //     Colors.green.shade600, Icons.check_circle);
      } else {
        showConnectionFlushbar(context, "Printer belum terhubung.");
        return;
      }
    }

    try {
      // 1. Mengubah status pesanan di backend menjadi 'processing'
      showLoadingDialog(context);

      final response =
          await OrderService().updateOrderStatus(order.orderNumber, status);

      print(response.body);

      if (response.statusCode == 200) {
        if (status == "processing") {
          // 2. Jika sukses, cetak struk via printer thermal
          await PrintBluetoothThermal.writeBytes(kotBytes);
        }

        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);

        // 3. Dismiss the loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        await orderProvider.getOrderDetail(order.orderNumber);
        await flushbarMessage(context, 'Pesanan berhasil diproses',
            Colors.green.shade600, Icons.check_circle);
      } else {
        await flushbarMessage(context, 'Gagal memproses pesanan',
            Colors.red.shade600, Icons.error);
        // 3. Dismiss the loading dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      await flushbarMessage(
          context, 'Terjadi kesalahan', Colors.red.shade600, Icons.error);
      // 3. Dismiss the loading dialog
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Function to show the loading dialog
  void showLoadingDialog(BuildContext context) {
    showDialog(
      // Prevents the user from dismissing the dialog by tapping outside
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          // Also prevents back button dismissal
          canPop: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
                ),
                SizedBox(height: 16),
                Text(
                  'Tunggu sebentar...',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, Order order) {
    final parentContext = context;
    // Ambil provider dari context sebelum showDialog
    final orderProvider =
        Provider.of<OrderProvider>(parentContext, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Konfirmasi Pembatalan',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin membatalkan pesanan #${order.orderNumber}? '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                // Tampilkan loading
                showLoadingDialog(parentContext);

                final response = await OrderService().deleteOrder(order.id);

                // Tutup loading
                if (parentContext.mounted) {
                  Navigator.of(parentContext, rootNavigator: true).pop();
                }

                if (response.statusCode == 200 || response.statusCode == 201) {
                  await orderProvider.fetchOrders();
                  orderProvider.selectOrder(null);

                  if (parentContext.mounted) {
                    await flushbarMessage(
                      parentContext,
                      'Pesanan berhasil dibatalkan',
                      Colors.green.shade600,
                      Icons.check_circle,
                    );
                  }
                } else {
                  if (parentContext.mounted) {
                    await flushbarMessage(
                      parentContext,
                      'Gagal membatalkan pesanan',
                      Colors.red.shade600,
                      Icons.error,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
              ),
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderItem(dynamic item, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Icon/Image Placeholder
          // Container(
          //   width: 44,
          //   height: 44,
          //   decoration: BoxDecoration(
          //     color: Colors.brown[400],
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Icon(
          //     _getItemIcon(item.productName),
          //     color: Colors.white,
          //     size: 20,
          //   ),
          // ),

          // SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 4),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.qty}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rp ${formatter(item.unitPrice)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),

                // Catatan khusus jika ada
                if (item.notes != null && item.notes.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber[100]!, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note,
                          size: 12,
                          color: Colors.amber[700],
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.notes,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber[700],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 12),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${formatter(item.totalPrice)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              if (item.qty > 1)
                Text(
                  '@ ${formatter(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method untuk empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: Colors.grey[300],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada item',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Item pesanan akan muncul di sini',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method untuk mendapatkan icon berdasarkan nama produk
  IconData _getItemIcon(String productName) {
    final name = productName.toLowerCase();

    if (name.contains('coffee') || name.contains('kopi')) {
      return Icons.local_cafe;
    } else if (name.contains('tea') || name.contains('teh')) {
      return Icons.emoji_food_beverage;
    } else if (name.contains('cake') || name.contains('kue')) {
      return Icons.cake;
    } else if (name.contains('sandwich') || name.contains('burger')) {
      return Icons.lunch_dining;
    } else if (name.contains('juice') || name.contains('jus')) {
      return Icons.local_drink;
    } else if (name.contains('snack') || name.contains('makanan ringan')) {
      return Icons.fastfood;
    } else {
      return Icons.restaurant;
    }
  }
}
