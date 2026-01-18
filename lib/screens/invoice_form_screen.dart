import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../models/invoice_data.dart';
import '../services/pdf_generator.dart';

/// Main screen with invoice input form
class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic invoice controllers
  final _invoiceNumberController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  // Consignor controllers
  final _consignorNameController =
      TextEditingController(text: 'RUDRANSH TRADING COMPANY');
  final _consignorAddressController =
      TextEditingController(text: '101/2, SANWER MAIN ROAD\nBHAWRASIA SANWER');
  final _consignorCityController = TextEditingController(text: 'Indore');
  final _consignorGstinController =
      TextEditingController(text: '23ETGPM3306C1Z7');

  // Consignee controllers
  final _consigneeNameController = TextEditingController();
  final _consigneeAddressController = TextEditingController();
  final _consigneeCityController = TextEditingController();
  final _consigneeGstinController = TextEditingController();

  // Product list
  final List<ProductItem> _products = [];

  // Delivery controllers
  final _loadingFromController = TextEditingController();
  final _deliveryPointController = TextEditingController();
  final _specialNoteController = TextEditingController();

  // Bank controllers
  final _bankNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _branchController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  // GST percentage controllers
  final _igstPercentController = TextEditingController(text: '0');
  final _cgstPercentController = TextEditingController(text: '9');
  final _sgstPercentController = TextEditingController(text: '9');

  bool _isGenerating = false;
  String? _lastGeneratedPath;

  @override
  void initState() {
    super.initState();
    // Add one default product
    _addProduct();
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _vehicleNumberController.dispose();
    _consignorNameController.dispose();
    _consignorAddressController.dispose();
    _consignorCityController.dispose();
    _consignorGstinController.dispose();
    _consigneeNameController.dispose();
    _consigneeAddressController.dispose();
    _consigneeCityController.dispose();
    _consigneeGstinController.dispose();
    _loadingFromController.dispose();
    _deliveryPointController.dispose();
    _specialNoteController.dispose();
    _bankNameController.dispose();
    _accountNoController.dispose();
    _branchController.dispose();
    _ifscCodeController.dispose();
    _igstPercentController.dispose();
    _cgstPercentController.dispose();
    _sgstPercentController.dispose();
    super.dispose();
  }

  void _addProduct() {
    setState(() {
      _products.add(ProductItem(
        description: '',
        hsnCode: '',
        quantity: '',
        rate: 0.0,
        amount: 0.0,
      ));
    });
  }

  void _removeProduct(int index) {
    if (_products.length > 1) {
      setState(() {
        _products.removeAt(index);
      });
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _lastGeneratedPath = null;
    });

    try {
      final invoiceData = InvoiceData(
        vehicleNumber: _vehicleNumberController.text.trim(),
        invoiceNumber: _invoiceNumberController.text.trim(),
        invoiceDate: DateTime.now(),
        consignorName: _consignorNameController.text.trim(),
        consignorAddress: _consignorAddressController.text.trim(),
        consignorCity: _consignorCityController.text.trim(),
        consignorGstin: _consignorGstinController.text.trim(),
        consigneeName: _consigneeNameController.text.trim(),
        consigneeAddress: _consigneeAddressController.text.trim(),
        consigneeCity: _consigneeCityController.text.trim(),
        consigneeGstin: _consigneeGstinController.text.trim(),
        products: _products,
        loadingFrom: _loadingFromController.text.trim(),
        deliveryPoint: _deliveryPointController.text.trim(),
        specialNote: _specialNoteController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNo: _accountNoController.text.trim(),
        branch: _branchController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        igstPercent: double.tryParse(_igstPercentController.text.trim()) ?? 0.0,
        cgstPercent: double.tryParse(_cgstPercentController.text.trim()) ?? 9.0,
        sgstPercent: double.tryParse(_sgstPercentController.text.trim()) ?? 9.0,
      );

      final pdfGenerator = PdfGeneratorService();
      final filePath = await pdfGenerator.generateInvoice(invoiceData);

      setState(() {
        _lastGeneratedPath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () => _openPdf(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _openPdf(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tax Invoice Generator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // Invoice Details
                _buildSection(
                    title: 'Invoice Details',
                    icon: Icons.receipt,
                    children: [
                      Row(children: [
                        Expanded(
                            child: _buildTextField(_invoiceNumberController,
                                'Invoice No.', 'RDB002', Icons.numbers,
                                required: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(
                                _vehicleNumberController,
                                'Vehicle No.',
                                'MP09GH9324',
                                Icons.local_shipping,
                                required: true,
                                caps: true)),
                      ]),
                    ]),
                const SizedBox(height: 16),

                // Consignor
                _buildSection(
                    title: 'Consignor (Seller)',
                    icon: Icons.business,
                    children: [
                      _buildTextField(_consignorNameController, 'Name',
                          'Company Name', Icons.person,
                          required: true),
                      const SizedBox(height: 12),
                      _buildTextField(_consignorAddressController, 'Address',
                          'Full Address', Icons.location_on,
                          maxLines: 2, required: true),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _buildTextField(_consignorCityController,
                                'City', 'City', Icons.location_city,
                                required: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(_consignorGstinController,
                                'GSTIN', '23XXXXXXXXXX1Z7', Icons.verified,
                                caps: true, required: true)),
                      ]),
                    ]),
                const SizedBox(height: 16),

                // Consignee
                _buildSection(
                    title: 'Consignee (Buyer)',
                    icon: Icons.store,
                    children: [
                      _buildTextField(_consigneeNameController, 'Name',
                          'Buyer Name', Icons.person,
                          required: true),
                      const SizedBox(height: 12),
                      _buildTextField(_consigneeAddressController, 'Address',
                          'Buyer Address', Icons.location_on,
                          maxLines: 2),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _buildTextField(_consigneeCityController,
                                'City', 'City', Icons.location_city)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(_consigneeGstinController,
                                'GSTIN', '23XXXXXXXXXX1ZX', Icons.verified,
                                caps: true)),
                      ]),
                    ]),
                const SizedBox(height: 16),

                // Products Section
                _buildProductsSection(),
                const SizedBox(height: 16),

                // Delivery
                _buildSection(
                    title: 'Delivery Details',
                    icon: Icons.local_shipping,
                    children: [
                      Row(children: [
                        Expanded(
                            child: _buildTextField(_loadingFromController,
                                'Loading From', 'SAWER ROAD', Icons.upload)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(_deliveryPointController,
                                'Delivery Point', 'Iohamandi', Icons.download)),
                      ]),
                      const SizedBox(height: 12),
                      _buildTextField(_specialNoteController, 'Special Note',
                          'Optional', Icons.note),
                    ]),
                const SizedBox(height: 16),

                // Bank
                _buildSection(
                    title: 'Bank Details (Optional)',
                    icon: Icons.account_balance,
                    children: [
                      Row(children: [
                        Expanded(
                            child: _buildTextField(_bankNameController,
                                'Bank Name', '', Icons.account_balance)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(_accountNoController,
                                'Account No.', '', Icons.credit_card)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _buildTextField(_branchController, 'Branch',
                                '', Icons.location_on)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextField(_ifscCodeController,
                                'IFSC Code', '', Icons.code,
                                caps: true)),
                      ]),
                    ]),
                const SizedBox(height: 16),

                // GST
                _buildSection(
                    title: 'GST Percentages',
                    icon: Icons.percent,
                    children: [
                      Row(children: [
                        Expanded(
                            child: _buildGstTextField(
                                _igstPercentController, 'IGST %', '0')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildGstTextField(
                                _cgstPercentController, 'CGST %', '9')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildGstTextField(
                                _sgstPercentController, 'SGST %', '9')),
                      ]),
                    ]),
                const SizedBox(height: 24),

                // Total Display
                _buildTotalDisplay(),
                const SizedBox(height: 16),

                _buildGenerateButton(),

                if (_lastGeneratedPath != null) ...[
                  const SizedBox(height: 16),
                  _buildSuccessCard(),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _totalAmount => _products.fold(0.0, (sum, p) => sum + p.amount);

  double get _totalWithGst {
    final igst = _totalAmount *
        ((double.tryParse(_igstPercentController.text) ?? 0) / 100);
    final cgst = _totalAmount *
        ((double.tryParse(_cgstPercentController.text) ?? 9) / 100);
    final sgst = _totalAmount *
        ((double.tryParse(_sgstPercentController.text) ?? 9) / 100);
    return _totalAmount + igst + cgst + sgst;
  }

  Widget _buildTotalDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2E5077)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sub Total (without GST):',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('₹ ${InvoiceData.formatIndianCurrency(_totalAmount)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total (with GST):',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('₹ ${InvoiceData.formatIndianCurrency(_totalWithGst)}',
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGstTextField(
      TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14),
      onChanged: (_) => setState(() {}), // Trigger rebuild to update totals
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            const Icon(Icons.percent, color: Color(0xFF1E3A5F), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(51))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 2)),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.inventory, color: Color(0xFF1E3A5F), size: 20),
                SizedBox(width: 8),
                Text('Products',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F))),
              ]),
              ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
              _products.length, (index) => _buildProductCard(index)),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = _products[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withAlpha(51)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF1E3A5F),
                child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text('Product Details',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              if (_products.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeProduct(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: product.description,
                decoration: _inputDecoration('Description *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onChanged: (v) => product.description = v,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: product.hsnCode,
                decoration: _inputDecoration('HSN Code'),
                onChanged: (v) => product.hsnCode = v,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextFormField(
                initialValue: product.quantity,
                decoration: _inputDecoration('Quantity'),
                onChanged: (v) {
                  product.quantity = v;
                  _updateProductAmount(index);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: product.rate.toString(),
                decoration: _inputDecoration('Rate (₹)'),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  product.rate = double.tryParse(v) ?? 0;
                  _updateProductAmount(index);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: product.amount.toString(),
                decoration: _inputDecoration('Amount (₹) *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) return 'Invalid';
                  return null;
                },
                onChanged: (v) {
                  setState(() {
                    product.amount = double.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _updateProductAmount(int index) {
    setState(() {
      final product = _products[index];
      final qty = double.tryParse(
              product.quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0;
      product.amount = qty * product.rate;
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.withAlpha(77))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 2)),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF2E5077)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1E3A5F).withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: const Row(children: [
        Icon(Icons.receipt_long, size: 40, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TAX INVOICE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          Text('Fill in the details below',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F))),
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon,
      {bool required = false,
      bool caps = false,
      int maxLines = 1,
      TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization:
          caps ? TextCapitalization.characters : TextCapitalization.none,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      validator: required
          ? (value) => (value == null || value.isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(51))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generatePdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF2ECC71).withAlpha(102),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isGenerating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.picture_as_pdf, size: 22),
                SizedBox(width: 10),
                Text('Generate PDF Invoice',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ]),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2ECC71).withAlpha(77)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 18),
          SizedBox(width: 8),
          Text('PDF Generated!',
              style: TextStyle(
                  color: Color(0xFF1E7E34),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        Text(_lastGeneratedPath!,
            style: TextStyle(color: Colors.grey[700], fontSize: 11)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openPdf(_lastGeneratedPath!),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open PDF'),
            style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A5F),
                side: const BorderSide(color: Color(0xFF1E3A5F))),
          ),
        ),
      ]),
    );
  }
}
