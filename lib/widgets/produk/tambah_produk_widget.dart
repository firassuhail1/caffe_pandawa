import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

Widget buildInputField(TextEditingController controller, String label,
    {TextInputType inputType = TextInputType.text, Widget? suffix}) {
  return TextFormField(
    controller: controller,
    keyboardType: inputType,
    style: TextStyle(),
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    // validator: (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
  );
}

Widget buildCurrencyField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: TextStyle(),
    inputFormatters: [
      CurrencyInputFormatter(
        thousandSeparator: ThousandSeparator.Period,
        mantissaLength: 0,
      ),
    ],
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    validator: (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
  );
}
