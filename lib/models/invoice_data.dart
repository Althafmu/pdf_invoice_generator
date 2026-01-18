/// Represents a single product item in the invoice
class ProductItem {
  String description;
  String hsnCode;
  String quantity;
  double rate;
  double amount;

  ProductItem({
    this.description = '',
    this.hsnCode = '',
    this.quantity = '',
    this.rate = 0.0,
    this.amount = 0.0,
  });

  /// Calculate amount from quantity and rate
  void calculateAmount() {
    final qty =
        double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    amount = qty * rate;
  }
}

/// Data model for invoice form inputs
class InvoiceData {
  // Basic invoice info
  final String vehicleNumber;
  final String invoiceNumber;
  final DateTime invoiceDate;

  // Consignor details
  final String consignorName;
  final String consignorAddress;
  final String consignorCity;
  final String consignorGstin;

  // Consignee details
  final String consigneeName;
  final String consigneeAddress;
  final String consigneeCity;
  final String consigneeGstin;

  // Product list
  final List<ProductItem> products;

  // Delivery details
  final String loadingFrom;
  final String deliveryPoint;
  final String specialNote;

  // Bank details
  final String bankName;
  final String accountNo;
  final String branch;
  final String ifscCode;

  // GST percentages
  final double igstPercent;
  final double cgstPercent;
  final double sgstPercent;

  InvoiceData({
    required this.vehicleNumber,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.consignorName = 'RUDRANSH TRADING COMPANY',
    this.consignorAddress = '101/2, SANWER MAIN ROAD\nBHAWRASIA SANWER',
    this.consignorCity = 'Indore',
    this.consignorGstin = '23ETGPM3306C1Z7',
    this.consigneeName = 'INDO REACH SOLUTIONS',
    this.consigneeAddress = '625 Khatiwala Tank\nNear Tower Square',
    this.consigneeCity = 'Indore',
    this.consigneeGstin = '23CBAPB8175L1ZN',
    this.products = const [],
    this.loadingFrom = 'SAWER ROAD',
    this.deliveryPoint = 'Iohamandi',
    this.specialNote = '',
    this.bankName = '',
    this.accountNo = '',
    this.branch = '',
    this.ifscCode = '',
    this.igstPercent = 0.0,
    this.cgstPercent = 9.0,
    this.sgstPercent = 9.0,
  });

  /// Calculate total amount from all products
  double get totalAmount => products.fold(0.0, (sum, p) => sum + p.amount);

  /// Calculate tax amounts
  double get subTotal => totalAmount;
  double get igst => totalAmount * (igstPercent / 100);
  double get cgst => totalAmount * (cgstPercent / 100);
  double get sgst => totalAmount * (sgstPercent / 100);
  double get grandTotal => subTotal + igst + cgst + sgst;

  /// Get special note or default route
  String get displaySpecialNote =>
      specialNote.isNotEmpty ? specialNote : '$loadingFrom TO $deliveryPoint';

  /// Format amount in Indian number format
  static String formatIndianCurrency(double amount) {
    if (amount == 0) return '0.00';

    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    // Apply Indian number formatting (XX,XX,XXX)
    String result = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        result = ',$result';
      }
      result = integerPart[i] + result;
      count++;
    }

    return '$result.$decimalPart';
  }

  /// Convert number to words (Indian format)
  static String amountInWords(double amount) {
    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String convertLessThanThousand(int num) {
      if (num == 0) return '';
      if (num < 20) return ones[num];
      if (num < 100) {
        return '${tens[num ~/ 10]} ${ones[num % 10]}'.trim();
      }
      return '${ones[num ~/ 100]} Hundred ${convertLessThanThousand(num % 100)}'
          .trim();
    }

    int intAmount = amount.toInt();
    if (intAmount == 0) return 'Zero Rupees Only';

    String result = '';

    // Crores
    if (intAmount >= 10000000) {
      result += '${convertLessThanThousand(intAmount ~/ 10000000)} Crore ';
      intAmount %= 10000000;
    }

    // Lakhs
    if (intAmount >= 100000) {
      result += '${convertLessThanThousand(intAmount ~/ 100000)} Lakh ';
      intAmount %= 100000;
    }

    // Thousands
    if (intAmount >= 1000) {
      result += '${convertLessThanThousand(intAmount ~/ 1000)} Thousand ';
      intAmount %= 1000;
    }

    // Hundreds and below
    result += convertLessThanThousand(intAmount);

    return '${result.trim()} Rupees Only';
  }
}
