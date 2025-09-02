import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/helpers/print_meja.dart';
import 'package:caffe_pandawa/services/table_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saver_gallery/saver_gallery.dart';

class TableSettingsScreen extends StatefulWidget {
  @override
  _TableSettingsScreenState createState() => _TableSettingsScreenState();
}

class _TableSettingsScreenState extends State<TableSettingsScreen> {
  final TableService _tableService = TableService();
  List<dynamic> _tables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    try {
      final tables = await _tableService.fetchTables();
      setState(() {
        _tables = tables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat data meja. $e')));
    }
  }

  void _showTableForm({Map<String, dynamic>? table}) {
    final _controller = TextEditingController(text: table?['table_number']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(table == null ? 'Tambah Meja Baru' : 'Edit Meja'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Nomor Meja'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final tableNumber = _controller.text;
                if (tableNumber.isNotEmpty) {
                  if (table == null) {
                    await _tableService.createTable(tableNumber);
                  } else {
                    await _tableService.updateTable(table['id'], tableNumber);
                  }
                  Navigator.pop(context);
                  _fetchTables();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTable(int tableId) async {
    await _tableService.deleteTable(tableId);
    _fetchTables();
  }

  void _showQrCode(Map<String, dynamic> table) {
    final qrData = json.encode({
      'table_number': table['table_number'],
    });

    // key untuk render QR + teks jadi satu gambar
    GlobalKey qrKey = GlobalKey();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('QR Code Meja ${table['table_number']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔑 RepaintBoundary untuk QR + teks
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  color: Colors.white, // biar background tidak transparan
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Meja ${table['table_number']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Pindai QR ini untuk memesan',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  _printToThermal(qrData);
                },
                icon: Icon(Icons.print),
                label: Text('Cetak dengan Printer Thermal'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await _saveQrToGallery(qrKey, table['table_number'], context);
                },
                icon: Icon(Icons.save),
                label: Text('Simpan sebagai PNG'),
              ),
            ],
          ),
        );
      },
    );
  }

  // TODO: Fungsi untuk mencetak ke printer thermal
  Future<void> _printToThermal(String data) async {
    List<int> printValue = await Print.instance.printMeja(data);
    final bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      await PrintBluetoothThermal.writeBytes(printValue);
    } else {
      // TODO : Jika belum, maka berikan dialog bahwa printer belum terhubung.
      showConnectionFlushbar(context, "Printer belum terhubung.");
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<void> _saveQrToGallery(
      GlobalKey qrKey, String tableNumber, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted ||
          await Permission.mediaLibrary.request().isGranted) {
        final boundary =
            qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) throw "Gagal konversi image ke bytes.";

        Uint8List pngBytes = byteData.buffer.asUint8List();

        await SaverGallery.saveImage(
          pngBytes,
          fileName: "qr_table_$tableNumber.png",
          skipIfExists: false,
          androidRelativePath: "Pictures/CaffePandawa",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("QR Meja $tableNumber berhasil disimpan ke galeri.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Izin akses galeri ditolak.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan QR: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Meja'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tables.isEmpty
              ? Center(child: Text('Belum ada meja yang terdaftar.'))
              : ListView.builder(
                  itemCount: _tables.length,
                  itemBuilder: (context, index) {
                    final table = _tables[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.table_bar, color: Colors.blue),
                        title: Text('Meja ${table['table_number']}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${table['id']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.qr_code),
                              color: Colors.green,
                              onPressed: () => _showQrCode(table),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.orange,
                              onPressed: () => _showTableForm(table: table),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _deleteTable(table['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTableForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
    );
  }
}
