// lib/customer/menu_screen.dart

import 'package:caffe_pandawa/customer/cart_screen.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/providers/cart_provider.dart';
import 'package:caffe_pandawa/services/menu_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  final String tableNumber;

  MenuScreen({required this.tableNumber});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Product>> _menuItems;

  // Brown color scheme
  static const Color primaryBrown = Color(0xFF8D5524);
  static const Color lightBrown = Color(0xFFD4A574);
  static const Color darkBrown = Color(0xFF5D2F00);
  static const Color creamBrown = Color(0xFFF5F1EB);
  static const Color accentBrown = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  void _fetchMenu() {
    setState(() {
      _menuItems = MenuService().fetchMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: creamBrown,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBrown, darkBrown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Caffe Pandawa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Meja ${widget.tableNumber}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) => Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_rounded,
                            color: Colors.white, size: 26),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(
                                tableNumber: widget.tableNumber,
                              ),
                            ),
                          );

                          if (result) {
                            _fetchMenu();
                          }
                        },
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: accentBrown,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [creamBrown, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Product>>(
          future: _menuItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBrown),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Memuat menu...',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red[300],
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Gagal Memuat Menu',
                        style: TextStyle(
                          color: darkBrown,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _fetchMenu,
                        icon: Icon(Icons.refresh_rounded),
                        label: Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          color: lightBrown,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Menu Belum Tersedia',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mohon tunggu, menu sedang disiapkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    _fetchMenu();
                    // await Future.delayed(Duration(milliseconds: 500));
                  },
                  color: primaryBrown,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            child: Opacity(
                              opacity: product.stock > 0 ? 1.0 : 0.6,
                              child: InkWell(
                                onTap: () {
                                  // Tambah detail product jika diperlukan
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [lightBrown, primaryBrown],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.local_cafe_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.namaProduct,
                                              style: TextStyle(
                                                color: darkBrown,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Rp ${product.harga.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                color: primaryBrown,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  product.stock > 0
                                                      ? Icons
                                                          .inventory_2_outlined
                                                      : Icons.warning_outlined,
                                                  size: 14,
                                                  color: product.stock > 0
                                                      ? Colors.grey[600]
                                                      : Colors.red[400],
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  product.stock > 0
                                                      ? 'Stok: ${product.stock}'
                                                      : 'Habis',
                                                  style: TextStyle(
                                                    color: product.stock > 0
                                                        ? Colors.grey[600]
                                                        : Colors.red[400],
                                                    fontSize: 12,
                                                    fontWeight:
                                                        product.stock > 0
                                                            ? FontWeight.normal
                                                            : FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: product.stock > 0
                                              ? LinearGradient(
                                                  colors: [
                                                    primaryBrown,
                                                    darkBrown
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Colors.grey[400]!,
                                                    Colors.grey[600]!
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: product.stock > 0
                                              ? [
                                                  BoxShadow(
                                                    color: primaryBrown
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: product.stock > 0
                                                ? () {
                                                    cart.addItem(product);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Colors
                                                                    .white,
                                                                size: 20),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                '${product.namaProduct} ditambahkan ke keranjang',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            primaryBrown,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        margin:
                                                            EdgeInsets.all(16),
                                                      ),
                                                    );
                                                  }
                                                : () {
                                                    // Tampilkan pesan jika stok habis
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .warning_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 20),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                '${product.namaProduct} sedang habis',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            Colors.orange[700],
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        margin:
                                                            EdgeInsets.all(16),
                                                      ),
                                                    );
                                                  },
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                product.stock > 0
                                                    ? Icons
                                                        .add_shopping_cart_rounded
                                                    : Icons
                                                        .remove_shopping_cart_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return Center(
              child: Text(
                'Tidak ada data.',
                style: TextStyle(
                  color: darkBrown,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
