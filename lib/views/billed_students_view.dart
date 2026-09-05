import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/ledgerModel.dart';
import '../controller/myprovider.dart';
import '../screen/ledgerReport.dart';

class BilledStudentsView extends StatefulWidget {
  final String billedId;
  final String feeName;

  const BilledStudentsView({super.key, required this.billedId, required this.feeName});

  @override
  State<BilledStudentsView> createState() => _BilledStudentsViewState();
}

class _BilledStudentsViewState extends State<BilledStudentsView> {
  List<LedgerTransaction> _billedTransactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final provider = context.read<Myprovider>();
    final snap = await provider.db.collection('ledger').where('billedId', isEqualTo: widget.billedId).get();
    
    setState(() {
      _billedTransactions = snap.docs.map((doc) => LedgerTransaction.fromFirestore(doc.id, doc.data())).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Students Billed: ${widget.feeName}"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _billedTransactions.isEmpty
              ? const Center(child: Text("No student records found for this billing"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(colors.surfaceContainerHigh),
                        columns:  [
                          DataColumn(label: Text("STUDENT ID")),
                          DataColumn(label: Text("STUDENT NAME")),
                          DataColumn(label: Text("AMOUNT (GHS)")),
                        ],
                        rows: _billedTransactions.map((tx) {
                          return DataRow(cells: [
                            DataCell(Text(tx.studentId)),
                            DataCell(Text(tx.studentName)),
                            DataCell(Text(NumberFormat("#,##0.00").format(tx.debitValue))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}
