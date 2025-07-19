import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/services/product_services.dart';
import 'package:caffe_pandawa/widgets/produk/edit_produk_widget.dart';

class EditProduk extends StatefulWidget {
  final Product product;

  const EditProduk({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProduk> createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  final ProductServices services = ProductServices();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _kodeProduk;
  late final TextEditingController _namaProduk;
  late final TextEditingController _hargaProduk;
  late final TextEditingController _hpp;
  late final TextEditingController _stokProduk;
  late final TextEditingController _hargaJualProductBundling;
  late final TextEditingController _jmlProdukPerBundling;
  late bool _status;
  File? _image;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _kodeProduk = TextEditingController(text: p.kodeProduct);
    _namaProduk = TextEditingController(text: p.namaProduct);
    _hargaProduk = TextEditingController(text: formatter(p.harga));
    _stokProduk = TextEditingController(text: formatter(p.stock));
    _hpp = TextEditingController(text: formatter(p.hargaAsliProduct ?? 0));
    _hargaJualProductBundling =
        TextEditingController(text: formatter(p.hargaJualProductBundling ?? 0));
    _jmlProdukPerBundling =
        TextEditingController(text: formatter(p.jmlProductPerBundling ?? 0));
    _status = p.status ?? true;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await services.editProduct(
        id: widget.product.id,
        namaProduk: _namaProduk.text,
        kodeProduk: _kodeProduk.text,
        hargaProduk: _hargaProduk.text,
        stock: _stokProduk.text,
        hpp: _hpp.text,
        hargaProdukBundling: _hargaJualProductBundling.text,
        jmlProdukPerBundling: _jmlProdukPerBundling.text,
        status: _status,
        image: _image,
      );

      Navigator.pop(context);
      final isSuccess = result;
      final message = isSuccess
          ? 'Produk berhasil di perbarui'
          : 'Gagal memperbarui produk';

      await Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor:
            isSuccess ? Colors.green.shade600 : Colors.red.shade400,
        icon: Icon(
          isSuccess ? Icons.check_circle : Icons.error_outline,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 2),
        messageText: Text(message, style: const TextStyle(color: Colors.white)),
      ).show(context);

      if (isSuccess) Navigator.pop(context, true);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.brown),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Edit Produk',
            style: TextStyle(
                color: Colors.brown[600], fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.brown.withOpacity(0.1),
                        border: Border.all(color: Colors.brown, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_a_photo_outlined,
                            color: Colors.brown, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(widget.product.image ?? '')
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _image == null
                        ? const Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              buildTextField(
                controller: _kodeProduk,
                label: 'Kode Produk',
              ),
              const SizedBox(height: 16),
              buildTextField(controller: _namaProduk, label: 'Nama Produk'),
              const SizedBox(height: 16),
              buildTextField(
                controller: _hargaProduk,
                label: 'Harga (Rp)',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                    trailingSymbol: '',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _stokProduk,
                label: 'Stok',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _hpp,
                label: 'Harga Pokok (HPP)',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                    trailingSymbol: '',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _hargaJualProductBundling,
                label: 'Harga Produk (bundling)',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                    trailingSymbol: '',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _jmlProdukPerBundling,
                label: 'Jumlah Produk per Bundling',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              status(_status, (bool value) {
                setState(() {
                  _status = value;
                });
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[400],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Perubahan',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
