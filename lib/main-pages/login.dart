import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:caffe_pandawa/main-pages/homepage.dart';
import 'package:caffe_pandawa/services/auth_services.dart';

class Login extends StatefulWidget {
  final String? kodeToko;

  const Login({
    Key? key,
    this.kodeToko,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthServices services = AuthServices();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  TextEditingController kodeTokoController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Color scheme
  final Color primaryColor = const Color.fromARGB(255, 77, 38, 38);
  final Color darkBrownColor = const Color.fromARGB(255, 62, 44, 44);
  final Color backgroundColor = Colors.white;
  final Color textColor = const Color(0xFF424242);
  final Color lightGreyColor = const Color(0xFFEEEEEE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    kodeTokoController.text = widget.kodeToko ?? "";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result =
          await services.login(_emailController.text, _passwordController.text);

      if (result['success']) {
        await storage.write(key: '_token', value: result['token']);
        await storage.write(key: '_user', value: jsonEncode(result['user']));

        String? token = await storage.read(key: '_token');
        String? user = await storage.read(key: '_user');

        print("token terpasang : $token");
        print("user terpasang : $user");

        await showDialogResponse(result['success'], result['message']);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
          (route) => false,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        showDialogResponse(result['success'], result['message']);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> showDialogResponse(bool status, String message) async {
    return await Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: status ? Colors.green.shade600 : Colors.red.shade600,
      icon:
          Icon(status ? Icons.check_circle : Icons.error, color: Colors.white),
      duration: const Duration(seconds: 2),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: PopScope(
        canPop: false, // jangan di pop dulu
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // kita intercept dan kirim result secara manual
            Navigator.pop(context, true);
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              // Icons.breakfast_dining,
              Icons.shopping_bag_outlined,
              size: 48,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Caffe Pandawa',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            // fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silahkan login untuk melanjutkan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: textColor.withOpacity(1),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor:
              Colors.brown[400], // warna titik bulat penggeser
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Masukkan email anda',
          prefixIcon: Icon(Icons.person_outline, color: primaryColor),
          filled: true,
          fillColor: lightGreyColor.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          floatingLabelStyle: TextStyle(color: primaryColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      cursorColor: primaryColor,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan password anda',
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: primaryColor,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: lightGreyColor.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        floatingLabelStyle: TextStyle(color: primaryColor),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _attemptLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryColor.withOpacity(0.5),
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'MASUK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: lightGreyColor,
                thickness: 1,
              ),
            ),
            Expanded(
              child: Divider(
                color: lightGreyColor,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Aplikasi Caffe Pandawa',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
