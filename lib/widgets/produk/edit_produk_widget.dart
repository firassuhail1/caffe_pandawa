import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 2),
      ),
      suffixIcon: suffixIcon,
    ),
    validator:
        validator ?? (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
  );
}

Widget status(status, Function(bool) updateStatus) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
    margin: EdgeInsets.only(bottom: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Status Produk", style: TextStyle(fontSize: 15)),
        Container(
          width: 40,
          height: 20,
          child: Transform.scale(
            scaleY: 0.75,
            scaleX: 0.78,
            child: Switch(
              value: status,
              onChanged: (value) {
                updateStatus(value);
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.brown[400],
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
