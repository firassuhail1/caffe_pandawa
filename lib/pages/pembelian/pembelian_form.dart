import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/services/pembelian_services.dart';

class PembelianForm extends StatefulWidget {
  const PembelianForm({super.key});

  @override
  State<PembelianForm> createState() => _PembelianFormState();
}

class _PembelianFormState extends State<PembelianForm> {
  // Data lists
  List<Map<String, dynamic>>? dataProduct;

  // Suggestions
  List<Map<String, dynamic>> _suggestionsData = [];

  // Controllers
  Timer? _debounce;
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController outletController = TextEditingController();
  final TextEditingController invoiceNumber = TextEditingController();

  // Selected values
  DateTime? date;

  // Add item controllers
  List<Map<String, dynamic>> productCartItems = [];
  List<TextEditingController> id = [];
  List<TextEditingController> product = [];
  List<TextEditingController> quantity = [];
  List<TextEditingController> costPrice = [];
  List<TextEditingController> qtyPerBundling = [];
  List<TextEditingController> tipe = [];
  List<TextEditingController> unitOfMeasure = [];
  List<TextEditingController> subtotal = [];
  List<TextEditingController> isPerUnit = [];
  List<TextEditingController> isBundling = [];

  // State variables
  bool isLoadingProduct = false;
  int? whereItem;
  bool _isAddItemOn = false;

