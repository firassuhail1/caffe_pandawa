import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:caffe_pandawa/models/CartItems.dart';
import 'package:caffe_pandawa/pages/kasir/pembayaran.dart';

class KeranjangPesanan extends StatefulWidget {
  final List<CartItems>? cartItems;
  const KeranjangPesanan({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<KeranjangPesanan> createState() => _KeranjangPesananState();
}

class _KeranjangPesananState extends State<KeranjangPesanan> {
  // Format uang dalam Rupiah
  final currencyFormatter = NumberFormat("#,###", "id_ID");

  bool isCheckoutVisible = true;

  // Total harga keseluruhan
  double get totalHarga {
    if (widget.cartItems == null || widget.cartItems!.isEmpty) return 0;
    return widget.cartItems!.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Menghapus item dari keranjang
  void removeItem(int index) {
    setState(() {
      widget.cartItems!.removeAt(index);
    });
  }

  // Mengubah jumlah item
  void updateQuantity(CartItems item, double newQuantity, String mode) {
    setState(() {
      if (newQuantity <= 0) {
        widget.cartItems!.remove(item);
      } else {
        item.quantity = newQuantity;
        if (mode == "plus") {
          item.totalHarga = (item.totalHarga ?? 0) + item.product.harga;
        } else {
          item.totalHarga = (item.totalHarga ?? 0) - item.product.harga;
        }
      }
    });
    print(widget.cartItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Keranjang Pesanan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (widget.cartItems != null && widget.cartItems!.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () {
                // Konfirmasi hapus semua item
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Hapus Semua?'),
                    content: Text(
                        'Yakin ingin menghapus semua item dari keranjang?'),
                    actions: [
                      TextButton(
                        child: Text('Batal'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child:
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          setState(() {
                            widget.cartItems!.clear();
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: PopScope(
        canPop: false, // jangan di pop dulu
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // kita intercept dan kirim result secara manual
            Navigator.pop(context, true);
          }
        },
        child: widget.cartItems == null || widget.cartItems!.isEmpty
            ? _buildEmptyCart()
            : _buildCartItems(),
      ),
      bottomNavigationBar: widget.cartItems == null || widget.cartItems!.isEmpty
          ? null
          : _buildCheckoutSection(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Belum ada produk yang ditambahkan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Kembali ke Produk',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return Column(
      children: [
        // Header informasi
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.brown[700], size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anda memiliki ${widget.cartItems!.length} jenis produk di keranjang',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.brown[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // List item keranjang
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8),
            itemCount: widget.cartItems!.length,
            itemBuilder: (context, index) {
              final item = widget.cartItems![index];
              final product = item.product;

              return Padding(
                padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: Dismissible(
                  key: Key(product.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) => removeItem(index),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar produk
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                              ),
                              child: product.image != null
                                  ? Image.network(
                                      product.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey),
                                    )
                                  : Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Informasi produk
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.namaProduct,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Rp${currencyFormatter.format(product.harga).replaceAll(",", ".")}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.brown[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Tombol quantity
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          // Tombol minus
                                          InkWell(
                                            onTap: () => updateQuantity(item,
                                                item.quantity - 1, 'minus'),
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  bottomLeft:
                                                      Radius.circular(7),
                                                ),
                                              ),
                                              child: Icon(Icons.remove,
                                                  size: 16,
                                                  color: Colors.grey[700]),
                                            ),
                                          ),
                                          // Display quantity
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                                right: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          // Tombol plus
                                          InkWell(
                                            onTap: () => updateQuantity(item,
                                                item.quantity + 1, 'plus'),
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(7),
                                                  bottomRight:
                                                      Radius.circular(7),
                                                ),
                                              ),
                                              child: Icon(Icons.add,
                                                  size: 16,
                                                  color: Colors.grey[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Total harga per item
                                    Text(
                                      'Rp${currencyFormatter.format(item.totalPrice).replaceAll(",", ".")}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -3),
            blurRadius: 6,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isCheckoutVisible
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isCheckoutVisible = !isCheckoutVisible;
              });
            },
          ),
          SizedBox(height: 6),
          if (isCheckoutVisible)
            // Ringkasan Harga
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Rp${currencyFormatter.format(totalHarga).replaceAll(",", ".")}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // jika mau menggunakan pajak

                  // SizedBox(height: 8),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Pembulatan',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: Colors.grey[700],
                  //       ),
                  //     ),
                  //     Text(
                  //       'Rp${currencyFormatter.format(totalHarga * 0.11).replaceAll(",", ".")}',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.black87,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 8),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Rp${currencyFormatter.format(totalHarga).replaceAll(",", ".")}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (isCheckoutVisible) SizedBox(height: 16),
          if (!isCheckoutVisible) SizedBox(height: 4),
          // if (isCheckoutVisible)
          // Tombol checkout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Proses checkout
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Pembayaran(
                      cartItems: widget.cartItems,
                      totalAmount: double.parse(
                          (totalHarga).toStringAsFixed(1)), // Misalnya 75000.0
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proses Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
