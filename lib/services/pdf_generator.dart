import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_data.dart';

/// Service class for generating PDF invoices
class PdfGeneratorService {
  // Border style for consistent borders
  static const _border = pw.BorderSide(width: 1);
  static const _thinBorder = pw.BorderSide(width: 0.5);

  /// Generate PDF invoice and save to file
  Future<String> generateInvoice(InvoiceData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return _buildInvoice(data);
        },
      ),
    );

    // Save to documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Invoice_${data.invoiceNumber}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Build the complete invoice layout
  pw.Widget _buildInvoice(InvoiceData data) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildTitle(),
          _buildHeaderSection(data),
          _buildConsigneeSection(data),
          _buildBuyerSection(),
          _buildStateSection(),
          _buildItemsTable(data),
          _buildAmountSection(data),
          _buildTaxBankSection(data),
          _buildSignatorySection(),
        ],
      ),
    );
  }

  /// Build the TAX INVOICE title
  pw.Widget _buildTitle() {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Center(
        child: pw.Text('TAX INVOICE',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ),
    );
  }

  /// Build header section with Consignor + Invoice Info
  pw.Widget _buildHeaderSection(InvoiceData data) {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration:
                  const pw.BoxDecoration(border: pw.Border(right: _thinBorder)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _labelValue('Consignor Name', data.consignorName, bold: true),
                  _labelValue('Address', data.consignorAddress),
                  _labelValue('City', data.consignorCity),
                  _labelValue('GSTIN/UIN', data.consignorGstin, bold: true),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(children: [
              _infoRow('Invoice No.', data.invoiceNumber, 'Dated',
                  DateFormat('dd/MM/yyyy').format(data.invoiceDate)),
              _infoRow("Buyer's Order No.", '', "Buyer's Order Date", ''),
              _infoRow('Bill From', data.consignorCity, 'Bill To',
                  data.consigneeCity),
              _infoRow('Dispatched Through', '', 'Delivery Note Dated', ''),
              _infoRow('Bill Of Lading/ L.R. No.', '', 'Motor Vehicle No.',
                  data.vehicleNumber),
              _infoRow('Loading From:', data.loadingFrom, 'Delivery Point',
                  data.deliveryPoint),
            ]),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoRow(
      String label1, String value1, String label2, String value2) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(left: _thinBorder, bottom: _thinBorder)),
      child: pw.Row(children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(3),
            decoration:
                const pw.BoxDecoration(border: pw.Border(right: _thinBorder)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label1, style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(value1,
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ]),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label2, style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(value2,
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ]),
          ),
        ),
      ]),
    );
  }

  pw.Widget _buildConsigneeSection(InvoiceData data) {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration:
                  const pw.BoxDecoration(border: pw.Border(right: _thinBorder)),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _labelValue('Consignee Name', data.consigneeName,
                        bold: true),
                    _labelValue('Address', data.consigneeAddress),
                    _labelValue('City', data.consigneeCity),
                    _labelValue('GSTIN/UIN', data.consigneeGstin, bold: true),
                  ]),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Special Note:',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 4),
                    pw.Text(data.displaySpecialNote,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBuyerSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      child:
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Buyer(if other than Consignee)',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        _labelValue('GSTIN/UIN', ''),
        _labelValue('State Name', ''),
        _labelValue('Place of Supply', ''),
      ]),
    );
  }

  pw.Widget _buildStateSection() {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      child: pw.Row(children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration:
                const pw.BoxDecoration(border: pw.Border(right: _thinBorder)),
            child:
                pw.Text('State Name:', style: const pw.TextStyle(fontSize: 8)),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('Place of Supply:',
                style: const pw.TextStyle(fontSize: 8)),
          ),
        ),
      ]),
    );
  }

  pw.Widget _buildItemsTable(InvoiceData data) {
    final products = data.products;
    final emptyRowsNeeded = (5 - products.length).clamp(0, 5);

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(55),
        3: const pw.FixedColumnWidth(65),
        4: const pw.FixedColumnWidth(45),
        5: const pw.FixedColumnWidth(25),
        6: const pw.FixedColumnWidth(75),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('S NO.', header: true),
            _tableCell('Description Of Goods', header: true),
            _tableCell('HSN/SAC', header: true),
            _tableCell('Quantity', header: true),
            _tableCell('Rate', header: true),
            _tableCell('Per', header: true),
            _tableCell('Amount', header: true),
          ],
        ),
        // Product rows
        ...products.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return pw.TableRow(children: [
            _tableCell('${i + 1}', align: pw.TextAlign.center),
            _tableCell(p.description),
            _tableCell(p.hsnCode, align: pw.TextAlign.center),
            _tableCell(p.quantity, align: pw.TextAlign.center),
            _tableCell(p.rate.toStringAsFixed(2), align: pw.TextAlign.right),
            _tableCell('-', align: pw.TextAlign.center),
            _tableCell(InvoiceData.formatIndianCurrency(p.amount),
                align: pw.TextAlign.right),
          ]);
        }),
        // Empty rows
        ...List.generate(
            emptyRowsNeeded,
            (_) => pw.TableRow(
                  children: List.generate(7, (_) => _tableCell('')),
                )),
        // Total row
        pw.TableRow(children: [
          _tableCell(''),
          _tableCell(''),
          _tableCell(''),
          _tableCell('Total', align: pw.TextAlign.right, bold: true),
          _tableCell(''),
          _tableCell(''),
          _tableCell(InvoiceData.formatIndianCurrency(data.totalAmount),
              align: pw.TextAlign.right, bold: true),
        ]),
      ],
    );
  }

  pw.Widget _tableCell(String text,
      {bool header = false,
      pw.TextAlign align = pw.TextAlign.left,
      bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 8,
            fontWeight:
                (header || bold) ? pw.FontWeight.bold : pw.FontWeight.normal),
        textAlign: header ? pw.TextAlign.center : align,
      ),
    );
  }

  pw.Widget _buildAmountSection(InvoiceData data) {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      child: pw.Row(children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration:
                const pw.BoxDecoration(border: pw.Border(right: _thinBorder)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Amount Chargeable(in Words)',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 2),
                  pw.Text(InvoiceData.amountInWords(data.totalAmount),
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Tax Amount(in Words):',
                      style: const pw.TextStyle(fontSize: 8)),
                ]),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('E.&O.E',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.right),
          ),
        ),
      ]),
    );
  }

  pw.Widget _buildTaxBankSection(InvoiceData data) {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: _border)),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration:
                const pw.BoxDecoration(border: pw.Border(right: _thinBorder)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Declaration',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Remarks:',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Any discrepancy in respect of quantity, measurement, weight etc. should be notified to us within seven days from date of receipt. We are not responsible there after. Interest will be charged @ 24% p.a. If the payment is not made within the stipulated time. We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.',
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                ]),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Column(children: [
            _taxRow(
                'Sub Total', InvoiceData.formatIndianCurrency(data.subTotal)),
            _taxRow('IGST (${data.igstPercent}%)',
                InvoiceData.formatIndianCurrency(data.igst)),
            _taxRow('CGST (${data.cgstPercent}%)',
                InvoiceData.formatIndianCurrency(data.cgst)),
            _taxRow('SGST (${data.sgstPercent}%)',
                InvoiceData.formatIndianCurrency(data.sgst)),
            _taxRow('Grand Total',
                InvoiceData.formatIndianCurrency(data.grandTotal),
                bold: true),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(4),
              decoration:
                  const pw.BoxDecoration(border: pw.Border(top: _thinBorder)),
              child: pw.Text('Company Bank Detail',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
            _bankRow('Bank', data.bankName),
            _bankRow('A/C No:', data.accountNo),
            _bankRow('Branch:', data.branch),
            _bankRow('IFSC Code:', data.ifscCode),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(data.consignorName,
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center),
            ),
          ]),
        ),
      ]),
    );
  }

  pw.Widget _taxRow(String label, String value, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration:
          const pw.BoxDecoration(border: pw.Border(bottom: _thinBorder)),
      child: pw
          .Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 8,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 8,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ]),
    );
  }

  pw.Widget _bankRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: pw.Row(children: [
        pw.SizedBox(
            width: 55,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 7))),
        pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 7))),
      ]),
    );
  }

  pw.Widget _buildSignatorySection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.SizedBox(height: 20),
          pw.Text('Authorised Signatory',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ]),
      ]),
    );
  }

  pw.Widget _labelValue(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(
            width: 80,
            child: pw.Text('$label :', style: const pw.TextStyle(fontSize: 8))),
        pw.Expanded(
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
      ]),
    );
  }
}
