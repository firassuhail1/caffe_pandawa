import 'package:another_flushbar/flushbar.dart';
import 'package:caffe_pandawa/helpers/pengaturan_printer.dart';
import 'package:flutter/material.dart';

Future<void> flushbarMessage(
    BuildContext context, String message, Color colors, IconData icon) async {
  await Flushbar(
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: colors,
    icon: Icon(icon, color: Colors.white),
    duration: const Duration(milliseconds: 1500),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
  ).show(context);
}

void showConnectionFlushbar(BuildContext context, String message) {
  Flushbar(
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: Colors.red.shade600,
    icon: const Icon(Icons.info, color: Colors.white),
    duration: const Duration(seconds: 3),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
    mainButton: TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PengaturanPrinter(),
          ),
        );
      },
      child: const Text(
        'Buka Pengaturan',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  ).show(context);
}
