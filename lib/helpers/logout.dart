import 'package:another_flushbar/flushbar.dart';
import 'package:caffe_pandawa/main-pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:caffe_pandawa/services/auth_services.dart';

final AuthServices services = AuthServices();
final FlutterSecureStorage storage = FlutterSecureStorage();

Future<void> confirmLogout(BuildContext context) async {
  bool? confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.exit_to_app, size: 50, color: Colors.brown[400]),
              SizedBox(height: 10),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Apakah Anda yakin ingin keluar?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Batal"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[400],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirm == true) {
    final result = await services.logout();

    if (result) {
      print("Token berhasil dihapus");
      await storage.delete(key: '_token'); // Hapus token
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } else {
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 2),
        messageText: Text(
          'Gagal melakukan logout',
          style: const TextStyle(color: Colors.white),
        ),
      ).show(context);
    }
  }

  // if (confirm == true) {
  //   await logout(context);
  // }
}

// Future<void> logout(BuildContext context) async {
//   try {
//     await storage.delete(key: '_token'); // Hapus token
//     print("Token berhasil dihapus");
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => LandingPage()),
//       (route) => false,
//     );
//   } catch (e) {
//     print("Gagal menghapus token: $e");
//   }
// }
