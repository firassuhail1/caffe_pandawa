import 'package:caffe_pandawa/main-pages/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Tambahkan ini:
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', ''), // English
      //   Locale('id', 'ID'), // Indonesian
      //   // Tambahkan locale lain yang didukung aplikasi Anda
      // ],
      theme: _buildTheme(Brightness.light), // Tema Terang
      darkTheme: _buildTheme(Brightness.dark), // Tema Gelap
      themeMode: ThemeMode.light, // Otomatis mengikuti sistem
      home: AuthWrapper(),
    );
  }
}

// ✅ Perbaikan: Gunakan ThemeData.light() atau ThemeData.dark()
ThemeData _buildTheme(Brightness brightness) {
  final baseTheme =
      brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

  return baseTheme.copyWith(
    textTheme:
        GoogleFonts.ptSansTextTheme(baseTheme.textTheme), // Terapkan font
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.brown[400],
      selectionColor: Colors.brown.withOpacity(0.4),
      selectionHandleColor: Colors.brown,
    ),
  );
}
