import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class Print {
  Print._init();

  static final Print instance = Print._init();

  Future<List<int>> printMeja(qrData) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // ubah string ke Map
    Map<String, dynamic> data = jsonDecode(qrData);

    bytes += generator.reset();

    bytes += generator.text(
      "Meja ${data['table_number']}",
      styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size4,
          width: PosTextSize.size4),
    );

    bytes += generator.feed(1);

    bytes += generator.text("Pindai QR ini untuk memesan");

    bytes += generator.qrcode(qrData, size: QRSize.size7);

    bytes += generator.feed(6);

    return bytes;
  }
}
