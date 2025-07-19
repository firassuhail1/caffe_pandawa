import 'package:flutter/material.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/services/product_services.dart';
import 'package:caffe_pandawa/widgets/produk/detail_produk_widget.dart';

class DetailProduk extends StatefulWidget {
  final Product product;

  const DetailProduk({super.key, required this.product});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  final ProductServices services = ProductServices();

  late Product data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.product;
  }

  void getProduct(int identifier) async {
    final result = await services.getProduct(identifier.toString());
    print("result : $result");
    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    double untung = data.harga - (data.hargaAsliProduct ?? 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.share, color: Colors.white),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.favorite_border, color: Colors.white),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: PopScope(
        canPop: false, // jangan di pop dulu
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // kita intercept dan kirim result secara manual
            Navigator.pop(context, true);
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Status Badge
              imageHeader(data),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      data.namaProduct,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Product Code
                    if (data.kodeProduct != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              'Kode: ',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              data.kodeProduct!,
                              style: TextStyle(
                                color: Colors.brown[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Price Section
                    priceSection(data, untung),
                    SizedBox(height: 20),
                    // Stock and Bundling Info
                    stockAndBundlingInfo(data),
                    SizedBox(height: 24),
                    // Description
                    descriptionProduct(data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: bottomMenu(context, data, () {
            setState(() {
              getProduct(data.id);
            });
          })),
    );
  }
}
