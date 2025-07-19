import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/pages/produk/tambah_produk.dart';
import 'package:caffe_pandawa/services/product_services.dart';
import 'package:caffe_pandawa/widgets/produk/produk_widget.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final ProductServices services = ProductServices();

  RefreshController _refreshController = RefreshController();
  TextEditingController searchController = TextEditingController();

  late List<Product> products = [];
  late List<Product> _filteredProduct;

  bool isLoading = true;
  String _filterQuery = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final result = await services.fetchProducts("for-list");

    setState(() {
      products = result;
      _filteredProduct = products;
      isLoading = false;
    });
  }

  void _applyFilterAndSort() {
    // Apply search filter
    List<Product> filteredList = products;

    if (_filterQuery.isNotEmpty) {
      filteredList = filteredList.where((product) {
        print(product.namaProduct);
        print(_filterQuery);
        // Filter by total
        if (product.namaProduct
            .toLowerCase()
            .contains(_filterQuery.toLowerCase())) {
          return true;
        }
        // Filter by total
        if (product.kodeProduct == _filterQuery) {
          return true;
        }

        return false;
      }).toList();
    }

    setState(() {
      _filteredProduct = filteredList;
    });

    print("hello : ${_filteredProduct[0].namaProduct}");
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filterQuery = query;
      _applyFilterAndSort();
    });
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
                        hintText: 'Cari Produk',
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
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                await fetchProducts();
                _refreshController.refreshCompleted();
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
                        : _filteredProduct.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredProduct.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      buildProductCard(
                                        context,
                                        _filteredProduct[index],
                                        index,
                                        () async {
                                          await fetchProducts();
                                        },
                                        (int index, bool value) async {
                                          setState(() {
                                            _filteredProduct[index].status =
                                                value;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'Belum ada produk',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TambahProduk(),
                ),
              );

              if (result) {
                await fetchProducts();
              }
            },
            backgroundColor: Colors.brown[700],
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