  // Theme colors
  static const Color primaryColor = Colors.brown;
  static const Color primaryLight = Color(0xFFE0F7FA);
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    supplierController.dispose();
    outletController.dispose();
    invoiceNumber.dispose();
    _disposeItemControllers();
    super.dispose();
  }

  void _disposeItemControllers() {
    for (var controller in id) {
      controller.dispose();
    }
    for (var controller in product) {
      controller.dispose();
    }
    for (var controller in tipe) {
      controller.dispose();
    }
    for (var controller in unitOfMeasure) {
      controller.dispose();
    }
    for (var controller in quantity) {
      controller.dispose();
    }
    for (var controller in costPrice) {
      controller.dispose();
    }
    for (var controller in qtyPerBundling) {
      controller.dispose();
    }
    for (var controller in subtotal) {
      controller.dispose();
    }
    for (var controller in isPerUnit) {
      controller.dispose();
    }
    for (var controller in isBundling) {
      controller.dispose();
    }

    id.clear();
    product.clear();
    tipe.clear();
    unitOfMeasure.clear();
    quantity.clear();
    costPrice.clear();
    qtyPerBundling.clear();
    subtotal.clear();
    isPerUnit.clear();
    isBundling.clear();
  }

  // Initialize all data
  void _initializeData() {
    loadProducts();
  }

  void loadProducts() async {
    try {
      final result = await PembelianServices().fetchProductForPembelian();
      if (mounted) {
        setState(() {
          dataProduct = result;
          isLoadingProduct = false;
        });
      }
      print('data product : $dataProduct');
    } catch (e) {
      print('Error load products: $e');
      if (mounted) {
        setState(() {
          isLoadingProduct = false;
        });
      }
    }
  }

  void _save() async {
    // Purchase.dart
    double totalAmount = productCartItems.fold(
        0.0, (sum, item) => sum + (item['subtotal'] ?? 0.0));

    print(date);
    print(invoiceNumber.text);

    for (var i = 0; i < productCartItems.length; i++) {
      // Pucrhcase Detail.dart
      print(productCartItems[i]['id']);
      print(productCartItems[i]['nama']);
      print(productCartItems[i]['tipe']);
      print(productCartItems[i]['cost_price']);
      print(productCartItems[i]['quantity']);
      print(productCartItems[i]['unit_cost']);
      print(productCartItems[i]['subtotal']);
    }

    if (date == null) {
      flushbarMessage(context, "Tanggal Pembelian harus diisi",
          Colors.red.shade600, Icons.warning);
      return;
    }

    if (productCartItems.isEmpty) {
      flushbarMessage(context, "Belum ada product yg di masukkan",
          Colors.yellow.shade600, Icons.warning);
      return;
    }

    final result = await PembelianServices().saveProduct(
      date!,
      invoiceNumber.text,
      totalAmount,
      productCartItems,
    );

    if (result) {
      await flushbarMessage(context, "Berhasil melakukan pembelian",
          Colors.green.shade600, Icons.check_circle);

      Navigator.pop(context);
    } else {
      flushbarMessage(context, "Gagal melakukan pembelian", Colors.red.shade600,
          Icons.error);
    }
  }

  void addNewItem() {
    setState(() {
      id.add(TextEditingController());
      product.add(TextEditingController());
      tipe.add(TextEditingController());
      unitOfMeasure.add(TextEditingController());
      quantity.add(TextEditingController());
      costPrice.add(TextEditingController());
      qtyPerBundling.add(TextEditingController());
      subtotal.add(TextEditingController(text: '0'));
      isPerUnit.add(TextEditingController(text: 'true'));
      isBundling.add(TextEditingController(text: 'false'));
    });
  }

  void _removeItem(int index) {
    setState(() {
      productCartItems.removeAt(index);
    });
  }

  void _removeAddItem(int index) {
    setState(() {
      id[index].dispose();
      product[index].dispose();
      tipe[index].dispose();
      unitOfMeasure[index].dispose();
      quantity[index].dispose();
      costPrice[index].dispose();
      qtyPerBundling[index].dispose();
      subtotal[index].dispose();
      isPerUnit[index].dispose();
      isBundling[index].dispose();

      id.removeAt(index);
      product.removeAt(index);
      tipe.removeAt(index);
      unitOfMeasure.removeAt(index);
      quantity.removeAt(index);
      costPrice.removeAt(index);
      qtyPerBundling.removeAt(index);
      subtotal.removeAt(index);
      isPerUnit.removeAt(index);
      isBundling.removeAt(index);

      if (product.isEmpty) {
        _isAddItemOn = false;
      }
    });
  }

  void _onProductSearched(String query, int index) {
    if (query.isEmpty) {
      setState(() {
        _suggestionsData = [];
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      isLoadingProduct = true;
      whereItem = index;
    });

    // final filteredSuggestions = dataProduct?.where((product) {
    //   final name = product['nama'].toLowerCase();
    //   return name.contains(query.toLowerCase());
    // }).toList();

    final filteredSuggestions = dataProduct?.where((product) {
      final name = (product['nama'] ?? '').toLowerCase();
      // final dataOutlet = product['inventories'].firstWhere(
      //   (item) => item['outlet_id'] == selectedOutlet,
      // );

      // return name.contains(query.toLowerCase()) && dataOutlet != null;
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _suggestionsData = filteredSuggestions ?? [];
      isLoadingProduct = false;
    });

    print("Filtered Product Suggestions: $_suggestionsData");

    if (dataProduct == null) {
      loadProducts();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        date = picked;
      });
    }
  }

  void _saveItems() {
    setState(() {
      // productCartItems ??= [];

      for (var i = 0; i < product.length; i++) {
        // Logic for saving items would go here
        // Currently commented out as per original code

        final unitCost = double.parse(subtotal[i].text);
        final harga = double.parse(costPrice[i].text.replaceAll('.', ''));
        final qty = double.parse(quantity[i].text.replaceAll('.', ''));

        final qty_per_bundling = double.tryParse(
                qtyPerBundling[i].text.replaceAll('.', '')) ??
            1; // beri nilai default 1 jika product tidak menggunakan mode bundling (biar tidak kosong dan null yang menyebabkan eror, jadi di beri nilai 1 karna nilai apapun di kali 1 akan tetap 1)

        double sub_total = 0;
        double qtyFinal = qty;

        if (isBundling[i].text == 'true') {
          print('else');
          // jika bundling aktif = subtotal nya sama dengan harga yg diinputkan itu sendiri
          sub_total = harga;
          qtyFinal = qty_per_bundling * qty;
        } else if (isPerUnit[i].text == "true") {
          print('else');
          // jika unit aktif = harga yang diinput kan itu sama dengan per pcs nya, jadi harus di kali dengan quantity
          // tetapi jika bundling aktif, otomatis case ini akan terlewati, karna sejatinya jika bundling aktif, is per unit dianggap dan harus false
          sub_total = harga * qtyFinal;
        } else {
          print('else');
          sub_total = harga;
        }

        Map<String, dynamic> productCart = {
          'id': id[i].text,
          'nama': product[i].text,
          'tipe': tipe[i].text,
          'cost_price': harga,
          'quantity': qtyFinal,
          'unit_cost': unitCost,
          'subtotal': sub_total,
        };

        // masukkan ke productCartItems
        productCartItems.add(productCart);

        print("paowjefpaoweifj : $productCartItems");
      }
    });

    _disposeItemControllers();
    _isAddItemOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Buat Pembelian',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _save();
          },
          icon: Icon(Icons.save),
          color: Colors.white,
        ),
        const SizedBox(width: 16),
      ],
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInvoiceSection(),
          const SizedBox(height: 20),
          _buildDateSection(),
          const SizedBox(height: 24),
          _buildItemsSection(),
          const SizedBox(height: 20),
          _buildAddItemButton(),
          if (_isAddItemOn) ...[
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryLight, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Pembelian Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lengkapi informasi pembelian dengan benar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return _buildSection(
      title: 'Nomor Transaksi',
      child: _buildTextField(
        controller: invoiceNumber,
        label: 'Masukkan nomor transaksi',
        icon: Icons.receipt_long,
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildSection(
      title: 'Tanggal Pembelian',
      child: _buildDateSelector(
        label: 'Pilih Tanggal',
        date: date,
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildItemsSection() {
    return _buildSection(
      title: 'Item Pembelian',
      child: Column(
        children: [
          // _buildItemsList(),
          _isAddItemOn ? _buildAddItemsList() : _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildTextFieldWithSearch({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return _buildTextField(
      controller: controller,
      label: label,
      icon: icon,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 12),
            Text(hint),
          ],
        ),
        items: items,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null ? '${date.day}/${date.month}/${date.year}' : label,
                style: TextStyle(
                  fontSize: 16,
                  color: date != null ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSuggestions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: isLoadingProduct ? 1 : _suggestionsData.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          if (isLoadingProduct) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text("Mencari produk..."),
                ],
              ),
            );
          }
          final product_item = _suggestionsData[index];
          return ListTile(
            leading:
                const Icon(Icons.inventory_2, color: primaryColor, size: 20),
            title: Text(
              product_item['nama'].toString().capitalize(),
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              setState(() {
                id[whereItem!].text = product_item['id'].toString();
                product[whereItem!].text = product_item['nama'];
                tipe[whereItem!].text = product_item['tipe'];
                unitOfMeasure[whereItem!].text =
                    product_item['unit_of_measure'];

                _suggestionsData = [];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildItemsList() {
    if (productCartItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Belum ada item yang ditambahkan',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productCartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildItemCard(index),
    );
  }

  Widget _buildItemCard(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: primaryColor, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productCartItems[index]['nama'].toString().capitalize(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Subtotal : Rp${formatter(productCartItems[index]['subtotal'])}',
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: product.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildAddItemCard(index),
    );
  }

  Widget _buildAddItemCard(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Item ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeAddItem(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: product[index],
            onChanged: (value) => _onProductSearched(value, index),
            decoration: InputDecoration(
              hintText: "Nama Bahan Baku",
              prefixIcon: const Icon(Icons.search, color: primaryColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          if (_suggestionsData.isNotEmpty && whereItem == index)
            _buildProductSuggestions(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: costPrice[index],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      costPrice[index].text = value;

                      double cost_price = double.tryParse(
                              costPrice[index].text.replaceAll('.', '')) ??
                          0;
                      double kuantitas = double.tryParse(
                              quantity[index].text.replaceAll('.', '')) ??
                          0;

                      double kuantitasPerBundling = double.tryParse(
                              qtyPerBundling[index].text.replaceAll('.', '')) ??
                          0;

                      double hitung = cost_price;

                      if (isBundling[index].text == 'true') {
                        hitung =
                            cost_price / (kuantitas * kuantitasPerBundling);
                      } else {
                        if (isPerUnit[index].text == 'false') {
                          hitung = cost_price / kuantitas;
                        }
                      }

                      subtotal[index].text = hitung.toString();
                    });
                  },
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                      trailingSymbol: '',
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: "Harga",
                    prefixIcon:
                        const Icon(Icons.attach_money, color: primaryColor),
                    enabledBorder: OutlineInputBorder(
                      // <== Tambahkan ini
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: quantity[index],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      quantity[index].text = value;
                      double cost_price = double.tryParse(
                              costPrice[index].text.replaceAll('.', '')) ??
                          0;
                      double kuantitas = double.tryParse(
                              quantity[index].text.replaceAll('.', '')) ??
                          0;

                      double kuantitasPerBundling = double.tryParse(
                              qtyPerBundling[index].text.replaceAll('.', '')) ??
                          0;

                      double hitung = cost_price;

                      if (isBundling[index].text == 'true') {
                        hitung =
                            cost_price / (kuantitas * kuantitasPerBundling);
                      } else {
                        if (isPerUnit[index].text == 'false') {
                          hitung = cost_price / kuantitas;
                        }
                      }

                      subtotal[index].text = hitung.toString();
                    });
                  },
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                      trailingSymbol: '',
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: unitOfMeasure[index].text,
                    enabledBorder: OutlineInputBorder(
                      // <== Tambahkan ini
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          // prentelan kebutuhan
          Padding(
            padding:
                const EdgeInsets.only(top: 16, bottom: 6, left: 4, right: 4),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: qtyPerBundling[index],
                        keyboardType: TextInputType.number,
                        readOnly:
                            isBundling[index].text == "true" ? false : true,
                        onChanged: (value) {
                          setState(() {
                            qtyPerBundling[index].text = value;

                            if (isBundling[index].text == 'true') {
                              double cost_price = double.tryParse(
                                      costPrice[index]
                                          .text
                                          .replaceAll('.', '')) ??
                                  0;
                              double kuantitas = double.tryParse(quantity[index]
                                      .text
                                      .replaceAll('.', '')) ??
                                  0;

                              double kuantitasPerBundling = double.tryParse(
                                      qtyPerBundling[index]
                                          .text
                                          .replaceAll('.', '')) ??
                                  0;

                              double hitung = cost_price;

                              hitung = cost_price /
                                  (kuantitas * kuantitasPerBundling);

                              subtotal[index].text = hitung.toString();
                            }
                          });
                        },
                        inputFormatters: [
                          CurrencyInputFormatter(
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                            trailingSymbol: '',
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: "Isi / Bundling",
                          enabledBorder: OutlineInputBorder(
                            // <== Tambahkan ini
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: isBundling[index].text == "true"
                                ? BorderSide(color: primaryColor)
                                : BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          fillColor: isBundling[index].text == "true"
                              ? Colors.grey.shade50
                              : Colors.grey.shade300,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isBundling[index].text == "true") {
                                  isBundling[index].text = "false";
                                } else {
                                  isBundling[index].text = "true";
                                }

                                double cost_price = double.tryParse(
                                        costPrice[index]
                                            .text
                                            .replaceAll('.', '')) ??
                                    0;
                                double kuantitas = double.tryParse(
                                        quantity[index]
                                            .text
                                            .replaceAll('.', '')) ??
                                    0;

                                double kuantitasPerBundling = double.tryParse(
                                        qtyPerBundling[index]
                                            .text
                                            .replaceAll('.', '')) ??
                                    0;

                                double hitung = cost_price;

                                if (isBundling[index].text == 'false') {
                                  if (isPerUnit[index].text == 'false') {
                                    hitung = cost_price / kuantitas;
                                  } else {
                                    hitung = cost_price;
                                  }
                                } else {
                                  hitung = cost_price /
                                      (kuantitas * kuantitasPerBundling);
                                }

                                subtotal[index].text = hitung.toString();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isBundling[index].text == "true"
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank_outlined,
                                  color: Colors.cyan,
                                  size: 16,
                                ),
                                Text(
                                  'Bundling',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyan[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              showTooltipDialog(context,
                                  "Gunakan centang Bundling jika produk yang dimasukkan memiliki beberapa item per bundlingnya, yang mana merupakan satuan barangnya.\n \nContoh anda membeli baju dengan quantity 2 (bundling) dengan harga total Rp1.000.000, dan isi per bundling nya 5,\n \nMaka harga per satuannya = \nharga / (jumlah isi per bundling x quantity barang)\n \nHarga Harga per satuannya = \n1.000.000 / (5 * 2) = 100.000\n \nJika tidak dicentang, sistem akan menganggap quantity yang dimasukkan adalah quantity satuan per barangnya.");
                            },
                            child: Icon(
                              Icons.info,
                              size: 19,
                              color: Colors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Per ${unitOfMeasure[index].text}: Rp${formatter(double.parse(subtotal[index].text))}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isBundling[index].text == 'true') return;

                              if (isPerUnit[index].text == "true") {
                                isPerUnit[index].text = "false";
                              } else {
                                isPerUnit[index].text = "true";
                              }

                              double cost_price = double.tryParse(
                                      costPrice[index]
                                          .text
                                          .replaceAll('.', '')) ??
                                  0;
                              double kuantitas = double.tryParse(quantity[index]
                                      .text
                                      .replaceAll('.', '')) ??
                                  0;

                              double hitung = cost_price;

                              if (isPerUnit[index].text == 'false') {
                                hitung = cost_price / kuantitas;
                              }

                              subtotal[index].text = hitung.toString();
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isPerUnit[index].text == "true"
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank_outlined,
                                color: Colors.cyan,
                                size: 16,
                              ),
                              Text(
                                'Unit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            showTooltipDialog(context,
                                "Gunakan centang Unit jika harga yang dimasukkan sudah per satuan barang.\n \nJika tidak dicentang, sistem akan menganggap harga yang dimasukkan adalah total dari semua barang dan akan membaginya sesuai quantity agar menjadi harga per satuan nya.");
                          },
                          child: Icon(
                            Icons.info,
                            size: 19,
                            color: Colors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isAddItemOn = true;
            });
            addNewItem();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.add, color: primaryColor),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Tambah Item Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveItems,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 20),
            SizedBox(width: 8),
            Text(
              "Simpan Item",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showTooltipDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // Tutup saat klik luar
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          backgroundColor: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
