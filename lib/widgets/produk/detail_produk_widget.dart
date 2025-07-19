import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/pages/produk/edit_produk.dart';
import 'package:caffe_pandawa/services/product_services.dart';

final ProductServices services = ProductServices();

Widget imageHeader(Product product) {
  return Stack(
    children: [
      Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: product.image != null
            ? CachedNetworkImage(
                imageUrl: product.image!,
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                  color: Colors.brown[400],
                )),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 50, color: Colors.red),
                fit: BoxFit.cover,
              )
            : Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.grey[400],
                ),
              ),
      ),
      if (product.status == true)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tersedia',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      if (product.status == false)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tidak Tersedia',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );
}

Widget priceSection(Product product, double untung) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.brown.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Price with Previous Price if available
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp${formatter(product.harga)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700],
              ),
            ),
            // SizedBox(width: 8),
            // if (product.hargaJualSebelumnya != null)
            //   Expanded(
            //     child: Text(
            //       "${formatter(product.hargaJualSebelumnya)}",
            //       style: const TextStyle(
            //         decoration: TextDecoration.lineThrough,
            //         color: Colors.grey,
            //         fontSize: 16,
            //       ),
            //       overflow: TextOverflow.ellipsis,
            //     ),
            //   ),
          ],
        ),
        SizedBox(height: 8),

        Text(
          'Untung: ${formatter(untung)}',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),

        // Original Price if available
        if (product.hargaAsliProduct != null)
          Text(
            'Harga Asli: ${formatter(product.hargaAsliProduct)}',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),

        if (product.hargaAsliSebelumnya != null)
          Text(
            'Harga Asli Sebelumnya: ${formatter(product.hargaAsliSebelumnya)}',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),

        // Bundling Prices if available
        if (product.hargaJualProductBundling != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Harga Bundling: ${formatter(product.hargaJualProductBundling)}',
              style: TextStyle(
                color: Colors.brown[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        if (product.hargaAsliProductBundling != null)
          Text(
            'Harga Asli Bundling: ${formatter(product.hargaAsliProductBundling)}',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
      ],
    ),
  );
}

Widget stockAndBundlingInfo(Product product) {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2, color: Colors.brown),
                  SizedBox(width: 8),
                  Text(
                    'Stok',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '${product.stock.toInt()} pcs',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: 12),
      if (product.jmlProductPerBundling != null)
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pcs/bundling',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '${product.jmlProductPerBundling!.toInt()} pcs',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

Widget descriptionProduct(Product product) {
  return Wrap(
    children: [
      const Text(
        'Deskripsi Produk',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          product.keterangan ?? 'Tidak ada deskripsi produk',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

Widget bottomMenu(
  BuildContext context,
  Product product,
  VoidCallback onRefresh,
) {
  return Row(
    children: [
      Expanded(
        flex: 1,
        child: Container(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final response = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content:
                      Text('Apakah anda yakin ingin menghapus produk ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[400]),
                      child: const Text("Yakin",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (response == true) {
                final result = await services.deleteProduct(product.id);

                if (result['success'] == true) {
                  await Flushbar(
                    margin: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.green.shade600,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    duration: const Duration(seconds: 2),
                    messageText: Text(
                      result['message'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ).show(context);

                  Navigator.pop(context, true);
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: Container(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProduk(
                    product: product,
                  ),
                ),
              );

              if (result) {
                onRefresh();
              }
            },
            child: const Text(
              'Edit Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
