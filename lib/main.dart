import 'package:flutter/material.dart';
import 'screens/invoice_form_screen.dart';

void main() {
  runApp(const PdfInvoiceApp());
}

class PdfInvoiceApp extends StatelessWidget {
  const PdfInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tax Invoice Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const InvoiceFormScreen(),
    );
  }
}
