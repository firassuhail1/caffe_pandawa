import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:caffe_pandawa/main-pages/homepage.dart';
import 'package:caffe_pandawa/main-pages/login.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    check();
  }

  Future<void> check() async {
    String? _token = await storage.read(key: '_token');

    if (mounted) {
      setState(() {
        token = _token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (token != null && token != "") {
      return HomePage(); // Sudah login
    } else {
      return Login(); // Belum login
    }
  }
}
