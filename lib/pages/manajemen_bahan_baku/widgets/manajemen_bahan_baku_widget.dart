import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:shimmer/shimmer.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/bahan_baku_form.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/detail_bahan_baku.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/detail_manajemen_bahan_baku.dart';
import 'package:caffe_pandawa/services/bahan_baku_services.dart';

final BahanBakuServices services = BahanBakuServices();

Widget buildBahanBakuOutletCard(BuildContext context, BahanBaku bahanBaku,
    int? outletId, int index, String? inventoryMethod, VoidCallback onRefresh) {
  return GestureDetector(
    onTap: () async {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailBahanBaku(
            bahanBaku: bahanBaku,
          ),
        ),
      );

      if (result) {
        onRefresh();
      }
    },
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bahanBaku.namaBahanBaku.capitalize(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Rp${formatter(bahanBaku.standartCostPrice)}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                  '${formatter(bahanBaku.bahanBakuInventory[0].stock)} ${bahanBaku.unitOfMeasure}'),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                elevation: 8,
                icon: Icon(Icons.more_vert, color: Colors.brown),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                onSelected: (value) async {
                  if (value == 'detail') {
                    // Aksi detail
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailManajemenBahanBaku(
                          bahanBaku: bahanBaku,
                        ),
                      ),
                    );

                    if (result) {
                      onRefresh();
                    }
                  } else if (value == 'edit') {
                    // Aksi edit
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BahanBakuForm(
                          bahanBaku: bahanBaku,
                        ),
                      ),
                    );

                    if (result) {
                      onRefresh();
                    }
                  } else if (value == 'hapus') {
                    final response = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Konfirmasi"),
                        content: Text(
                            'Apakah anda yakin ingin menghapus bahan baku ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Batal"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown),
                            child: const Text("Yakin",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (response == true) {
                      final result =
                          await services.deleteBahanBaku(bahanBaku.id);

                      if (result['success'] == true) {
                        onRefresh();
                        flushbarMessage(context, result['message'],
                            Colors.green.shade600, Icons.check_circle);
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  _buildPopupItem(Icons.info_outline, 'Detail Produk',
                      Colors.grey.shade700, 'detail'),
                  _buildPopupItem(Icons.edit_outlined, 'Edit Produk',
                      Colors.blueGrey, 'edit'),
                  _buildPopupItem(Icons.delete_outline, 'Hapus Bahan Baku',
                      Colors.red.shade400, 'hapus',
                      isDanger: true),
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildBahanBakuCardEmpty() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          color: Colors.grey[400],
          size: 60,
        ),
        const SizedBox(height: 16),
        Text(
          'Tidak ada bahan baku ditemukan',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Belum ada bahan baku yang tersedia atau\ncoba gunakan filter pencarian yang berbeda',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

BoxDecoration boxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
  );
}

Widget buildShimmerCard() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (gambar + teks + icon)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(width: 16),
            // Nama produk & harga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  // Nama produk (panjang)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Harga (pendek)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 10,
                      width: 80,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            // Icon more
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: EdgeInsets.only(top: 14),
                width: 12,
                height: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Footer bawah (Switch dan stok)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Switch dan label 'Tersedia'
            Row(
              children: [
                SizedBox(width: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 12,
                    width: 50,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Info stok
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 12,
                width: 60,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

PopupMenuItem<String> _buildPopupItem(
    IconData icon, String text, Color color, String value,
    {bool isDanger = false}) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: isDanger ? Colors.red[400] : Colors.black87),
        ),
      ],
    ),
  );
}
