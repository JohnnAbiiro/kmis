import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../controller/dbmodels/feePaymentModel.dart';
import '../components/receiptpdf.dart';

class FeePaymentView extends StatefulWidget {
  const FeePaymentView({super.key});

  @override
  State<FeePaymentView> createState() => _FeePaymentViewState();
}

class _FeePaymentViewState extends State<FeePaymentView> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7)); // Default to last 7 days
  DateTime endDate = DateTime.now();
  final DateFormat _df = DateFormat("dd MMM yyyy");
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final provider = context.read<Myprovider>();
    await provider.getdata();
    final startOfRange = DateTime(startDate.year, startDate.month, startDate.day);
    await provider.fetchFeePayment(startDate: startOfRange, endDate: endDate);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      saveText: "CHECK",
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
              maxHeight: 550,
            ),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      final provider = context.read<Myprovider>();
      final startOfRange = DateTime(startDate.year, startDate.month, startDate.day);
      await provider.fetchFeePayment(startDate: startOfRange, endDate: endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, val, child) {
          final filteredPayments = val.feepaymentlist.where((payment) {
            final query = searchQuery.toLowerCase();
            return payment.studentName.toLowerCase().contains(query) || 
                   payment.studentId.toLowerCase().contains(query) ||
                   payment.ledgerid.toLowerCase().contains(query);
          }).toList();

          double totalReceived = filteredPayments.fold(0.0, (sum, item) => sum + item.fees.values.fold(0.0, (s, f) => s + f));

          return Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            appBar: AppBar(
              title: _isSearching 
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Search name, ID or receipt...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (val) => setState(() => searchQuery = val),
                  )
                : const Text("Payment Records", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              elevation: 0,
              actions: [
                if (!_isSearching) ...[
                  ActionChip(
                    avatar: Icon(Icons.calendar_today, size: 16, color: colors.primary),
                    label: Text("${_df.format(startDate)} - ${_df.format(endDate)}", 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary)),
                    onPressed: () => _selectDateRange(context),
                    backgroundColor: colors.primaryContainer.withOpacity(0.2),
                    side: BorderSide(color: colors.primary.withOpacity(0.2)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _isSearching = true),
                    icon: const Icon(Icons.search_rounded),
                    tooltip: "Search",
                  ),
                  IconButton(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: "Refresh",
                  ),
                ] else
                  IconButton(
                    onPressed: () => setState(() {
                      _isSearching = false;
                      searchQuery = "";
                      _searchController.clear();
                    }),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: "Close Search",
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: filteredPayments.isEmpty
                      ? _buildEmptyState(colors)
                      : _buildPaymentsTable(context, filteredPayments, val, colors, totalReceived),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildPaymentsTable(BuildContext context, List<FeePaymentModel> payments, Myprovider val, ColorScheme colors, double total) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
            headingRowColor: WidgetStateProperty.all(colors.surfaceContainerHigh),
            dataRowMaxHeight: 70,
            horizontalMargin: 24,
            columnSpacing: 40,
            columns: [
              _buildColumn("Date"),
              _buildColumn("Student"),
              _buildColumn("Receipt No"),
              _buildColumn("Category"),
              _buildColumn("Method"),
              _buildColumn("Amount (GHS)", numeric: true),
              _buildColumn("Actions"),
            ],
            rows: [
              ...payments.map((payment) {
                final double amount = payment.fees.values.fold(0.0, (sum, val) => sum + val);
                return DataRow(
                  cells: [
                    DataCell(Text(DateFormat("dd MMM, HH:mm").format(payment.dateCreated), style: const TextStyle(fontSize: 13))),
                    DataCell(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(payment.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(payment.studentId, style: TextStyle(fontSize: 11, color: colors.secondary)),
                      ],
                    )),
                    DataCell(Text(payment.ledgerid.split('_').last, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                    DataCell(Text(payment.fees.keys.join(", "), style: const TextStyle(fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(payment.paymentmethod, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.onSecondaryContainer)),
                    )),
                    DataCell(Text(val.numberFormat.format(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.print_outlined, size: 18, color: colors.primary),
                          onPressed: () => _printReceipt(context, val, payment),
                          tooltip: "Print",
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () => _handleDelete(context, val, payment),
                          tooltip: "Delete",
                        ),
                      ],
                    )),
                  ],
                );
              }),
              // Total Row at the bottom
              DataRow(
                color: WidgetStateProperty.all(colors.primaryContainer.withOpacity(0.1)),
                cells: [
                  const DataCell(Text("")),
                  const DataCell(Text("")),
                  const DataCell(Text("")),
                  const DataCell(Text("")),
                  DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text("TOTAL:", style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 12)),
                  )),
                  DataCell(Text(val.numberFormat.format(total), 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: colors.primary))),
                  const DataCell(Text("")),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  DataColumn _buildColumn(String label, {bool numeric = false}) {
    return DataColumn(
      numeric: numeric,
      label: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payments_outlined, size: 64, color: colors.outlineVariant),
          const SizedBox(height: 16),
          Text("No payments found for this range", style: TextStyle(color: colors.outline, fontSize: 16)),
          const SizedBox(height: 8),
          TextButton(onPressed: _refreshData, child: const Text("Clear Filters")),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Myprovider val, FeePaymentModel payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("This will permanently remove the payment record and reverse the student's balance. Continue?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete Record")
          ),
        ],
      ),
    );

    if (confirm == true) {
      final progress = ProgressHUD.of(context);
      progress?.show();
      try {
        await val.voidFeePayment(payment, val.name);
        await _refreshData();
      } finally {
        progress?.dismiss();
      }
    }
  }

  Future<void> _printReceipt(BuildContext context, Myprovider val, FeePaymentModel model) async {
    final receiptId = model.ledgerid.split('_').last;
    
    double outstanding = 0;
    double billed = 0;
    double paid = 0;

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
