import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:ksoftsms/controller/dbmodels/feePaymentModel.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import '../widgets/dropdown.dart';
import '../controller/dbmodels/contestantsmodel.dart';
import '../components/receiptpdf.dart';
import 'package:pdf/pdf.dart';

class FeePayment extends StatefulWidget {
  const FeePayment({super.key});

  @override
  State<FeePayment> createState() => _FeePaymentState();
}

class _FeePaymentState extends State<FeePayment> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final searchController = TextEditingController();

  String? selectedpaymentmethod;
  String? selectedLinkedAccount;
  String? selectedfee;
  String? selectedTerm;
  StudentModel? selectedStudent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.getdata();
      provider.paymentmethodslist();
      provider.fetchFess();
      await provider.fetchterms();
      
      if (mounted && provider.term.isNotEmpty) {
        setState(() {
          selectedTerm = provider.term;
        });
      }
    });
    amountController.addListener(() => setState(() {}));
    noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            appBar: AppBar(
              title: const Text('Fee Payment Management'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () async {
                    await provider.getdata();
                    provider.paymentmethodslist();
                    provider.fetchFess();
                    provider.fetchterms();
                  },
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: isMobile 
                        ? _buildMobileLayout(context, provider, colors)
                        : _buildDesktopLayout(context, provider, colors, constraints.maxHeight),
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Myprovider provider, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (provider.loadterms || provider.loadschool)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Form Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildFormContent(context, provider, colors, isMobile: true),
                ),
                Divider(height: 1, color: colors.outlineVariant, thickness: 1.5),
                // Preview Section
                Container(
                  color: colors.primaryContainer.withValues(alpha: 0.03),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPreviewContent(context, provider, colors),
                      const SizedBox(height: 24),
                      _buildActionButtons(context, provider, colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Myprovider provider, ColorScheme colors, double availableHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        children: [
          if (provider.loadterms || provider.loadschool)
            const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT: Form Section
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildFormContent(context, provider, colors, isMobile: false),
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant, thickness: 1.5),
                  // RIGHT: Preview Section
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: colors.primaryContainer.withValues(alpha: 0.03),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildPreviewContent(context, provider, colors),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildActionButtons(context, provider, colors),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, Myprovider provider, ColorScheme colors, {required bool isMobile}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: colors.primary),
              const SizedBox(width: 12),
              const Text("Transaction Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildSectionLabel("Student Selection"),
          const SizedBox(height: 8),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search name or student ID...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (q) => provider.searchStudents(q),
          ),
          
          if (provider.searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = provider.searchResults[index];
                  return ListTile(
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text("${s.studentid} • ${s.level}"),
                    onTap: () {
                      setState(() {
                        selectedStudent = s;
                        provider.emptysearchResults();
                        searchController.text = s.name;
                      });
                    },
                  );
                },
              ),
            ),
          ],

          if (selectedStudent != null) ...[
            const SizedBox(height: 16),
            _buildSelectedStudentTile(selectedStudent!, colors),
          ],

          const SizedBox(height: 32),

          if (isMobile) 
            _buildInputsList(context, provider, colors)
          else 
            _buildInputsGrid(context, provider, colors),
        ],
      ),
    );
  }

  // Grid layout for PC (2 items per row)
  Widget _buildInputsGrid(BuildContext context, Myprovider provider, ColorScheme colors) {
    return Column(
      children: [
        _buildTwoInRow(
          DropdownWidget.buildDropdown(
            dropdownContext: context,
            value: selectedpaymentmethod,
            items: provider.paymethodlist.map((e) => e.name).toList(),
            label: "Payment Method",
            fillColor: colors.surface,
            onChanged: (v) async {
              setState(() {
                selectedpaymentmethod = v;
                selectedLinkedAccount = null;
              });
              if (v != null) await provider.fetchLinkedAccounts(v);
            },
            validatorMsg: 'Required',
          ),
          DropdownWidget.buildDropdown(
            dropdownContext: context,
            value: selectedLinkedAccount,
            items: provider.linkedAccounts.map((acc) => acc["name"]!).toList(),
            label: "Receiving Account",
            fillColor: colors.surface,
            onChanged: (v) => setState(() => selectedLinkedAccount = v),
            validatorMsg: "Required",
          ),
        ),
        const SizedBox(height: 20),
        _buildTwoInRow(
          DropdownWidget.buildDropdown(
            dropdownContext: context,
            value: selectedfee,
            items: provider.fees.map((e) => e.name).toList(),
            label: "Fee Type",
            fillColor: colors.surface,
            onChanged: (v) => setState(() => selectedfee = v),
            validatorMsg: 'Required',
          ),
          provider.loadterms 
            ? const _LoadingDropdown(label: "Academic Term")
            : DropdownWidget.buildDropdown(
                dropdownContext: context,
                value: selectedTerm,
                items: provider.terms.map((e) => e.name).toList(),
                label: "Academic Term",
                fillColor: colors.surface,
                onChanged: (v) => setState(() => selectedTerm = v),
                validatorMsg: "Required",
              ),
        ),
        const SizedBox(height: 20),
        _buildTwoInRow(
          TextFormField(
            controller: amountController,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Amount (GHS)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
          ),
          TextFormField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: "Note / Reference",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
          ),
        ),
      ],
    );
  }

  // Stacked layout for Mobile
  Widget _buildInputsList(BuildContext context, Myprovider provider, ColorScheme colors) {
    return Column(
      children: [
        DropdownWidget.buildDropdown(dropdownContext: context, value: selectedpaymentmethod, items: provider.paymethodlist.map((e) => e.name).toList(), label: "Payment Method", fillColor: colors.surface, onChanged: (v) async { setState(() { selectedpaymentmethod = v; selectedLinkedAccount = null; }); if (v != null) await provider.fetchLinkedAccounts(v); }, validatorMsg: 'Required'),
        const SizedBox(height: 16),
        DropdownWidget.buildDropdown(dropdownContext: context, value: selectedLinkedAccount, items: provider.linkedAccounts.map((acc) => acc["name"]!).toList(), label: "Receiving Account", fillColor: colors.surface, onChanged: (v) => setState(() => selectedLinkedAccount = v), validatorMsg: "Required"),
        const SizedBox(height: 16),
        DropdownWidget.buildDropdown(dropdownContext: context, value: selectedfee, items: provider.fees.map((e) => e.name).toList(), label: "Fee Type", fillColor: colors.surface, onChanged: (v) => setState(() => selectedfee = v), validatorMsg: 'Required'),
        const SizedBox(height: 16),
        provider.loadterms 
          ? const _LoadingDropdown(label: "Academic Term")
          : DropdownWidget.buildDropdown(dropdownContext: context, value: selectedTerm, items: provider.terms.map((e) => e.name).toList(), label: "Academic Term", fillColor: colors.surface, onChanged: (v) => setState(() => selectedTerm = v), validatorMsg: "Required"),
        const SizedBox(height: 16),
        TextFormField(controller: amountController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Amount (GHS)", border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        TextFormField(controller: noteController, decoration: const InputDecoration(labelText: "Note", border: OutlineInputBorder())),
      ],
    );
  }

  Widget _buildPreviewContent(BuildContext context, Myprovider provider, ColorScheme colors) {
    final amount = amountController.text.isEmpty ? "0.00" : amountController.text;
    final balance = selectedStudent?.accounts?['balance'] ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: colors.primary, size: 20),
            const SizedBox(width: 10),
            Text("PAYMENT PREVIEW", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: colors.primary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 32),
        _previewItem("RECIPIENT", selectedStudent?.name ?? "---"),
        _previewItem("STUDENT ID", selectedStudent?.studentid ?? "---"),
        _previewItem("CLASS / LEVEL", selectedStudent?.level ?? "---"),
        _previewItem("CURRENT BALANCE", "GHS ${provider.numberFormat.format(balance)}"),
        _previewItem("ACADEMIC TERM", selectedTerm ?? "---"),
        _previewItem("FEE CATEGORY", selectedfee ?? "---"),
        _previewItem("PAYMENT METHOD", selectedpaymentmethod ?? "---"),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TOTAL PAYABLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            Text("GHS $amount", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.primary)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Myprovider provider, ColorScheme colors) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => _handleSave(context, provider),
            child: const Text("CONFIRM & PROCESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, Routes.feepaymentview),
            icon: const Icon(Icons.history, size: 20),
            label: const Text("VIEW HISTORY", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildTwoInRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));
  }

  Widget _previewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSelectedStudentTile(StudentModel s, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: colors.primary, child: Text(s.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("ID: ${s.studentid} • ${s.level}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => selectedStudent = null)),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, Myprovider provider) async {
    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a student first")));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final progress = ProgressHUD.of(context);
    progress?.show();

    try {
      await provider.generatereceiptnumber();
      String receiptId = provider.receiptno;
      String docId = "${provider.schoolid}_$receiptId";
      
      final data = FeePaymentModel(
        studentId: selectedStudent!.studentid,
        studentName: selectedStudent!.name,
        term: selectedTerm.toString(),
        schoolId: provider.schoolid,
        dateCreated: DateTime.now(),
        paymentmethod: selectedpaymentmethod.toString(),
        receivedaccount: selectedLinkedAccount.toString(),
        note: noteController.text.trim(),
        staff: provider.name,
        staffId: provider.staffid,
        fees: {selectedfee.toString(): double.parse(amountController.text.trim())},
        level: selectedStudent!.level,
        yeargroup: selectedStudent!.yeargroup,
        ledgerid: docId,
        activityType: "Fee Payment",
      );

      await provider.db.collection("feepayment").doc(docId).set(data.toJson());
      
      progress?.dismiss();
      if (context.mounted) {
        _showSuccessDialog(context, provider, data, receiptId);
      }

      amountController.clear();
      noteController.clear();
      searchController.clear();
      setState(() {
        selectedStudent = null;
        selectedfee = null;
        selectedTerm = null;
        selectedpaymentmethod = null;
        selectedLinkedAccount = null;
      });
    } catch (e) {
      progress?.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _showSuccessDialog(BuildContext context, Myprovider provider, FeePaymentModel model, String receiptId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Payment Successful", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("Receipt: $receiptId"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              _printReceipt(provider, model, receiptId);
            },
            icon: const Icon(Icons.print),
            label: const Text("PRINT"),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt(Myprovider val, FeePaymentModel model, String receiptId) async {
    double outstanding = 0;
    double billed = 0;
    double paid = 0;

    // Fetch the latest student balance info
    try {
      final studentDocId = "${val.schoolid}_${model.studentId}".toUpperCase();
      final doc = await val.db.collection("students").doc(studentDocId).get();
      if (doc.exists) {
        final sData = doc.data()!;
        final sAccounts = Map<String, dynamic>.from(sData['accounts'] ?? {});
        billed = (sAccounts['billed'] ?? 0.0).toDouble();
        paid = (sAccounts['paid'] ?? 0.0).toDouble();
        outstanding = (sAccounts['balance'] ?? 0.0).toDouble();
      }
    } catch (e) {
      debugPrint("Error fetching balance for PDF: $e");
    }

    final printer = SchoolReceiptPrinter(
      schoolName: val.currentschool,
      schoolAddress: "BOLGA, UPPER EAST", 
      schoolEmail: "info@kologsoft.com",
      schoolWebsite: "www.kologsoft.com",
      schoolPhone: "+233 553 354 349",
      logoAssetPath: "assets/images/logo.png", 

      date: DateFormat('dd MMM yyyy').format(DateTime.now()),
      receiptNo: receiptId,
      receivedFrom: model.studentName,
      paymentType: model.paymentmethod,
      paymentFor: model.note.isEmpty ? "Fees Payment (${model.term})" : model.note,
      paymentDate: DateFormat('dd MMM yyyy').format(model.dateCreated),
      records: model.fees,
      total: model.fees.values.fold(0.0, (sum, item) => sum + item).toStringAsFixed(2),
      outstandingBalance: val.numberFormat.format(outstanding),
      totalBilled: val.numberFormat.format(billed),
      totalPaid: val.numberFormat.format(paid),
    );

    final pdfBytes = await printer.generatePdf(PdfPageFormat.a4, "Receipt-$receiptId");
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}

class _LoadingDropdown extends StatelessWidget {
  final String label;
  const _LoadingDropdown({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text("Loading $label...", style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
