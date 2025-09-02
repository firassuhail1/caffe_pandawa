import 'package:caffe_pandawa/helpers/formatter.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/services/bahan_baku_services.dart';
import 'package:caffe_pandawa/widgets/produk/tambah_produk_widget.dart';

class BahanBakuForm extends StatefulWidget {
  final BahanBaku? bahanBaku;

  const BahanBakuForm({
    Key? key,
    this.bahanBaku,
  }) : super(key: key);

  @override
  State<BahanBakuForm> createState() => _BahanBakuFormState();
}

class _BahanBakuFormState extends State<BahanBakuForm> {
  final BahanBakuServices services = BahanBakuServices();
  final _formKey = GlobalKey<FormState>();

  int? selectedOutlet;

  List<Map<String, dynamic>> satuanUkur = [
    {"nama": "kg"},
    {"nama": "gram"},
    {"nama": "liter"},
    {"nama": "ml"},
    {"nama": "meter"},
    {"nama": "cm"},
    {"nama": "mm"},
    {"nama": "pcs"},
    {"nama": "rol"},
    {"nama": "botol"},
  ];

  final TextEditingController _kodeProduk = TextEditingController();
  final TextEditingController _namaProduk = TextEditingController();
  final TextEditingController _stock = TextEditingController(text: "0");
  final TextEditingController _hargaPembelian =
      TextEditingController(text: "0");
  final TextEditingController _minStokAlert = TextEditingController(text: "0");
  String selectedSatuanUkur = 'pcs';

  static const Color cardColor = Color(0xFFFAFAFA);
  static const Color primaryColor = Color(0xFF00BCD4);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  void loadData() async {
    setState(() {
      if (widget.bahanBaku != null) {
        _kodeProduk.text = widget.bahanBaku?.kodeBahanBaku ?? "";
        _namaProduk.text = widget.bahanBaku?.namaBahanBaku ?? "";
        _stock.text = formatter(widget.bahanBaku?.bahanBakuInventory[0].stock);
        _hargaPembelian.text =
            widget.bahanBaku?.standartCostPrice.toStringAsFixed(0) ?? "";
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        // cek apakah ini tambah bahan baku atau edit bahan baku
        // jika tambah bahan baku
        if (widget.bahanBaku?.id == null) {
          final result = await services.addBahanBaku(
            _kodeProduk.text,
            _namaProduk.text,
            selectedSatuanUkur,
            double.parse(_hargaPembelian.text.replaceAll('.', '')),
            int.parse(_minStokAlert.text.replaceAll('.', '')),
            selectedOutlet,
            double.parse(_stock.text.replaceAll('.', '')),
          );

          Navigator.pop(context, true); // Tutup loading

          if (result) {
            await flushbarMessage(context, "Berhasil menambah bahan baku",
                Colors.green.shade600, Icons.check_circle);
            Navigator.pop(context, true); // kembali ke halaman sebelumnya
          } else {
            flushbarMessage(context, "Gagal menambah bahan baku",
                Colors.red.shade600, Icons.warning);
          }
        } else {
          final result = await services.editBahanBaku(
            widget.bahanBaku!.id,
            _kodeProduk.text,
            _namaProduk.text,
            selectedSatuanUkur,
            double.parse(_hargaPembelian.text),
            int.parse(_minStokAlert.text),
            double.parse(_stock.text.replaceAll('.', '')),
          );

          Navigator.pop(context); // Tutup loading

          if (result) {
            await flushbarMessage(context, "Berhasil mengubah bahan baku",
                Colors.green.shade600, Icons.check_circle);
            Navigator.pop(context, true); // kembali ke halaman sebelumnya
          } else {
            flushbarMessage(context, "Gagal mengubah bahan baku",
                Colors.red.shade600, Icons.warning);
          }
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
        leading: BackButton(color: Colors.brown),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.bahanBaku?.id != null ? "Edit" : "Tambah"} Bahan Baku',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 26),
              buildInputField(
                _kodeProduk,
                "Kode Produk",
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak wajib diisi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              buildInputField(_namaProduk, "Nama Produk"),
              SizedBox(height: 16),
              buildCurrencyField(_stock, "Quantity"),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BCD4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSatuanUkur,
                    hint: const Text('Pilih Satuan Ukur'),
                    items: satuanUkur.map((satuan) {
                      return DropdownMenuItem<String>(
                        value: satuan['nama'],
                        child: Text(satuan['nama']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSatuanUkur = value!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              buildCurrencyField(
                  _hargaPembelian, "HPP (Rp/${selectedSatuanUkur})"),
              SizedBox(height: 16),
              buildCurrencyField(_minStokAlert,
                  "Minimal Stok Untuk Peringatan (${selectedSatuanUkur})"),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.add_circle_outline_rounded),
                  label: Text(
                      "${widget.bahanBaku?.id != null ? "Edit" : "Tambah"} Bahan Baku",
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
}
