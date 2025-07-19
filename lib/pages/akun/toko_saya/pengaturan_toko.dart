// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:caffe_pandawa/widgets/akun/toko_saya/pengaturan_toko_widget.dart';

// class PengaturanToko extends StatefulWidget {
//   const PengaturanToko({Key? key}) : super(key: key);

//   @override
//   State<PengaturanToko> createState() => _PengaturanTokoState();
// }

// class _PengaturanTokoState extends State<PengaturanToko> {
//   final TenantServices services = TenantServices();
//   final FlutterSecureStorage storage = FlutterSecureStorage();

//   bool isPriceRoundingEnabled = false;
//   bool isScanSoundEnabled = false;
//   bool isStorePublic = false;
//   bool isLoading = false;

//   late Toko toko;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     getTenant();
//   }

//   Future<void> getTenant() async {
//     String? _toko = await storage.read(key: '_tenant');
//     setState(() {
//       toko = Toko.fromJson(jsonDecode(_toko!));
//       isStorePublic = toko.statusPublic;
//       isScanSoundEnabled = toko.deringScan;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Pengaturan Toko',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.cyan,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (!didPop) {
//             if (isLoading) return;
//             Navigator.pop(context);
//           }
//         },
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 color: Colors.cyan,
//                 padding: const EdgeInsets.only(
//                   left: 20,
//                   right: 20,
//                   bottom: 30,
//                 ),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Konfigurasi Toko Anda',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       'Sesuaikan pengaturan untuk meningkatkan efisiensi operasional toko Anda',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'PENGATURAN UMUM',
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               buildSettingCard(
//                 title: 'Pembulatan Harga',
//                 subtitle:
//                     'Aktifkan fitur pembulatan otomatis untuk harga produk',
//                 description:
//                     'Harga produk akan dibulatkan ke atas untuk mempermudah transaksi dan mengurangi kebutuhan uang receh.',
//                 value: isPriceRoundingEnabled,
//                 onChanged: (value) async {
//                   setState(() {
//                     isPriceRoundingEnabled = value;
//                   });

//                   print(value);
//                   final result = await services.editStatusPublicTenant(
//                     toko.id,
//                     value,
//                   );
//                   setState(() {
//                     isStorePublic = value;
//                     toko = result;
//                     print(result.statusPublic);
//                   });

//                   await storage.write(
//                       key: '_tenant', value: jsonEncode(toko.toJson()));
//                 },
//               ),
//               buildSettingCard(
//                 title: 'Dering Scan Produk',
//                 subtitle:
//                     'Aktifkan notifikasi suara dan getar saat scan produk',
//                 description:
//                     'Perangkat akan mengeluarkan bunyi saat barcode produk berhasil terdeteksi untuk konfirmasi cepat.',
//                 value: isScanSoundEnabled,
//                 onChanged: (value) async {
//                   setState(() {
//                     isScanSoundEnabled = value;
//                     isLoading = true;
//                   });
//                   final result = await services.editStatusDeringScan(
//                     toko.id,
//                     value,
//                   );
//                   if (mounted) {
//                     setState(() {
//                       toko = result;
//                       print(result.deringScan);
//                     });

//                     await storage.write(
//                         key: '_tenant', value: jsonEncode(toko.toJson()));

//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'VISIBILITAS TOKO',
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _buildStoreVisibilityCard(),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStoreVisibilityCard() {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Status Toko',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               'Atur visibilitas toko Anda untuk umum atau privat',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Column(
//                 children: [
//                   RadioListTile<bool>(
//                     title: const Text(
//                       'Publik',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 15,
//                       ),
//                     ),
//                     subtitle: const Text(
//                       'Toko Anda dapat dilihat oleh semua pengguna',
//                       style: TextStyle(fontSize: 13),
//                     ),
//                     value: true,
//                     groupValue: isStorePublic,
//                     activeColor: Colors.cyan,
//                     onChanged: (value) async {
//                       setState(() {
//                         isLoading = true;
//                         isStorePublic = value!;
//                       });

//                       final result = await services.editStatusPublicTenant(
//                         toko.id,
//                         value!,
//                       );
//                       setState(() {
//                         toko = result;
//                         print(result.statusPublic);
//                       });

//                       await storage.write(
//                           key: '_tenant', value: jsonEncode(toko.toJson()));

//                       setState(() {
//                         isLoading = false;
//                       });
//                     },
//                   ),
//                   Divider(height: 1, color: Colors.grey.shade300),
//                   RadioListTile<bool>(
//                     title: const Text(
//                       'Privat',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 15,
//                       ),
//                     ),
//                     subtitle: const Text(
//                       'Toko Anda tidak dapat dilihat oleh siapapun di ruang publik',
//                       style: TextStyle(fontSize: 13),
//                     ),
//                     value: false,
//                     groupValue: isStorePublic,
//                     activeColor: Colors.cyan,
//                     onChanged: (value) async {
//                       setState(() {
//                         isLoading = true;
//                         isStorePublic = value!;
//                       });

//                       final result = await services.editStatusPublicTenant(
//                         toko.id,
//                         value!,
//                       );
//                       setState(() {
//                         toko = result;
//                         print(result.statusPublic);
//                       });

//                       await storage.write(
//                           key: '_tenant', value: jsonEncode(toko.toJson()));

//                       setState(() {
//                         isLoading = false;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.cyan.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: Colors.cyan.withOpacity(0.2),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     size: 18,
//                     color: Colors.cyan[700],
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       isStorePublic
//                           ? 'Dengan status Publik, toko Anda dapat ditemukan oleh semua pengguna aplikasi. Ini meningkatkan visibilitas dan potensi transaksi.'
//                           : 'Dengan status Privat, toko Anda tidak dapat ditemukan oleh semua pengguna aplikasi, hanya dapat diakses oleh pengguna yang telah Anda berikan izin khusus. Cocok untuk toko dengan layanan eksklusif.',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.cyan[800],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
