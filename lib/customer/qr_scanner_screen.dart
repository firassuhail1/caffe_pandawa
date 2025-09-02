// lib/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'menu_screen.dart'; // Halaman menu

class QrScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pindai QR Code Meja')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final barcode = barcodes.first;
            final String? qrData = barcode.rawValue;

            if (qrData != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(qrData);
                final String tableNumber = data['table_number'];

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(
                      tableNumber: tableNumber,
                    ),
                  ),
                );
              } catch (e) {
                print('Data QR tidak valid: $e');
              }
            }
          }
        },
      ),
    );
  }
}
