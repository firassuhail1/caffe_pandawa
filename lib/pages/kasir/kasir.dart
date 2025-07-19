import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/services/cashier_session_services.dart';
import 'package:caffe_pandawa/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:caffe_pandawa/models/CartItems.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/services/product_services.dart';
import 'package:caffe_pandawa/pages/kasir/keranjang_pesanan.dart';

class Kasir extends StatefulWidget {
  const Kasir({super.key});

  @override
  State<Kasir> createState() => _KasirState();
}

class _KasirState extends State<Kasir> {
  final ProductServices productServices = ProductServices();
  final CashierSessionServices cashierSessionServices =
      CashierSessionServices();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  late List<Product> products = [];
  late List<Product> _filteredProduct;

  bool isDering = true;
  bool isLoading = true;
  bool isPlusMinusInvisible = true;
  bool isShiftOn = false;
  Map<String, dynamic>? cashierSession = {};

  TextEditingController _searchController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();
  TextEditingController _openingCashController = TextEditingController();

  bool _showClearButton = false;
  String _filterQuery = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });

    fetchProducts();

    // Memanggil dialog saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cashierSession = await cashierSessionServices.getCashierSession();

      // Cek apakah sesi kasir ada dan statusnya 'open'
      if (cashierSession != null && cashierSession?['status'] == 'open') {
        setState(() {
          isShiftOn = true; // Set isShiftOn menjadi true jika ada sesi open
        });
        print('Shift is already open.');
      } else {
        // Jika tidak ada sesi atau statusnya bukan 'open', tampilkan dialog buka kasir
        setState(() {
          isShiftOn = false; // Set isShiftOn menjadi false
        });
        print(
            'No active shift found or shift is closed/abandoned. Showing opening dialog.');
        _showStartCashierDialog(context);
      }
    });
  }

  void fetchProducts() async {
    final result = await productServices.fetchProducts("for-kasir");

    setState(() {
      products = result;
      _filteredProduct = products;
      isLoading = false;
    });
  }

  Future<void> attemptStartCashier(String? startingCashAmount) async {
    if (startingCashAmount == null ||
        startingCashAmount == "" ||
        startingCashAmount == "0") {
      if (mounted)
        await Flushbar(
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.red.shade600,
          icon: Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 2),
          messageText: Text(
            'Uang buka kasir harus diisi',
            style: const TextStyle(color: Colors.white),
          ),
        ).show(context);

      return;
    }

    final result =
        await cashierSessionServices.startCashier(startingCashAmount);

    if (result['success']) {
      setState(() {
        isShiftOn = true;
        cashierSession = result['data'];
      });

      Navigator.of(context).pop(); // Tutup dialog
    } else {
      await flushbarMessage(
          context, result['message'], Colors.red.shade600, Icons.error);
    }
  }

  Future<void> attemptEndingCashier(String? endingCashAmount) async {
    // Ubah nama parameter agar lebih jelas
    if (endingCashAmount == null || endingCashAmount.isEmpty) {
      // Gunakan .isEmpty juga
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white), // Tambahkan const
        duration: const Duration(seconds: 2),
        messageText: const Text(
          // Tambahkan const
          'Uang tutup kasir harus diisi',
          style: TextStyle(color: Colors.white),
        ),
      ).show(context);
      return;
    }

    // Panggil service untuk mengakhiri sesi kasir
    // Kita perlu mendapatkan ID sesi kasir yang aktif dari local storage
    final currentSession = await cashierSessionServices.getCashierSession();

    if (currentSession == null || currentSession['id'] == null) {
      // Ini seharusnya tidak terjadi jika alur buka kasir sudah benar
      // Tapi penting untuk penanganan error
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
        messageText: const Text(
          'Tidak ada sesi kasir aktif. Silakan buka kasir terlebih dahulu.',
          style: TextStyle(color: Colors.white),
        ),
      ).show(context);
      return;
    }

    // Panggil service dengan ID sesi kasir dan ending_physical_cash_amount
    final result = await cashierSessionServices.endCashier(
        currentSession['id'], endingCashAmount);

    if (result['success']) {
      setState(() {
        isShiftOn = false; // Set status shift menjadi non-aktif di UI
        cashierSession = null;
      });
      // Hapus sesi kasir dari SecureStorage
      await cashierSessionServices.deleteCashierSession();
      // Tampilkan pesan sukses
      await Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        messageText: Text(
          result['message'] ?? 'Berhasil melakukan tutup kasir.',
          style: const TextStyle(color: Colors.white),
        ),
      ).show(context);
      // Mungkin juga menampilkan selisih kas jika dikembalikan oleh backend
      if (result['cash_difference'] != null) {
        // Tampilkan dialog terpisah atau notifikasi tentang selisih kas
        print('Selisih Kas: ${result['cash_difference']}');
      }
      Navigator.pop(context, true);
    } else {
      // Tampilkan pesan error dari backend
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
        messageText: Text(
          result['message'] ?? 'Gagal melakukan tutup kasir.',
          style: const TextStyle(color: Colors.white),
        ),
      ).show(context);
    }
  }

  Future<void> attemptCashInOut(
      String? cashIn, String? description, String type) async {
    // Ubah nama parameter agar lebih jelas
    if (cashIn == null || cashIn.isEmpty) {
      // Gunakan .isEmpty juga
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white), // Tambahkan const
        duration: const Duration(seconds: 2),
        messageText: const Text(
          // Tambahkan const
          'Uang tutup kasir harus diisi',
          style: TextStyle(color: Colors.white),
        ),
      ).show(context);
      return;
    } else if (description == null) {
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white), // Tambahkan const
        duration: const Duration(seconds: 2),
        messageText: const Text(
          // Tambahkan const
          'Uang tutup kasir harus diisi',
          style: TextStyle(color: Colors.white),
        ),
      ).show(context);
      return;
    }

    final currentSession = await cashierSessionServices.getCashierSession();

    if (currentSession == null || currentSession['id'] == null) {
      // Ini seharusnya tidak terjadi jika alur buka kasir sudah benar
      // Tapi penting untuk penanganan error
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
        messageText: const Text(
          'Tidak ada sesi kasir aktif. Silakan buka kasir terlebih dahulu.',
          style: TextStyle(color: Colors.white),
        ),
      ).show(context);
      return;
    }

    final result =
        await cashierSessionServices.cashIn(cashIn, description, type);

    if (result["success"]) {
      await Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 2),
        messageText: Text(
          'Berhasil ${type == 'in' ? 'memasukkan' : 'mengeluarkan'} uang.',
          style: TextStyle(color: Colors.white),
        ),
      ).show(context);
      Navigator.pop(context);
    }
  }

  List<CartItems>? cartItems = [];

  void addToCart(Product product) {
    if (cashierSession == null || cashierSession?["status"] != "open") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kasir belum dibuka'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int index = cartItems!.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Jika produk sudah ada di keranjang, tambah qty
      setState(() {
        cartItems?[index].quantity++;
        cartItems?[index].totalHarga = cartItems?[index].totalPrice;
      });
    } else {
      // Jika produk belum ada di keranjang, tambahkan baru
      setState(() {
        cartItems?.add(CartItems(
            product: product,
            quantity: 1,
            totalHarga: 1 * product.harga,
            isPlusMinusInvisible: true));
      });
    }

    print(cartItems);
  }

  void removeFromCart(Product product) {
    setState(() {
      cartItems?.remove(product);
    });
  }

  void clearCart() {
    setState(() {
      cartItems?.clear();
    });
  }

  double getTotalHarga() {
    return cartItems!
        .fold(0, (total, item) => total + (item.product.harga * item.quantity));
  }

  void _applyFilterAndSort() {
    // Apply search filter
    List<Product> filteredList = products;

    if (_filterQuery.isNotEmpty) {
      filteredList = filteredList.where((product) {
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
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filterQuery = query;
      _applyFilterAndSort();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text(
              'Caffe Pandawa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      drawer: DrawerWidget(
        isShiftOn: isShiftOn,
        attemptEndingCashier: (value) => attemptEndingCashier(value),
        attemptCashIn: (cashAmount, description) =>
            attemptCashInOut(cashAmount, description, 'in'),
        attemptCashOut: (cashAmount, description) =>
            attemptCashInOut(cashAmount, description, 'out'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 6),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        hintText: 'Cari Produk',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintStyle: TextStyle(fontWeight: FontWeight.w200),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 0.2, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.brown),
                        ),
                        suffixIcon: _showClearButton
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.black54,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  // List produk dengan padding
                  isLoading
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 9, // tampilkan 9 shimmer
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.47,
                          ),
                          itemBuilder: (context, index) => _buildShimmerCard(),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProduct.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 kolom
                            crossAxisSpacing: 10, // Jarak antar kolom
                            mainAxisSpacing: 10, // Jarak antar baris
                            childAspectRatio:
                                0.47, // Rasio ukuran card (atur sesuai kebutuhan)
                          ),
                          itemBuilder: (context, index) {
                            return _buildProductCard(
                                _filteredProduct[index], index);
                          },
                        ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            // Mencegah overflow teks
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              // Memperkecil teks otomatis jika terlalu panjang
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Rp${NumberFormat("#,###", "id_ID").format(getTotalHarga()).replaceAll(",", ".")}', // Format lebih rapi
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow
                                    .ellipsis, // Tambahkan elipsis jika terlalu panjang
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Row(
                      children: [
                        PhysicalModel(
                          color: Colors.red[600]!, // Warna utama
                          elevation: 4, // Besar bayangan
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: clearCart,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 7),
                              child: Icon(
                                Icons.delete_outline,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => KeranjangPesanan(
                                  cartItems: cartItems,
                                ),
                              ),
                            );

                            if (result) {
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            "Lihat Keranjang",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    // Cek apakah produk ada di cartItems
    var cartItem = cartItems?.firstWhereOrNull(
      (element) => element.product.id == product.id,
    );

    return GestureDetector(
      onTap: () => addToCart(product),
      child: Container(
        decoration: _boxDecoration(),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: CachedNetworkImage(
                        imageUrl: product.image ?? "",
                        placeholder: (context, url) => Container(
                          width: 160,
                          height: 160,
                          child: const Center(
                              child: CircularProgressIndicator(
                            color: Colors.brown,
                          )),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.black54, width: 0.2)),
                          ),
                          child: const Icon(Icons.broken_image,
                              size: 16, color: Colors.brown),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.namaProduct,
                        style: GoogleFonts.ptSans(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rp${NumberFormat("#,###", "id_ID").format(product.harga).replaceAll(",", ".")}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Stock : ${product.stock.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            // Tampilkan badge jumlah item hanya jika produk ada di cartItems
            if (cartItem != null && cartItem.quantity > 0)
              // Posisikan container di dalam area gambar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100, // Sama dengan tinggi container gambar
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.6), // Background semi-transparan
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Baris untuk tombol plus/minus
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!cartItem.isPlusMinusInvisible)
                                // Tombol minus
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (cartItem.quantity > 0) {
                                        cartItem.quantity--;
                                        cartItem.totalHarga =
                                            (cartItem.totalHarga ?? 0) -
                                                product.harga;

                                        if (cartItem.quantity < 1) {
                                          cartItems?.remove(cartItem);
                                        }
                                      }
                                    });

                                    print(cartItems);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              // Tampilan quantity
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    cartItem.isPlusMinusInvisible =
                                        !cartItem.isPlusMinusInvisible;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    // shape: BoxShape.circle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    cartItem.quantity.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (!cartItem.isPlusMinusInvisible)
                                // Tombol plus
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cartItem.quantity++;
                                      cartItem.totalHarga =
                                          (cartItem.totalHarga ?? 0) +
                                              product.harga;
                                    });

                                    print(cartItems);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 8),
                          // Tombol edit (jika visible)
                          if (!cartItem.isPlusMinusInvisible)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showFormDialogQty(
                                      cartItem: cartItem, product: product);
                                  cartItem.isPlusMinusInvisible = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.brown[600],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: 80,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showFormDialogQty({CartItems? cartItem, required Product product}) {
    final _focusNode = FocusNode();
    _qtyController.text = cartItem!.quantity.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        // Fokuskan setelah frame selesai dibangun
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_focusNode.hasFocus) {
            FocusScope.of(context).requestFocus(_focusNode);
          }
        });
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Jumlah Produk',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Min Price Field
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Jml Produk',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context, _qtyController.text);
              },
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      }),
    ).then((value) {
      // Ini dijalankan setelah dialog ditutup
      if (value != null || value != -1) {
        setState(() {
          cartItem.quantity = double.parse(_qtyController.text);
          cartItem.totalHarga = cartItem.totalPrice;
        });
      }
    });
  }

  void _showStartCashierDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan tap di luar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Mulai Shift'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Masukkan uang buka kasir Anda:'),
                const SizedBox(height: 10),
                TextField(
                  controller: _openingCashController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                      trailingSymbol: '',
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Uang Buka Kasir',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ', // Menambahkan prefix "Rp"
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Mulai'),
              onPressed: () async {
                // Lakukan sesuatu dengan nilai uang buka kasir
                // Contoh: Simpan ke database, tampilkan di UI, dll.
                print('Uang buka kasir: Rp ${_openingCashController.text}');

                String amount = "";
                amount = _openingCashController.text.replaceAll('.', '');

                // if (amount == "") return;

                print(amount);
                await attemptStartCashier(amount);
              },
            ),
          ],
        );
      },
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }
}
