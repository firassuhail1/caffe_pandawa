import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:caffe_pandawa/services/product_services.dart';
import 'package:caffe_pandawa/widgets/produk/tambah_produk_widget.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({Key? key}) : super(key: key);

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final ProductServices services = ProductServices();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kodeProduk = TextEditingController();
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _hargaProduk = TextEditingController(text: "0");
  final TextEditingController _stokProduk = TextEditingController(text: "0");
  final TextEditingController _jmlProdukPerBundling =
      TextEditingController(text: "1");

  File? _image;
  bool _status = true;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      // print(_hargaProduk.text.replaceAll('.', ''));
      try {
        final result = await services.addProduct(
          kodeProduk: _kodeProduk.text,
          namaProduk: _namaProduk.text,
          hargaProduk: _hargaProduk.text,
          stock: _stokProduk.text,
          jmlProdukPerBundling: _jmlProdukPerBundling.text,
          status: _status,
          image: _image, // bisa null jika tidak diganti
        );

        Navigator.pop(context, true); // Tutup loading

        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Produk berhasil ditambah"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // kembali ke halaman sebelumnya
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menambah produk"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Tutup loading kalau error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.brown[400]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tambah Produk',
          style: TextStyle(
            color: Colors.brown[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10),
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
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.brown[400],
                          size: 36,
                        ),
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
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey)
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 26),
              buildInputField(
                _kodeProduk,
                "Kode Produk",
              ),
              SizedBox(height: 16),
              buildInputField(_namaProduk, "Nama Produk"),
              SizedBox(height: 16),
              buildCurrencyField(_hargaProduk, "Harga (Rp)"),
              SizedBox(height: 16),
              buildInputField(_stokProduk, "Stok",
                  inputType: TextInputType.number),
              SizedBox(height: 16),
              buildInputField(_jmlProdukPerBundling, "Jml Produk / bundling",
                  inputType: TextInputType.number),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status Produk", style: TextStyle(fontSize: 15)),
                  Transform.scale(
                    scaleX: 0.78,
                    scaleY: 0.75,
                    child: Switch(
                      value: _status,
                      onChanged: (value) => setState(() => _status = value),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.brown[400],
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.add_circle_outline_rounded),
                  label: Text("Tambah Produk",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
