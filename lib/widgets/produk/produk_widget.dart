import 'package:flutter/material.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/pages/produk/detail_produk.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/pages/produk/edit_produk.dart';
import 'package:caffe_pandawa/services/product_services.dart';

final ProductServices services = ProductServices();

Widget buildProductCard(BuildContext context, Product product, int index,
    VoidCallback onRefresh, final Function(int, bool) updateProductStatus) {
  return GestureDetector(
    onTap: () async {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailProduk(
            product: product,
          ),
        ),
      );

      if (result) {
        onRefresh();
      }
    },
    child: Container(
      // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: rigidBoxDecoration(),
      child: Column(
        children: [
          // Header Section - Fixed Height
          Container(
            height: 80,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Image Container - Fixed Size
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.zero, // Sharp corners
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: CachedNetworkImage(
                      imageUrl: product.image ?? "",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                        ),
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.broken_image,
                          size: 24,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),

                // Product Info - Fixed Layout
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Product Name - Fixed Height
                        Container(
                          height: 20,
                          child: Text(
                            product.namaProduct,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.0,
                            ),
                          ),
                        ),

                        SizedBox(height: 4),

                        // Price - Fixed Height
                        Container(
                          height: 16,
                          child: Text(
                            'Rp ${formatter(product.harga)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Button - Fixed Size
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[700],
                      size: 18,
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: Colors.grey[400]!, width: 1),
                    ),
                    onSelected: (value) async {
                      await _handleMenuAction(
                          context, value, product, onRefresh);
                    },
                    itemBuilder: (context) => [
                      _buildRigidPopupItem(Icons.info_outline, 'Detail Produk',
                          Colors.grey.shade700, 'detail'),
                      _buildRigidPopupItem(Icons.edit_outlined, 'Edit Produk',
                          Colors.blueGrey, 'edit'),
                      _buildRigidPopupItem(Icons.delete_outline, 'Hapus Produk',
                          Colors.red.shade600, 'hapus',
                          isDanger: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section - Fixed Height
          Container(
            height: 60,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Section - Fixed Width
                Container(
                  width: 120,
                  child: Row(
                    children: [
                      // Switch Container - Fixed Size
                      Container(
                        width: 36,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Transform.scale(
                          scaleY: 0.6,
                          scaleX: 0.7,
                          child: Switch(
                            value: product.status ?? true,
                            onChanged: (value) async {
                              try {
                                updateProductStatus(index, value);
                                services.editStatusProduct(product.id, value);
                              } catch (e) {
                                print('Error updating status: $e');
                              }
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Colors.brown[600],
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey[200],
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      // Status Text - Fixed
                      Container(
                        child: Text(
                          product.status ?? true ? 'TERSEDIA' : 'HABIS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.status ?? true
                                ? Colors.green[700]
                                : Colors.red[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Spacer
                Spacer(),

                // Stock Section - Fixed Layout
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    border: Border.all(
                      color: Colors.brown[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    'STOK: ${formatter(product.stock)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown[700],
                      letterSpacing: 0.3,
                    ),
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

// Rigid Box Decoration
BoxDecoration rigidBoxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: Colors.grey[400]!,
      width: 1,
    ),
    borderRadius: BorderRadius.zero, // Sharp corners
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: Offset(0, 2),
        blurRadius: 0, // No blur for sharp shadow
        spreadRadius: 0,
      ),
    ],
  );
}

// Rigid Shimmer Card
Widget buildShimmerCard() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: rigidBoxDecoration(),
    child: Column(
      children: [
        // Header Section
        Container(
          height: 80,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Image Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Text Shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        width: 100,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Button Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content Section
        Container(
          height: 60,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Switch Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 16,
                  width: 80,
                  color: Colors.grey[200],
                ),
              ),

              Spacer(),

              // Stock Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 24,
                  width: 60,
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Rigid Popup Menu Item
PopupMenuItem<String> _buildRigidPopupItem(
    IconData icon, String text, Color color, String value,
    {bool isDanger = false}) {
  return PopupMenuItem<String>(
    value: value,
    height: 40,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDanger ? Colors.red[600] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Menu Action Handler
Future<void> _handleMenuAction(BuildContext context, String value,
    Product product, VoidCallback onRefresh) async {
  switch (value) {
    case 'detail':
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailProduk(product: product),
        ),
      );
      if (result) onRefresh();
      break;

    case 'edit':
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditProduk(product: product),
        ),
      );
      if (result) onRefresh();
      break;

    case 'hapus':
      final response = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.grey[400]!, width: 1),
          ),
          title: Text(
            "KONFIRMASI HAPUS",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          content: Container(
            child: Text(
              'Apakah Anda yakin ingin menghapus produk ini?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          actions: [
            Container(
              height: 36,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                ),
                child: Text(
                  "BATAL",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              height: 36,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Colors.red[700]!, width: 1),
                  ),
                ),
                child: Text(
                  "HAPUS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      if (response == true) {
        final result = await services.deleteProduct(product.id);
        if (result['success'] == true) {
          onRefresh();
          Flushbar(
            margin: EdgeInsets.all(16),
            borderRadius: BorderRadius.zero,
            backgroundColor: Colors.green.shade600,
            icon: Icon(Icons.check_circle, color: Colors.white),
            duration: Duration(seconds: 3),
            messageText: Text(
              result['message'],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ).show(context);
        }
      }
      break;
  }
}
