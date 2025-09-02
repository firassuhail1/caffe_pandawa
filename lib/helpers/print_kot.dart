import 'package:caffe_pandawa/models/Order.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class Print {
  Print._init();

  static final Print instance = Print._init();

  Future<List<int>> printKOT(Order orderData) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final orderNumber = orderData.orderNumber;
    final items = orderData.items;
    final now = DateTime.now();
    final formatter =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";

    // Header KOT
    bytes += generator.text(
      "KITCHEN ORDER TICKET",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text("--------------------------------");

    // Informasi Pesanan
    bytes += generator.text("Order: #$orderNumber",
        styles: const PosStyles(bold: true));
    bytes += generator.text("Date: $formatter");
    bytes += generator.text("--------------------------------");

    // Daftar Item Pesanan
    for (var item in items) {
      final productName = item.productName;
      final quantity = item.qty;
      bytes +=
          generator.text("$productName", styles: const PosStyles(bold: true));
      bytes += generator.text("Qty: $quantity");
      bytes += generator.feed(1);
    }

    // Footer
    bytes += generator.text("--------------------------------");
    bytes += generator.text("Siap disajikan!");
    bytes += generator.feed(6);

    return bytes;
  }
}
