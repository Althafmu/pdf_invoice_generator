// Basic widget test for PDF Invoice Generator app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdf_invoice_generator/main.dart';

void main() {
  testWidgets('App loads with Tax Invoice Generator title',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PdfInvoiceApp());

    // Verify that the app title is displayed
    expect(find.text('Tax Invoice Generator'), findsOneWidget);

    // Verify the Generate PDF button exists
    expect(find.text('Generate PDF Invoice'), findsOneWidget);
  });
}
