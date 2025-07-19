import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/bahan_baku_form.dart';
import 'package:caffe_pandawa/pages/manajemen_bahan_baku/widgets/manajemen_bahan_baku_widget.dart';
import 'package:caffe_pandawa/services/bahan_baku_services.dart';

class ManajemenBahanBaku extends StatefulWidget {
  const ManajemenBahanBaku({super.key});

  @override
  State<ManajemenBahanBaku> createState() => _ManajemenBahanBakuState();
}

class _ManajemenBahanBakuState extends State<ManajemenBahanBaku> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  final BahanBakuServices services = BahanBakuServices();

  PageController _pageController = PageController();
  RefreshController _refreshControllerKelolaBahanBaku = RefreshController();
  RefreshController _refreshControllerOutletBahanBaku = RefreshController();
  int _selectedTabTop = 0;
  TextEditingController searchController = TextEditingController();
  String? inventoryMethod;

  int? outlet;
  late List<BahanBaku> daftar_bahan_baku = [];
  late List<BahanBaku> _filteredProduct;

  bool isLoading = true;
  String _filterQuery = '';

  // belum digunakan
  // Fungsi untuk mengubah tab atas
  void _onTopTabTapped(int index) {
    setState(() {
      _selectedTabTop = index;
    });
    // Mengubah halaman pada PageView sesuai tab yang dipilih
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchBahanBaku();
  }

  Future<void> fetchBahanBaku() async {
    final result = await services.fetchBahanBaku();

    if (!mounted) return;
    setState(() {
      daftar_bahan_baku = result;
      _filteredProduct = daftar_bahan_baku;

      isLoading = false;
    });
  }

  void _applyFilterAndSort() {
    // Apply search filter
    List<BahanBaku> filteredList = daftar_bahan_baku;

    if (_filterQuery.isNotEmpty) {
      filteredList = filteredList.where((product) {
        print(product.namaBahanBaku);
        print(_filterQuery);
        // Filter by total
        if (product.namaBahanBaku
            .toLowerCase()
            .contains(_filterQuery.toLowerCase())) {
          return true;
        }
        // Filter by total
        if (product.kodeBahanBaku == _filterQuery) {
          return true;
        }

        return false;
      }).toList();
    }

    setState(() {
      _filteredProduct = filteredList;
    });

    print("hello : ${_filteredProduct[0].namaBahanBaku}");
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filterQuery = query;
      _applyFilterAndSort();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshControllerKelolaBahanBaku.dispose();
    _refreshControllerOutletBahanBaku.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                        hintText: 'Cari Bahan Baku',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintStyle: GoogleFonts.ptSans(
                          fontWeight: FontWeight.w200,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0.2,
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTopTabTapped(0),
                  child: Container(
                    padding: EdgeInsets.only(top: 6, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabTop == 0
                              ? Colors.brown
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kelola Bahan Baku',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedTabTop == 0
                                ? Colors.brown
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTabTop = index;
                });
              },
              children: [
                // Halaman 1: Kelola Produk (halaman yang sudah ada)
                // _buildKelolaBahanBakuPage(),

                // Halaman 2: Produk di Gudang (kosong untuk sementara)
                _buildBahanBakuGudangPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTabTop == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BahanBakuForm(),
                      ),
                    );

                    if (result) {
                      await fetchBahanBaku();
                    }
                  },
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildKelolaBahanBakuPage() {
    return SmartRefresher(
      controller: _refreshControllerKelolaBahanBaku,
      onRefresh: () async {
        await fetchBahanBaku();
        _refreshControllerKelolaBahanBaku.refreshCompleted();
      },
      header: WaterDropHeader(
        complete: Text("Sudah up to date!"),
        waterDropColor: Colors.brown,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // List produk dengan padding
            isLoading
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5, // Jumlah dummy shimmer
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildShimmerCard(),
                          SizedBox(height: 16),
                        ],
                      );
                    },
                  )
                : _filteredProduct.isEmpty
                    ? buildBahanBakuCardEmpty()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredProduct.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              buildBahanBakuOutletCard(
                                context,
                                _filteredProduct[index],
                                outlet,
                                index,
                                inventoryMethod,
                                () async {
                                  await fetchBahanBaku();
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildBahanBakuGudangPage() {
    return SmartRefresher(
      controller: _refreshControllerOutletBahanBaku,
      onRefresh: () async {
        await fetchBahanBaku();
        _refreshControllerOutletBahanBaku.refreshCompleted();
      },
      header: WaterDropHeader(
        complete: Text("Sudah up to date!"),
        waterDropColor: Colors.brown,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            // List produk dengan padding
            isLoading
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5, // Jumlah dummy shimmer
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildShimmerCard(),
                          SizedBox(height: 16),
                        ],
                      );
                    },
                  )
                : _filteredProduct.isEmpty
                    ? buildBahanBakuCardEmpty()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredProduct.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              buildBahanBakuOutletCard(
                                context,
                                _filteredProduct[index],
                                outlet,
                                index,
                                inventoryMethod,
                                () async {
                                  await fetchBahanBaku();
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
