import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DrawerWidget extends StatefulWidget {
  final bool isShiftOn;
  final Future<void> Function(String?) attemptEndingCashier;
  final Future<void> Function(String?, String?) attemptCashIn;
  final Future<void> Function(String?, String?) attemptCashOut;

  const DrawerWidget({
    super.key,
    required this.isShiftOn,
    required this.attemptEndingCashier,
    required this.attemptCashIn,
    required this.attemptCashOut,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- Bagian Menu Utama: Status Shift ---
          const SizedBox(height: 36),
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Kasir',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Wrap(
                  children: [
                    Switch(
                      value: widget.isShiftOn,
                      onChanged: (value) async {
                        // try {
                        //   updateProductStatus(index, value);

                        //   services.editStatusProduct(
                        //     product.id,
                        //     value,
                        //   );
                        // } catch (e) {
                        //   print('eror');
                        // }
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.brown[400],
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Menu Kasir',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.receipt_long, color: Colors.blueGrey[700]),
            title: const Text(
              'Rekap Kas Harian',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              // Navigasi ke halaman Rekap Kas
              // Navigator.push(context, MaterialPageRoute(builder: (context) => RekapKasPage()));
            },
          ),
          ListTile(
            leading:
                Icon(MdiIcons.accountClockOutline, color: Colors.blueGrey[700]),
            title: const Text(
              'Tutup Shift',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              // Tampilkan dialog konfirmasi atau navigasi ke halaman Tutup Shift
              _showEndingCashierDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.input_rounded, color: Colors.blueGrey[700]),
            title: const Text(
              'Uang Masuk',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              // Tampilkan dialog konfirmasi atau navigasi ke halaman Tutup Shift
              _showCashInDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.outbond_outlined, color: Colors.blueGrey[700]),
            title: const Text(
              'Uang Keluar',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              // Tampilkan dialog konfirmasi atau navigasi ke halaman Tutup Shift
              _showCashOutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi Tutup Shift
  void _showEndingCashierDialog(BuildContext context) {
    TextEditingController _endingCashController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan tap di luar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tutup Shift'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Masukkan uang tutup kasir Anda:'),
                const SizedBox(height: 10),
                TextField(
                  controller: _endingCashController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                      trailingSymbol: '',
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Uang Tutup Kasir',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ', // Menambahkan prefix "Rp"
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              // Tambahkan tombol 'Batal' agar user bisa menutup dialog
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Tutup'),
              onPressed: () async {
                // Lakukan sesuatu dengan nilai uang buka kasir
                // Contoh: Simpan ke database, tampilkan di UI, dll.
                print('Uang tutup kasir: Rp ${_endingCashController.text}');
                String cleanedAmount =
                    _endingCashController.text.replaceAll('.', '');
                await widget.attemptEndingCashier(cleanedAmount);
                if (mounted) Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showCashInDialog(BuildContext context) {
    TextEditingController _cashInController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan tap di luar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Uang Masuk'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Masukkan uang masuk:'),
                const SizedBox(height: 10),
                TextField(
                  controller: _cashInController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                      trailingSymbol: '',
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Uang Masuk',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ', // Menambahkan prefix "Rp"
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              // Tambahkan tombol 'Batal' agar user bisa menutup dialog
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Masukkan'),
              onPressed: () async {
                // Lakukan sesuatu dengan nilai uang buka kasir
                // Contoh: Simpan ke database, tampilkan di UI, dll.
                print('Uang masuk: Rp ${_cashInController.text}');
                print('Description: Rp ${_descriptionController.text}');
                String cleanedAmount =
                    _cashInController.text.replaceAll('.', '');
                await widget.attemptCashIn(
                    cleanedAmount, _descriptionController.text);
                if (mounted) Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showCashOutDialog(BuildContext context) {
    TextEditingController _cashOutController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan tap di luar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Uang Keluar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Masukkan uang keluar:'),
                const SizedBox(height: 10),
                TextField(
                  controller: _cashOutController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                      trailingSymbol: '',
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Uang Keluar',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ', // Menambahkan prefix "Rp"
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              // Tambahkan tombol 'Batal' agar user bisa menutup dialog
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Tutup'),
              onPressed: () async {
                // Lakukan sesuatu dengan nilai uang buka kasir
                // Contoh: Simpan ke database, tampilkan di UI, dll.
                print('Uang tutup kasir: Rp ${_cashOutController.text}');
                print('Description: Rp ${_descriptionController.text}');
                String cleanedAmount =
                    _cashOutController.text.replaceAll('.', '');
                await widget.attemptCashOut(
                    cleanedAmount, _descriptionController.text);
                if (mounted) Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }
}
