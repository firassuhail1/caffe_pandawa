// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:caffe_pandawa/models/Transaksi.dart';
// import 'package:caffe_pandawa/services/transaksi_services.dart';
// import 'package:caffe_pandawa/widgets/beranda/transaksi/transaksi_widget.dart';

// class TransaksiPage extends StatefulWidget {
//   const TransaksiPage({Key? key}) : super(key: key);

//   @override
//   _TransaksiPageState createState() => _TransaksiPageState();
// }

// class _TransaksiPageState extends State<TransaksiPage> {
//   final TransaksiServices services = TransaksiServices();

//   List<Transaksi> _transaksiList = [];
//   List<Transaksi> _filteredTransaksiList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   String _sortBy = 'newest'; // 'newest', 'oldest', 'highest', 'lowest'
//   String _filterQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchTransaksi();
//   }

//   Future<void> _fetchTransaksi() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     // Ganti dengan URL API Anda
//     final response = await services.fetchTransaksi();

//     if (response['success']) {
//       setState(() {
//         _transaksiList = response["transaksiList"];
//         print("hai : $_transaksiList");
//         _applyFilterAndSort();
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _errorMessage = response["message"];
//         _isLoading = false;
//       });
//     }
//   }

//   void _applyFilterAndSort() {
//     // Apply search filter
//     List<Transaksi> filteredList = _transaksiList;

//     if (_filterQuery.isNotEmpty) {
//       filteredList = filteredList.where((transaksi) {
//         // Filter by ID
//         if (transaksi.id.toString().contains(_filterQuery)) {
//           return true;
//         }

//         // Filter by products
//         for (final item in transaksi.daftarBarang) {
//           if (item.namaProduct
//               .toLowerCase()
//               .contains(_filterQuery.toLowerCase())) {
//             return true;
//           }
//         }

//         // Filter by total
//         if (transaksi.totalBayar.toString().contains(_filterQuery)) {
//           return true;
//         }

//         // Filter by date
//         final dateStr =
//             DateFormat('dd/MM/yyyy HH:mm').format(transaksi.createdAt);
//         if (dateStr.contains(_filterQuery)) {
//           return true;
//         }

//         return false;
//       }).toList();
//     }

//     // Apply sorting
//     switch (_sortBy) {
//       case 'newest':
//         filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//         break;
//       case 'oldest':
//         filteredList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//         break;
//       case 'highest':
//         filteredList.sort((a, b) => b.totalBayar.compareTo(a.totalBayar));
//         break;
//       case 'lowest':
//         filteredList.sort((a, b) => a.totalBayar.compareTo(b.totalBayar));
//         break;
//     }

//     setState(() {
//       _filteredTransaksiList = filteredList;
//     });

//     print("hello : $_filteredTransaksiList");
//   }

//   void _onSearchChanged(String query) {
//     setState(() {
//       _filterQuery = query;
//       _applyFilterAndSort();
//     });
//   }

//   void _onSortChanged(String? value) {
//     if (value != null) {
//       setState(() {
//         _sortBy = value;
//         _applyFilterAndSort();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Riwayat Transaksi'),
//         backgroundColor: Colors.brown,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           TransaksiFilterHeader(
//             searchController: _searchController,
//             onSearchChanged: _onSearchChanged,
//             sortBy: _sortBy,
//             onSortChanged: _onSortChanged,
//             onRefresh: _fetchTransaksi,
//           ),
//           Expanded(
//             child: _buildBody(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const TransaksiLoadingView();
//     }

//     if (_filteredTransaksiList.isEmpty) {
//       return const TransaksiEmptyView();
//     }

//     if (_errorMessage.isNotEmpty) {
//       return TransaksiErrorView(
//         errorMessage: _errorMessage,
//         onRetry: _fetchTransaksi,
//       );
//     }

//     return TransaksiListView(transaksiList: _filteredTransaksiList);
//   }
// }
