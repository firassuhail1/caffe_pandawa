import 'package:another_flushbar/flushbar.dart';
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
