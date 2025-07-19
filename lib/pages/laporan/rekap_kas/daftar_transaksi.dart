import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caffe_pandawa/models/Transaksi.dart';
import 'package:caffe_pandawa/services/transaksi_services.dart';
import 'package:caffe_pandawa/widgets/laporan/rekap_kas/daftar_transaksi_widget.dart';

class DaftarTransaksi extends StatefulWidget {
  final List<Transaksi>? transaksi;

  const DaftarTransaksi({Key? key, this.transaksi}) : super(key: key);

  @override
  Daftar_TransaksiState createState() => Daftar_TransaksiState();
}

class Daftar_TransaksiState extends State<DaftarTransaksi> {
  final TransaksiServices services = TransaksiServices();

  List<Transaksi> _transaksiList = [];
  List<Transaksi> _filteredTransaksiList = [];
  String _sortBy = 'newest'; // 'newest', 'oldest', 'highest', 'lowest'
  String _filterQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transaksiList = widget.transaksi ?? [];
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    // Apply search filter
    List<Transaksi> filteredList = _transaksiList;

    if (_filterQuery.isNotEmpty) {
      filteredList = filteredList.where((transaksi) {
        // Filter by ID
        if (transaksi.id.toString().contains(_filterQuery)) {
          return true;
        }

        // Filter by products
        for (final item in transaksi.daftarBarang) {
          if (item.namaProduct
              .toLowerCase()
              .contains(_filterQuery.toLowerCase())) {
            return true;
          }
        }

        // Filter by total
        if (transaksi.totalBayar.toString().contains(_filterQuery)) {
          return true;
        }

        // Filter by date
        final dateStr =
            DateFormat('dd/MM/yyyy HH:mm').format(transaksi.createdAt);
        if (dateStr.contains(_filterQuery)) {
          return true;
        }

        return false;
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filteredList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        filteredList.sort((a, b) => b.totalBayar.compareTo(a.totalBayar));
        break;
      case 'lowest':
        filteredList.sort((a, b) => a.totalBayar.compareTo(b.totalBayar));
        break;
    }

    setState(() {
      _filteredTransaksiList = filteredList;
    });

    print("hello : $_filteredTransaksiList");
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filterQuery = query;
      _applyFilterAndSort();
    });
  }

  void _onSortChanged(String? value) {
    if (value != null) {
      setState(() {
        _sortBy = value;
        _applyFilterAndSort();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // TransaksiFilterHeader(
          //   searchController: _searchController,
          //   onSearchChanged: _onSearchChanged,
          //   sortBy: _sortBy,
          //   onSortChanged: _onSortChanged,
          // ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_filteredTransaksiList.isEmpty) {
      return const TransaksiEmptyView();
    }

    return TransaksiListView(transaksiList: _filteredTransaksiList);
  }
}
