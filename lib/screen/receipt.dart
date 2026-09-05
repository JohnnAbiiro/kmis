import 'package:flutter/material.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../components/receiptpdf.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class SchoolReceipt extends StatefulWidget {
  const SchoolReceipt({super.key});

  @override
  State<SchoolReceipt> createState() => _SchoolReceiptState();
}

class _SchoolReceiptState extends State<SchoolReceipt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.getdata();
      await provider.myreceipt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<Myprovider>(
      builder: (BuildContext context, val, child) {
        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: colors.surface,
            foregroundColor: colors.onSurface,
            title: const Text("Payment Receipt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: () => _handlePrint(val),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text("PRINT"),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      // Header Section
                      _buildBrandingHeader(val, colors),

                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReceiptTitle(val, colors),
                            const SizedBox(height: 32),
                            _buildInfoGrid(val, colors),
                            const SizedBox(height: 40),
                            _buildItemsTable(val, colors),
                            const SizedBox(height: 32),
                            _buildFinancialSummary(val, colors),
                            const SizedBox(height: 48),
                            _buildFooter(val, colors),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandingHeader(Myprovider val, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.02),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("Logo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(val.currentschool.toUpperCase(), 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colors.primary, letterSpacing: -0.5)),
                  Text("Official Payment Receipt", style: TextStyle(fontSize: 12, color: colors.secondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _headerInfoText("BOLGA, UPPER EAST"),
              _headerInfoText("info@kologsoft.com"),
              _headerInfoText("+233 553 354 349"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfoText(String text) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5));
  }

  Widget _buildReceiptTitle(Myprovider val, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("RECEIPT NO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(val.receiptno, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colors.onSurface, letterSpacing: 1)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("DATE ISSUED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(val.today, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoGrid(Myprovider val, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _infoItem("RECEIVED FROM", val.receiptName, colors),
          const Spacer(),
          _infoItem("PAYMENT METHOD", val.receiptpaymentmethod, colors),
          const Spacer(),
          _infoItem("ACADEMIC TERM", val.term, colors),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildItemsTable(Myprovider val, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PAYMENT BREAKDOWN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FixedColumnWidth(150),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.primary.withOpacity(0.05)),
              children: [
                _tableHeader("Description"),
                _tableHeader("Amount (GHS)", align: TextAlign.right),
              ],
            ),
            ...val.receiptrecords.entries.map((entry) => TableRow(
              children: [
                _tableCell(entry.key),
                _tableCell("GHS ${val.numberFormat.format(entry.value)}", align: TextAlign.right, weight: FontWeight.bold),
              ],
            )),
          ],
        ),
      ],
    );
  }

  Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text.toUpperCase(), 
        textAlign: align, 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _tableCell(String text, {TextAlign align = TextAlign.left, FontWeight weight = FontWeight.normal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(text, 
        textAlign: align, 
        style: TextStyle(fontSize: 13, fontWeight: weight)),
    );
  }

  Widget _buildFinancialSummary(Myprovider val, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("REMARKS / ACADEMIC INFO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(val.receiptnote, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              const Text("PAYMENT STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              if (val.outstandingBalance == 0)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text("ACCOUNT SETTLED", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                )
              else if (val.outstandingBalance > 0)
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text("BALANCE DUE: GHS ${val.numberFormat.format(val.outstandingBalance)}", 
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 340,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _summaryRow("SUBTOTAL PAID", "GHS ${val.numberFormat.format(val.receiptTotal)}", colors, isBold: true, color: colors.primary),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _summaryRow("TOTAL BILLED TO DATE", "GHS ${val.numberFormat.format(val.totalBilled)}", colors),
                _summaryRow("TOTAL PAID TO DATE", "GHS ${val.numberFormat.format(val.totalPaid)}", colors),
                const SizedBox(height: 12),
                if (val.outstandingBalance > 0)
                  _summaryRow("OUTSTANDING BALANCE", "GHS ${val.numberFormat.format(val.outstandingBalance)}", colors, isBold: true, color: Colors.red)
                else if (val.outstandingBalance == 0)
                  _summaryRow("ACCOUNT STATUS", "FULLY PAID", colors, isBold: true, color: Colors.green)
                else
                  _summaryRow("STATUS", "BALANCE PENDING", colors, isBold: true, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, ColorScheme colors, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: colors.secondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color ?? colors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildFooter(Myprovider val, ColorScheme colors) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Generated on ${val.today}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(width: 150, height: 1, color: colors.outline),
                const SizedBox(height: 8),
                const Text("Authorized Signature", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text("This is an official system-generated document.", 
          style: TextStyle(fontSize: 10, color: colors.outline, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Future<void> _handlePrint(Myprovider val) async {
    final printer = SchoolReceiptPrinter(
      schoolName: val.currentschool,
      schoolAddress: "BOLGA, UPPER EAST",
      schoolEmail: "info@kologsoft.com",
      schoolWebsite: "www.kologsoft.com",
      schoolPhone: "+233 553 354 349",
      logoAssetPath: "assets/logo.png",
      date: val.today,
      receiptNo: val.receiptno,
      receivedFrom: val.receiptName,
      paymentType: val.receiptpaymentmethod,
      paymentFor: val.receiptnote,
      paymentDate: val.receiptdate,
      records: val.receiptrecords,
      total: val.numberFormat.format(val.receiptTotal),
      outstandingBalance: val.numberFormat.format(val.outstandingBalance),
      totalBilled: val.numberFormat.format(val.totalBilled),
      totalPaid: val.numberFormat.format(val.totalPaid),
    );

    final pdfBytes = await printer.generatePdf(PdfPageFormat.a4, "School Receipt");
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}
