
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../components/appColors.dart';
import '../controller/myprovider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../controller/dbmodels/ledgerModel.dart';
import '../controller/routes.dart';

class DailyLedgerReportView extends StatefulWidget {
  const DailyLedgerReportView({super.key});

  @override
  State<DailyLedgerReportView> createState() => _DailyLedgerReportViewState();
}

class _DailyLedgerReportViewState extends State<DailyLedgerReportView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalController = ScrollController();

  List<LedgerTransaction> _allTransactions = [];
  List<LedgerAccountSummary> _accountSummaries = [];
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  
  bool _loading = true;
  String? _error;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day, 0, 0, 0);
    _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59, 999);
    
    _searchController.addListener(_rebuildReport);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLedger();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_rebuildReport);
    _searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _loadLedger() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<Myprovider>(context, listen: false);
      if (provider.schoolid.isEmpty) {
        await provider.getdata();
      }
      final schoolId = provider.schoolid;

      if (schoolId.isEmpty) {
        throw Exception('School ID is empty. Please login again.');
      }

      final snapshot = await provider.db
          .collection('ledger')
          .where('schoolId', isEqualTo: schoolId)
          .get();

      final List<LedgerTransaction> transactions = [];
      for (final doc in snapshot.docs) {
        try {
          transactions.add(LedgerTransaction.fromFirestore(doc.id, doc.data()));
        } catch (e) {
          debugPrint('Skipping invalid ledger document ${doc.id}: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _allTransactions = transactions;
        _loading = false;
      });
      _rebuildReport();
    } catch (e) {
      debugPrint('Ledger loading error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _rebuildReport() {
    final query = _searchController.text.trim().toLowerCase();
    final accounts = <String, LedgerAccountSummary>{};

    for (final tx in _allTransactions) {
      // Debit side
      if (tx.debitAccount.isNotEmpty) {
        final summary = accounts.putIfAbsent(
          tx.debitAccount,
          () => LedgerAccountSummary(
            account: tx.debitAccount,
            accountClass: tx.debitAccountClass,
            subClass: tx.debitSubClass,
          ),
        );
        
        if (tx.createdAt.isBefore(_startDate)) {
          summary.openingDebit += tx.debitValue;
        } else if (tx.createdAt.isAfter(_startDate.subtract(const Duration(microseconds: 1))) &&
            tx.createdAt.isBefore(_endDate)) {
          summary.debit += tx.debitValue;
          summary.transactions.add(tx);
        }
      }

      // Credit side
      if (tx.creditAccount.isNotEmpty) {
        final summary = accounts.putIfAbsent(
          tx.creditAccount,
          () => LedgerAccountSummary(
            account: tx.creditAccount,
            accountClass: tx.creditAccountClass,
            subClass: tx.creditSubClass,
          ),
        );

        if (tx.createdAt.isBefore(_startDate)) {
          summary.openingCredit += tx.creditValue;
        } else if (tx.createdAt.isAfter(_startDate.subtract(const Duration(microseconds: 1))) &&
            tx.createdAt.isBefore(_endDate)) {
          summary.credit += tx.creditValue;
          summary.transactions.add(tx);
        }
      }
    }

    List<LedgerAccountSummary> summaries = accounts.values.toList();
    
    // Apply search filter
    if (query.isNotEmpty) {
      summaries = summaries.where((a) => a.account.toLowerCase().contains(query) || a.accountClass.toLowerCase().contains(query)).toList();
    }

    summaries.sort((a, b) => a.account.toLowerCase().compareTo(b.account.toLowerCase()));

    if (!mounted) return;
    setState(() {
      _accountSummaries = summaries;
    });
  }

  Future<void> _selectDateRange() async {
    await showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStart = _startDate;
        DateTime? tempEnd = _endDate;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date Range', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    tempStart == null
                        ? 'Select start date'
                        : '${DateFormat('dd MMM yyyy').format(tempStart!)} - ${tempEnd == null ? '...' : DateFormat('dd MMM yyyy').format(tempEnd!)}',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                height: 350,
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(_startDate, _endDate),
                  maxDate: DateTime.now(),
                  onSelectionChanged: (args) {
                    if (args.value is PickerDateRange) {
                      setDialogState(() {
                        tempStart = args.value.startDate;
                        tempEnd = args.value.endDate;
                      });
                    }
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (tempStart != null) {
                      setState(() {
                        _startDate = DateTime(tempStart!.year, tempStart!.month, tempStart!.day, 0, 0, 0);
                        _endDate = DateTime(tempEnd?.year ?? tempStart!.year, tempEnd?.month ?? tempStart!.month, tempEnd?.day ?? tempStart!.day, 23, 59, 59, 999);
                      });
                      _rebuildReport();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _printReport() async {
    if (_accountSummaries.isEmpty) return;
    
    final pdf = await DailyLedgerPdfService.buildDailyReportPdf(
      accounts: _accountSummaries,
      startDate: _startDate,
      endDate: _endDate,
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf,
      name: 'Daily Ledger Report ${DateFormat('dd-MM-yyyy').format(_startDate)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldcolor,
      appBar: AppBar(
        backgroundColor: Constants.appbarcolor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(Routes.dashboard),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search account...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Ledger Report', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(
                    '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: _printReport,
            tooltip: 'Print Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLedger,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return _buildMobileView();
        }
        return _buildDesktopView();
      },
    );
  }

  Widget _buildDesktopView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Opening Balance'), numeric: true),
                      DataColumn(label: Text('Debit'), numeric: true),
                      DataColumn(label: Text('Credit'), numeric: true),
                      DataColumn(label: Text('Closing Balance'), numeric: true),
                    ],
                    rows: _accountSummaries.map((a) => DataRow(
                      onSelectChanged: (_) => _showAccountDetails(a),
                      cells: [
                        DataCell(Text(a.account, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(money(a.openingBalance))),
                        DataCell(Text(money(a.debit))),
                        DataCell(Text(money(a.credit))),
                        DataCell(Text(money(a.closingBalance), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _accountSummaries.length,
            itemBuilder: (context, index) {
              final a = _accountSummaries[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => _showAccountDetails(a),
                  title: Text(a.account, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Opening:'),
                          Text(money(a.openingBalance)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Debit / Credit:'),
                          Text('${money(a.debit)} / ${money(a.credit)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Closing Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(money(a.closingBalance), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAccountDetails(LedgerAccountSummary account) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyLedgerAccountDetailsView(
          account: account,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );
  }

  String money(double value) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }
}

class DailyLedgerAccountDetailsView extends StatelessWidget {
  final LedgerAccountSummary account;
  final DateTime startDate;
  final DateTime endDate;

  const DailyLedgerAccountDetailsView({
    super.key,
    required this.account,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final transactions = List<LedgerTransaction>.from(account.transactions);
    transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final List<double> runningBalances = [];
    double currentBalance = account.openingBalance;
    
    for (var tx in transactions) {
      final isDebit = tx.debitAccount == account.account;
      if (account.isDebitNormal) {
        currentBalance += isDebit ? tx.debitValue : -tx.creditValue;
      } else {
        currentBalance += !isDebit ? tx.creditValue : -tx.debitValue;
      }
      runningBalances.add(currentBalance);
    }

    return Scaffold(
      backgroundColor: Constants.scaffoldcolor,
      appBar: AppBar(
        backgroundColor: Constants.appbarcolor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.account, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _printAccountDetail(context, transactions, runningBalances),
            tooltip: 'Print Detail',
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Column(
          children: [
            _buildDetailSummary(isDesktop),
            Expanded(
              child: isDesktop
                  ? _buildDesktopDetails(transactions, runningBalances)
                  : _buildMobileDetails(transactions, runningBalances),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailSummary(bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Opening Balance', money(account.openingBalance)),
              _summaryItem('Debit', money(account.debit)),
              _summaryItem('Credit', money(account.credit)),
              _summaryItem('Closing Balance', money(account.closingBalance), isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }

  Widget _buildDesktopDetails(List<LedgerTransaction> transactions, List<double> balances) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Activity')),
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('Note')),
                DataColumn(label: Text('Debit'), numeric: true),
                DataColumn(label: Text('Credit'), numeric: true),
                DataColumn(label: Text('Balance'), numeric: true),
              ],
              rows: [
                DataRow(
                  color: WidgetStateProperty.all(Colors.blue.withOpacity(0.05)),
                  cells: [
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(startDate.subtract(const Duration(days: 1))), style: const TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('OPENING BALANCE', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('-')),
                    const DataCell(Text('-')),
                    const DataCell(Text('-')),
                    const DataCell(Text('-')),
                    DataCell(Text(money(account.openingBalance), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  ],
                ),
                ...List.generate(transactions.length, (index) {
                  final tx = transactions[index];
                  final bal = balances[index];
                  final isDebit = tx.debitAccount == account.account;
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt))),
                    DataCell(Text(tx.activityType)),
                    DataCell(Text(tx.studentName.isNotEmpty ? '${tx.studentName} (${tx.studentId})' : '-')),
                    DataCell(Text(tx.note.isNotEmpty ? tx.note : '-')),
                    DataCell(Text(isDebit ? money(tx.debitValue) : '-')),
                    DataCell(Text(!isDebit ? money(tx.creditValue) : '-')),
                    DataCell(Text(money(bal), style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDetails(List<LedgerTransaction> transactions, List<double> balances) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.blue.shade50,
          elevation: 0,
          child: ListTile(
            title: const Text('OPENING BALANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('As of ${DateFormat('dd MMM yyyy').format(startDate.subtract(const Duration(days: 1)))}'),
            trailing: Text(money(account.openingBalance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(transactions.length, (index) {
          final tx = transactions[index];
          final bal = balances[index];
          final isDebit = tx.debitAccount == account.account;
          final amount = isDebit ? tx.debitValue : tx.creditValue;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDebit ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isDebit ? 'DEBIT' : 'CREDIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDebit ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(tx.activityType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (tx.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(tx.note, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                  if (tx.studentName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Student: ${tx.studentName} (${tx.studentId})', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(money(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Running Balance', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(money(bal), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _printAccountDetail(BuildContext context, List<LedgerTransaction> transactions, List<double> balances) async {
    final pdf = await DailyLedgerPdfService.buildAccountDetailPdf(
      account: account,
      startDate: startDate,
      endDate: endDate,
      transactions: transactions,
      balances: balances,
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf,
      name: 'Ledger_${account.account}_${DateFormat('dd-MM-yyyy').format(startDate)}',
    );
  }

  String money(double value) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }
}

class DailyLedgerPdfService {
  static Future<Uint8List> buildDailyReportPdf({
    required List<LedgerAccountSummary> accounts,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat('#,##0.00');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Daily Ledger Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Account', 'Opening Balance', 'Debit', 'Credit', 'Closing Balance'],
            data: accounts.map((a) => [
              a.account,
              formatter.format(a.openingBalance),
              formatter.format(a.debit),
              formatter.format(a.credit),
              formatter.format(a.closingBalance),
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
            },
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> buildAccountDetailPdf({
    required LedgerAccountSummary account,
    required DateTime startDate,
    required DateTime endDate,
    required List<LedgerTransaction> transactions,
    required List<double> balances,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat('#,##0.00');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Account Ledger Detail', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('Account: ${account.account}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  'Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text('Opening: ${formatter.format(account.openingBalance)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Debit: ${formatter.format(account.debit)}'),
              pw.Text('Total Credit: ${formatter.format(account.credit)}'),
              pw.Text('Closing: ${formatter.format(account.closingBalance)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Activity', 'Student', 'Note', 'Debit', 'Credit', 'Balance'],
            data: [
              [
                DateFormat('dd/MM/yyyy').format(startDate.subtract(const Duration(days: 1))),
                'OPENING BALANCE',
                '-',
                '-',
                '-',
                '-',
                formatter.format(account.openingBalance),
              ],
              ...List.generate(transactions.length, (index) {
                final tx = transactions[index];
                final bal = balances[index];
                final isDebit = tx.debitAccount == account.account;
                return [
                  DateFormat('dd/MM/yy HH:mm').format(tx.createdAt),
                  tx.activityType,
                  tx.studentName.isNotEmpty ? '${tx.studentName} (${tx.studentId})' : '-',
                  tx.note.isNotEmpty ? tx.note : '-',
                  isDebit ? formatter.format(tx.debitValue) : '-',
                  !isDebit ? formatter.format(tx.creditValue) : '-',
                  formatter.format(bal),
                ];
              }),
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
