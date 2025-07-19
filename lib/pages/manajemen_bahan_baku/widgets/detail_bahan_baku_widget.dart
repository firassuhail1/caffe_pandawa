import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/services/product_services.dart';

final ProductServices services = ProductServices();

Widget imageHeader(BahanBaku product) {
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
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                  color: Colors.brown,
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
      // if (product.productInventory.isAvailableInOutlet == true)
      //   Positioned(
      //     top: 16,
      //     right: 16,
      //     child: Container(
      //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //       decoration: BoxDecoration(
      //         color: Colors.green,
      //         borderRadius: BorderRadius.circular(20),
      //       ),
      //       child: const Text(
      //         'Tersedia',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ),
      // if (product.productInventory.isAvailableInOutlet == false)
      //   Positioned(
      //     top: 16,
      //     right: 16,
      //     child: Container(
      //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //       decoration: BoxDecoration(
      //         color: Colors.red,
      //         borderRadius: BorderRadius.circular(20),
      //       ),
      //       child: const Text(
      //         'Tidak Tersedia',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ),
    ],
  );
}

Widget priceSection(BahanBaku product, double untung) {
  return Container(
    padding: EdgeInsets.all(0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selling Price
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.brown.withOpacity(0.1),
                Colors.brown.withOpacity(0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       'Harga Jual',
              //       style: TextStyle(
              //         color: Colors.grey[600],
              //         fontSize: 14,
              //       ),
              //     ),
              //     Text(
              //       'Rp${formatter(productInventory.sellingPrice)}',
              //       style: TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.brown[700],
              //       ),
              //     ),
              //   ],
              // ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AKTIF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // Cost and Profit Details
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Harga Pokok',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      // 'Rp${formatter(productInventory.costPrice)}',
                      'Rp${formatter(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              // ),
              // SizedBox(width: 12),
              // Expanded(
              //   child: Container(
              //     padding: EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: Colors.green[50],
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: Colors.green[200]!),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             Icon(Icons.trending_up,
              //                 size: 16, color: Colors.green[600]),
              //             SizedBox(width: 4),
              //             Text(
              //               'Keuntungan',
              //               style: TextStyle(
              //                 color: Colors.green[600],
              //                 fontSize: 12,
              //               ),
              //             ),
              //           ],
              //         ),
              //         SizedBox(height: 4),
              //         Text(
              //           'Rp${formatter(productInventory.sellingPrice - productInventory.costPrice)}',
              //           style: TextStyle(
              //             fontSize: 16,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.green[700],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Profit Margin
        // Container(
        //   padding: EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.blue[50],
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.blue[200]!),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Row(
        //         children: [
        //           Icon(Icons.percent, size: 16, color: Colors.blue[600]),
        //           SizedBox(width: 4),
        //           Text(
        //             'Margin Keuntungan',
        //             style: TextStyle(
        //               color: Colors.blue[600],
        //               fontSize: 12,
        //             ),
        //           ),
        //         ],
        //       ),
        //       Text(
        //         '${(((productInventory.sellingPrice - productInventory.costPrice) / productInventory.sellingPrice) * 100).toStringAsFixed(1)}%',
        //         style: TextStyle(
        //           fontSize: 14,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.blue[700],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    ),
  );
}

// Widget stockAndBundlingInfo(BahanBaku product, Outlet? outlet) {
//   if (outlet == null) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.orange.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.orange.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning, color: Colors.orange),
//           SizedBox(width: 8),
//           Text(
//             'Data outlet tidak ditemukan',
//             style: TextStyle(
//               color: Colors.orange[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   final productInventory = product.bahanBakuInventory
//       .firstWhere((item) => item.outlet?.id == outlet.id);

//   // Determine stock status
//   Color stockColor;
//   IconData stockIcon;
//   String stockStatus;

//   if (productInventory.stock <= 0) {
//     stockColor = Colors.red;
//     stockIcon = Icons.warning;
//     stockStatus = 'Habis';
//   } else if (productInventory.stock <= 10) {
//     stockColor = Colors.orange;
//     stockIcon = Icons.warning_amber;
//     stockStatus = 'Menipis';
//   } else {
//     stockColor = Colors.green;
//     stockIcon = Icons.check_circle;
//     stockStatus = 'Tersedia';
//   }

//   return Column(
//     children: [
//       Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     stockColor.withOpacity(0.1),
//                     stockColor.withOpacity(0.05)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: stockColor.withOpacity(0.3)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(stockIcon, color: stockColor, size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Stok Tersedia',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: stockColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     '${formatter(productInventory.stock - (productInventory.stockAllocated ?? 0))} ${product.unitOfMeasure}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: stockColor,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       stockStatus,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     stockColor.withOpacity(0.1),
//                     stockColor.withOpacity(0.05)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: stockColor.withOpacity(0.3)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(stockIcon, color: stockColor, size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Min. Stok',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: stockColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     '${formatter(productInventory.minStockAlert)} ${product.unitOfMeasure}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: stockColor,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       stockStatus,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),

//       SizedBox(height: 12),

//       Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.purple[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.purple.withOpacity(0.3)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.category, color: Colors.purple, size: 18),
//                       SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           'Total Stok',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.purple,
//                             fontSize: 13,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     '${formatter(productInventory.stock)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     product.unitOfMeasure,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.purple[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.purple.withOpacity(0.3)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.category, color: Colors.purple, size: 18),
//                       SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           'Dalam Produksi',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.purple,
//                             fontSize: 13,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     '${formatter(productInventory.stockAllocated)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     product.unitOfMeasure,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),

//       // // Stock Level Indicator
//       // Container(
//       //   padding: EdgeInsets.all(12),
//       //   decoration: BoxDecoration(
//       //     color: Colors.grey[50],
//       //     borderRadius: BorderRadius.circular(8),
//       //     border: Border.all(color: Colors.grey[200]!),
//       //   ),
//       //   child: Column(
//       //     crossAxisAlignment: CrossAxisAlignment.start,
//       //     children: [
//       //       Row(
//       //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //         children: [
//       //           Text(
//       //             'Level Stok',
//       //             style: TextStyle(
//       //               fontSize: 12,
//       //               color: Colors.grey[600],
//       //               fontWeight: FontWeight.w500,
//       //             ),
//       //           ),
//       //           Text(
//       //             '${productInventory.currentStock.toStringAsFixed(0)} dari target minimum',
//       //             style: TextStyle(
//       //               fontSize: 12,
//       //               color: Colors.grey[600],
//       //             ),
//       //           ),
//       //         ],
//       //       ),
//       //       SizedBox(height: 6),
//       //       LinearProgressIndicator(
//       //         value: productInventory.currentStock <= 0
//       //             ? 0
//       //             : (productInventory.currentStock /
//       //                     (productInventory.currentStock + 20))
//       //                 .clamp(0.0, 1.0),
//       //         backgroundColor: Colors.grey[300],
//       //         valueColor: AlwaysStoppedAnimation<Color>(stockColor),
//       //         minHeight: 6,
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     ],
//   );
// }

Widget descriptionProduct(Product product) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.description, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Text(
            'Catatan Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Divider(),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          product.keterangan ?? 'Tidak ada catatan untuk produk ini.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: product.keterangan != null
                ? Colors.grey[800]
                : Colors.grey[500],
            fontStyle: product.keterangan != null
                ? FontStyle.normal
                : FontStyle.italic,
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
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final response = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Konfirmasi Hapus"),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Apakah Anda yakin ingin menghapus produk ini?'),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.red[600], size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tindakan ini tidak dapat dibatalkan!',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Hapus"),
                    ),
                  ],
                ),
              );

              if (response == true) {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Menghapus produk...'),
                        ],
                      ),
                    ),
                  ),
                );

                final result = await services.deleteProduct(product.id);

                Navigator.pop(context); // Close loading dialog

                if (result['success'] == true) {
                  await Flushbar(
                    margin: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.green.shade600,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    duration: const Duration(seconds: 3),
                    messageText: Text(
                      result['message'] ?? 'Produk berhasil dihapus',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ).show(context);

                  Navigator.pop(context, true);
                } else {
                  await Flushbar(
                    margin: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.red.shade600,
                    icon: const Icon(Icons.error, color: Colors.white),
                    duration: const Duration(seconds: 3),
                    messageText: Text(
                      result['message'] ?? 'Gagal menghapus produk',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ).show(context);
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, size: 18),
                SizedBox(width: 4),
                Text(
                  'Hapus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              // TODO: Implement edit functionality
              // final result = await Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (_) => EditProduk(
              //       product: product,
              //     ),
              //   ),
              // );

              // if (result) {
              //   onRefresh();
              // }

              // For now, show coming soon message
              await Flushbar(
                margin: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(12),
                backgroundColor: Colors.blue.shade600,
                icon: const Icon(Icons.info, color: Colors.white),
                duration: const Duration(seconds: 2),
                messageText: Text(
                  'Fitur edit produk akan segera tersedia',
                  style: const TextStyle(color: Colors.white),
                ),
              ).show(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 6),
                Text(
                  'Edit Produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
