
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/appColors.dart';
import '../controller/myprovider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../controller/routes.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class LedgerReportPage extends StatefulWidget {
const LedgerReportPage({super.key});

@override
State<LedgerReportPage> createState() => _LedgerReportPageState();
}

class _LedgerReportPageState extends State<LedgerReportPage> {
final TextEditingController _searchController =
TextEditingController();

final ScrollController _horizontalController =
ScrollController();

List<LedgerTransaction> _allTransactions = [];

List<LedgerTransaction> _filteredTransactions = [];

List<LedgerAccountSummary> _accountSummaries = [];

DateTime _selectedDate = DateTime.now();

bool _loading = true;

String? _error;

DateTime _startDate = DateTime.now();
DateTime _endDate = DateTime.now();
Widget _exportButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(
      icon,
      size: 15,
    ),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF315CF6),
      side: const BorderSide(
        color: Color(0xFFD0D5DD),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}


Future<void> _exportFullReport() async {
  if (_accountSummaries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('There is no data to export.'),
      ),
    );
    return;
  }

  final bytes =
  await LedgerPdfService.buildLedgerReportPdf(
    accounts: _accountSummaries,
    startDate: _startDate,
    endDate: _endDate,
  );

  await Printing.layoutPdf(
    onLayout: (_) async => bytes,
  );
}

Future<void> _printFullReport() async {
  if (_accountSummaries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('There is no data to print.'),
      ),
    );
    return;
  }

  final bytes =
  await LedgerPdfService.buildLedgerReportPdf(
    accounts: _accountSummaries,
    startDate: _startDate,
    endDate: _endDate,
  );

  await Printing.layoutPdf(
    onLayout: (_) async => bytes,
    name: 'Ledger Report',
  );
}


@override
void initState() {
super.initState();

_searchController.addListener(_onSearchChanged);

WidgetsBinding.instance.addPostFrameCallback((_) {
_loadLedger();
});
}

@override
void dispose() {
_searchController.removeListener(_onSearchChanged);
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
final provider =
Provider.of<Myprovider>(context, listen: false);

final schoolId = provider.schoolid;

if (schoolId.isEmpty) {
throw Exception('School ID is empty.');
}

final snapshot = await provider.db.collection('ledger') .where('schoolId', isEqualTo: schoolId,).get();

final List<LedgerTransaction> transactions = [];

for (final doc in snapshot.docs) {
try {
final transaction = LedgerTransaction.fromFirestore(
doc.id,
doc.data(),
);
print('Loaded transaction: ${transaction.debitAccount} -> ${transaction.creditAccount}, Amount: ${transaction.debitValue}');
transactions.add(transaction);
} catch (e) {
debugPrint(
'Skipping invalid ledger document ${doc.id}: $e',
);
}
}

if (!mounted) return;

setState(() {
_allTransactions = transactions;
_filteredTransactions = List.from(transactions);
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

// =============================================================
// SEARCH
// =============================================================

void _onSearchChanged() {
_applyFilters();
}

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    final results = _allTransactions.where((transaction) {
      // ─────────────────────────────────────────────
      // 1. DATE RANGE FILTER
      // ─────────────────────────────────────────────
      final date = transaction.createdAt;

      final matchesDate =
          !date.isBefore(_startDate) &&
              !date.isAfter(_endDate);

      if (!matchesDate) {
        return false;
      }

      // ─────────────────────────────────────────────
      // 2. SEARCH FILTER
      // ─────────────────────────────────────────────
      if (query.isEmpty) {
        return true;
      }

      return transaction.debitAccount
          .toLowerCase()
          .contains(query) ||
          transaction.creditAccount
              .toLowerCase()
              .contains(query) ||
          transaction.debitAccountClass
              .toLowerCase()
              .contains(query) ||
          transaction.creditAccountClass
              .toLowerCase()
              .contains(query) ||
          transaction.studentName
              .toLowerCase()
              .contains(query) ||
          transaction.studentId
              .toLowerCase()
              .contains(query) ||
          transaction.feeName
              .toLowerCase()
              .contains(query) ||
          transaction.activityType
              .toLowerCase()
              .contains(query) ||
          transaction.staff
              .toLowerCase()
              .contains(query) ||
          transaction.transactionId
              .toLowerCase()
              .contains(query) ||
          transaction.billedId
              .toLowerCase()
              .contains(query) ||
          transaction.note
              .toLowerCase()
              .contains(query);
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredTransactions = results;
    });

    // Rebuild account totals based on the filtered results.
    _rebuildReport();
  }
void _rebuildReport() {
final accounts =
<String, LedgerAccountSummary>{};

final startOfSelectedDate = DateTime(
_selectedDate.year,
_selectedDate.month,
_selectedDate.day,
);

final endOfSelectedDate =
startOfSelectedDate.add(
const Duration(days: 1),
);

for (final transaction in _filteredTransactions) {
// ---------------------------------------------------------
// DEBIT SIDE
// ---------------------------------------------------------

if (transaction.debitAccount.isNotEmpty) {
final key = transaction.debitAccount;

final summary = accounts.putIfAbsent(
key,
() => LedgerAccountSummary(
account: transaction.debitAccount,
accountClass:
transaction.debitAccountClass,
subClass:
transaction.debitSubClass,
),
);

final amount = transaction.debitValue;

if (transaction.createdAt
    .isBefore(startOfSelectedDate)) {
summary.openingDebit += amount;
} else if (transaction.createdAt
    .isAfter(
startOfSelectedDate.subtract(
const Duration(microseconds: 1),
),
) &&
transaction.createdAt
    .isBefore(endOfSelectedDate)) {
summary.debit += amount;
summary.transactions.add(transaction);
}
}

// ---------------------------------------------------------
// CREDIT SIDE
// ---------------------------------------------------------

if (transaction.creditAccount.isNotEmpty) {
final key = transaction.creditAccount;

final summary = accounts.putIfAbsent(
key,
() => LedgerAccountSummary(
account: transaction.creditAccount,
accountClass:
transaction.creditAccountClass,
subClass:
transaction.creditSubClass,
),
);

final amount = transaction.creditValue;

if (transaction.createdAt
    .isBefore(startOfSelectedDate)) {
summary.openingCredit += amount;
} else if (transaction.createdAt
    .isAfter(
startOfSelectedDate.subtract(
const Duration(microseconds: 1),
),
) &&
transaction.createdAt
    .isBefore(endOfSelectedDate)) {
summary.credit += amount;
summary.transactions.add(transaction);
}
}
}

final summaries = accounts.values.toList();

summaries.sort(
(a, b) => a.account
    .toLowerCase()
    .compareTo(
b.account.toLowerCase(),
),
);

if (!mounted) return;

setState(() {
_accountSummaries = summaries;
});
}

void _setToday() {
setState(() {
_selectedDate = DateTime.now();
});

_rebuildReport();
}

void _setYesterday() {
final yesterday =
DateTime.now().subtract(
const Duration(days: 1),
);

setState(() {
_selectedDate = yesterday;
});

_rebuildReport();
}


double get _totalOpening {
return _accountSummaries.fold(
0,
(sum, account) =>
sum + account.openingBalance,
);
}

double get _totalDebit {
return _accountSummaries.fold(
0,
(sum, account) =>
sum + account.debit,
);
}

double get _totalCredit {
return _accountSummaries.fold(
0,
(sum, account) =>
sum + account.credit,
);
}

double get _totalClosing {
return _accountSummaries.fold(
0,
(sum, account) =>
sum + account.closingBalance,
);
}

// =============================================================
// ACCOUNT DETAIL
// =============================================================

void _openAccount(
LedgerAccountSummary account,
) {
Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => LedgerAccountDetailsPage(
account: account,
selectedDate: _selectedDate,
),
),
);
}

// =============================================================
// CLEAR SEARCH
// =============================================================

void _clearSearch() {
_searchController.clear();
}

// =============================================================
// BUILD
// =============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Constants.scaffoldcolor,
appBar: _buildAppBar(),
body: _loading
? const _LoadingView()
    : _error != null
? _ErrorView(
error: _error!,
onRetry: _loadLedger,
)
    : _buildBody(),
);
}

// =============================================================
// APP BAR
// =============================================================

PreferredSizeWidget _buildAppBar() {
return AppBar(
backgroundColor:Constants.appbarcolor,
surfaceTintColor: Colors.white,
elevation: 0,
toolbarHeight: 72,
leading: IconButton(
  color: Constants.whitetext,
tooltip: 'Back',
onPressed: () {
      context.go(Routes.dashboard);
          },
icon: const Icon(
Icons.arrow_back_rounded,
color: Constants.whitetext,
),
),
title: Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Color(0xFF315CF6),
Color(0xFF5278FF),
],
),
borderRadius:
BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: const Color(0xFF315CF6)
    .withOpacity(.16),
blurRadius: 12,
offset: const Offset(0, 5),
),
],
),
child: const Icon(
Icons.account_balance_rounded,
color: Colors.white,
size: 21,
),
),
const SizedBox(width: 12),
const Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Ledger Report',
style: TextStyle(
color: Constants.whitetext,
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
SizedBox(height: 3),
],
),
],
),
actions: [
IconButton(
tooltip: 'Refresh',
onPressed: _loadLedger,
icon: const Icon(
Icons.refresh_rounded,
color: Color(0xFF475467),
),
),
const SizedBox(width: 8),
],
);
}

// =============================================================
// BODY
// =============================================================

Widget _buildBody() {
return LayoutBuilder(
builder: (context, constraints) {
final width = constraints.maxWidth;

if (width < 700) {
return _buildMobileBody();
}

return _buildDesktopBody(width);
},
);
}

// =============================================================
// DESKTOP BODY
// =============================================================

Widget _buildDesktopBody(double width) {
return SingleChildScrollView(
padding: EdgeInsets.all(
width >= 1200 ? 28 : 20,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const SizedBox(height: 5),
_buildFilters(),
const SizedBox(height: 24),
_buildDesktopAccountTable(),
],
),
);
}

// =============================================================
// MOBILE BODY
// =============================================================

Widget _buildMobileBody() {
return RefreshIndicator(
color: const Color(0xFF315CF6),
onRefresh: _loadLedger,
child: ListView(
padding: const EdgeInsets.all(16),
children: [
const SizedBox(height: 16),
_buildMobileFilters(),
_buildMobileAccounts(),
],
),
);
}


Widget _buildAccountCount() {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 13,
vertical: 9,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(10),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Row(
children: [
const Icon(
Icons.account_balance_wallet_outlined,
size: 16,
color: Color(0xFF315CF6),
),
const SizedBox(width: 7),
Text(
'${_accountSummaries.length} Accounts',
style: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.w700,
color: Color(0xFF344054),
),
),
],
),
);
}

// =============================================================
// FILTERS DESKTOP
// =============================================================

Widget _buildFilters() {
return Center( child:
ConstrainedBox( constraints:
const BoxConstraints( minWidth: 0, maxWidth: 900, ),
    child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Row(
children: [
_dateButton(),
const SizedBox(width: 8),
_quickDateButton(
label: 'Today',
onTap: _setToday,
),
const SizedBox(width: 6),
_quickDateButton(
label: 'Yesterday',
onTap: _setYesterday,
),
const SizedBox(width: 16),
Container(
height: 34,
width: 1,
color: const Color(0xFFE4E7EC),
),
const SizedBox(width: 16),
Expanded(
child: _searchField(),
),
if (_searchController.text.isNotEmpty) ...[
const SizedBox(width: 8),
IconButton(
tooltip: 'Clear search',
onPressed: _clearSearch,
icon: const Icon(
Icons.close_rounded,
size: 19,
),
),
],
],
),
)));
}

// =============================================================
// FILTERS MOBILE
// =============================================================

Widget _buildMobileFilters() {
return Column(
children: [
_searchField(),
const SizedBox(height: 10),
Row(
children: [
Expanded(
child: _dateButton(),
),
const SizedBox(width: 8),
_quickDateButton(
label: 'Today',
onTap: _setToday,
),
],
),
const SizedBox(height: 8),
Row(
children: [
Expanded(
child: _quickDateButton(
label: 'Yesterday',
onTap: _setYesterday,
expanded: true,
),
),
],
),
],
);
}

// =============================================================
// DATE BUTTON
// =============================================================


  Future<void> _selectDateRange() async {
    DateTimeRange? result;

    await showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStart = _startDate;
        DateTime? tempEnd = _endDate;

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            4,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            14,
          ),
          title: const Text(
            'Select Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
          content: SizedBox(
            width: 360,
            height: 350,
            child: SfDateRangePicker(
              selectionMode:
              DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                _startDate,
                _endDate,
              ),
              maxDate: DateTime.now(),
              showActionButtons: false,
              selectionColor:
              const Color(0xFF315CF6),
              startRangeSelectionColor:
              const Color(0xFF315CF6),
              endRangeSelectionColor:
              const Color(0xFF315CF6),
              rangeSelectionColor:
              const Color(0xFFEFF2FF),
              todayHighlightColor:
              const Color(0xFF315CF6),
              headerStyle:
              const DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101828),
                ),
              ),
              monthViewSettings:
              const DateRangePickerMonthViewSettings(
                firstDayOfWeek: 1,
              ),
              onSelectionChanged:
                  (DateRangePickerSelectionChangedArgs args) {
                final value = args.value;

                if (value is PickerDateRange) {
                  tempStart = value.startDate;
                  tempEnd = value.endDate;
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempStart == null) return;

                result = DateTimeRange(
                  start: tempStart!,
                  end: tempEnd ?? tempStart!,
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF315CF6),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      _startDate = DateTime(
        result!.start.year,
        result!.start.month,
        result!.start.day,
      );

      _endDate = DateTime(
        result!.end.year,
        result!.end.month,
        result!.end.day,
        23,
        59,
        59,
        999,
      );
    });

    _applyFilters();
  }


  Widget _dateButton() {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD0D5DD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: Color(0xFF315CF6),
            ),

            const SizedBox(width: 8),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(_startDate),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF344054),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Color(0xFF98A2B3),
              ),
            ),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(_endDate),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF344054),
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF667085),
            ),
          ],
        ),
      ),
    );
  }


// =============================================================
// QUICK DATE BUTTON
// =============================================================

Widget _quickDateButton({
required String label,
required VoidCallback onTap,
bool expanded = false,
}) {
return InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(9),
child: Container(
height: 44,
width: expanded ? double.infinity : null,
padding: const EdgeInsets.symmetric(
horizontal: 13,
),
alignment: Alignment.center,
decoration: BoxDecoration(
color: const Color(0xFFEFF2FF),
borderRadius:
BorderRadius.circular(9),
),
child: Text(
label,
style: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.w700,
color: Color(0xFF315CF6),
),
),
),
);
}

// =============================================================
// SEARCH
// =============================================================

Widget _searchField() {
return Container(
height: 44,
decoration: BoxDecoration(
color: const Color(0xFFF8F9FC),
borderRadius:
BorderRadius.circular(10),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: TextField(
controller: _searchController,
decoration: const InputDecoration(
border: InputBorder.none,
prefixIcon: Icon(
Icons.search_rounded,
size: 19,
color: Color(0xFF98A2B3),
),
hintText:
'Search account, student, fee, staff...',
hintStyle: TextStyle(
fontSize: 11,
color: Color(0xFF98A2B3),
),
contentPadding:
EdgeInsets.symmetric(
vertical: 13,
),
),
style: const TextStyle(
fontSize: 11.5,
color: Color(0xFF344054),
fontWeight: FontWeight.w600,
),
),
);
}


Widget _buildDesktopAccountTable() {
if (_accountSummaries.isEmpty) {
return const _EmptyView();
}

return Center(
  child:
  ConstrainedBox(
  constraints: const BoxConstraints(
    minWidth: 0,
    maxWidth: 950,
  ),child:
  Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child:Column(
children: [
  Container(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F7FF),
      border: Border(
        bottom: BorderSide(
          color: const Color(0xFFE0E7FF),
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 19,
            color: Color(0xFF4F46E5),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ledger Accounts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Constants.bgDark,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Click an account to view transaction details',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Constants.tableheader,
                ),
              ),
              child: Text(
                '${_accountSummaries.length} accounts',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475467),
                ),
              ),
            ),

            const SizedBox(width: 8),

            _exportButton(
              icon: Icons.print_outlined,
              label: 'Print',
              onPressed: _printFullReport,
            ),

            const SizedBox(width: 6),

            _exportButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'PDF',
              onPressed: _exportFullReport,
            ),
          ],
        )      ],
    ),
  ),const Divider(
height: 1,
color: Color(0xFFE4E7EC),
),
Scrollbar(
controller:
_horizontalController,
thumbVisibility: true,
child: SingleChildScrollView(
controller:
_horizontalController,
scrollDirection:
Axis.horizontal,
child: DataTable(
headingRowHeight: 46,
dataRowMinHeight: 40,
dataRowMaxHeight: 45,
columnSpacing: 30,
horizontalMargin: 45,
headingTextStyle:
const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w800,
color: Color(0xFF667085),
),
columns: const [
DataColumn(
label: Text('ACCOUNT'),
),
DataColumn(
label: Text('CLASS'),
),
DataColumn(
label: Text('OPENING'),
numeric: true,
),
DataColumn(
label: Text('DEBIT'),
//(GH₵)
numeric: true,
),
DataColumn(
label: Text('CREDIT'),
numeric: true,
),
DataColumn(
label: Text('BALANCE'),
numeric: true,
),
DataColumn(
label: Text(''),
),
],
rows: _accountSummaries
    .map(
(account) =>
_buildAccountRow(
account,
),
)
    .toList(),
),
),
),
],
),
)));
}

DataRow _buildAccountRow(
LedgerAccountSummary account,
) {
return DataRow(
onSelectChanged: (_) {
_openAccount(account);
},
cells: [
DataCell(
SizedBox(
width: 190,
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
account.account,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 11.5,
fontWeight:
FontWeight.w800,
color:
Color(0xFF101828),
),
),
const SizedBox(height: 3),
Text(
account.subClass,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 9,
color:
Color(0xFF98A2B3),
),
),
],
),
),
),
DataCell(
_classBadge(
account.accountClass,
),
),
DataCell(
_amountText(
account.openingBalance,
),
),
DataCell(
_amountText(
account.debit,
),
),
DataCell(
_amountText(
account.credit,
),
),
DataCell(
_balanceText(
account.closingBalance,
),
),
const DataCell(
Icon(
Icons.chevron_right_rounded,
size: 20,
color: Color(0xFF98A2B3),
),
),
],
);
}

// =============================================================
// MOBILE ACCOUNTS
// =============================================================

Widget _buildMobileAccounts() {
if (_accountSummaries.isEmpty) {
return const _EmptyView();
}

return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
const Expanded(
child: Text(
'Ledger Accounts',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
),
),
Text(
'${_accountSummaries.length}',
style: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.w700,
color: Color(0xFF667085),
),
),
],
),
const SizedBox(height: 12),
..._accountSummaries.map(
(account) => Padding(
padding:
const EdgeInsets.only(
bottom: 10,
),
child: _buildMobileAccountCard(
account,
),
),
),
],
);
}

Widget _buildMobileAccountCard(
LedgerAccountSummary account,
) {
return InkWell(
onTap: () {
_openAccount(account);
},
borderRadius:
BorderRadius.circular(15),
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(15),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Column(
children: [
Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color:
const Color(0xFFEFF2FF),
borderRadius:
BorderRadius.circular(10),
),
child: const Icon(
Icons.account_balance_outlined,
size: 18,
color:
Color(0xFF315CF6),
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
account.account,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 12.5,
fontWeight:
FontWeight.w800,
color:
Color(0xFF101828),
),
),
const SizedBox(height: 3),
Text(
'${account.accountClass} • ${account.subClass}',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 9.5,
color:
Color(0xFF98A2B3),
fontWeight:
FontWeight.w500,
),
),
],
),
),
const Icon(
Icons.chevron_right_rounded,
color: Color(0xFF98A2B3),
),
],
),
const SizedBox(height: 16),
Container(
width: double.infinity,
padding:
const EdgeInsets.symmetric(
vertical: 11,
horizontal: 12,
),
decoration: BoxDecoration(
color: const Color(0xFFF8F9FC),
borderRadius:
BorderRadius.circular(10),
),
child: Row(
children: [
const Expanded(
child: Text(
'BALANCE',
style: TextStyle(
fontSize: 8,
fontWeight:
FontWeight.w800,
color:
Color(0xFF98A2B3),
letterSpacing: .5,
),
),
),
Text(
money(
account.closingBalance,
),
style: const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w800,
color:
Color(0xFF101828),
),
),
],
),
),
const SizedBox(height: 13),
Row(
children: [
Expanded(
child: _miniMetric(
'OPENING',
account.openingBalance,
),
),
Expanded(
child: _miniMetric(
'DEBIT',
account.debit,
),
),
Expanded(
child: _miniMetric(
'CREDIT',
account.credit,
),
),
],
),
],
),
),
);
}

Widget _miniMetric(
String label,
double amount,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
fontSize: 7.5,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w800,
letterSpacing: .4,
),
),
const SizedBox(height: 4),
Text(
money(amount),
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 9.5,
color: Color(0xFF475467),
fontWeight: FontWeight.w700,
),
),
],
);
}

// =============================================================
// BADGES / TEXT
// =============================================================

Widget _classBadge(String accountClass) {
return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 8,
vertical: 5,
),
decoration: BoxDecoration(
color: const Color(0xFFF2F4F7),
borderRadius:
BorderRadius.circular(7),
),
child: Text(
accountClass,
style: const TextStyle(
fontSize: 8.5,
fontWeight: FontWeight.w700,
color: Color(0xFF475467),
),
),
);
}

Widget _amountText(double amount) {
return Text(
money(amount),
style: const TextStyle(
fontSize: 10.5,
fontWeight: FontWeight.w700,
color: Color(0xFF475467),
),
);
}

Widget _balanceText(double amount) {
return Text(
money(amount),
style: const TextStyle(
fontSize: 10.5,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
);
}
}


/// ===============================================================
/// LEDGER ACCOUNT DETAILS PAGE
/// ===============================================================

class LedgerAccountDetailsPage
extends StatelessWidget {
final LedgerAccountSummary account;
final DateTime selectedDate;

const LedgerAccountDetailsPage({
super.key,
required this.account,
required this.selectedDate,
});

@override
Widget build(BuildContext context) {
final transactions =
List<LedgerTransaction>.from(
account.transactions,
);

transactions.sort(
(a, b) => b.createdAt.compareTo(
a.createdAt,
),
);

return Scaffold(
backgroundColor:Constants.scaffoldcolor,
appBar: AppBar(
backgroundColor: Constants.appbarcolor,
surfaceTintColor: Colors.white,
elevation: 0,
toolbarHeight: 70,
leading: IconButton(
onPressed: () {
Navigator.of(context).pop();
},
icon: const Icon(
Icons.arrow_back_rounded,
color: Color(0xFF344054),
),
),
title: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
account.account,
style: const TextStyle(
color: Color(0xFF101828),
fontSize: 15,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 3),
Text(
'${account.accountClass} • ${account.subClass}',
style: const TextStyle(
color: Color(0xFF98A2B3),
fontSize: 10,
fontWeight: FontWeight.w500,
),
),
],
),
),
body: LayoutBuilder(
builder: (context, constraints) {
if (constraints.maxWidth < 700) {
return _mobileDetails(
context,
transactions,
);
}

return _desktopDetails(
context,
transactions,
);
},
),
);
}

// =============================================================
// DESKTOP DETAILS
// =============================================================

Widget _desktopDetails(
BuildContext context,
List<LedgerTransaction> transactions,
) {
return SingleChildScrollView(
padding: const EdgeInsets.all(28),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_detailsHeader(),
const SizedBox(height: 20),
_detailsSummary(),
const SizedBox(height: 24),
_transactionTable(
context,
transactions,
),
],
),
);
}

// =============================================================
// MOBILE DETAILS
// =============================================================

Widget _mobileDetails(
BuildContext context,
List<LedgerTransaction> transactions,
) {
return ListView(
padding: const EdgeInsets.all(16),
children: [
_detailsHeader(),
const SizedBox(height: 16),
_detailsSummary(),
const SizedBox(height: 20),
_transactionCards(
context,
transactions,
),
],
);
}

// =============================================================
// DETAILS HEADER
// =============================================================

Widget _detailsHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Row(
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Color(0xFF315CF6),
Color(0xFF5278FF),
],
),
borderRadius:
BorderRadius.circular(14),
),
child: const Icon(
Icons.account_balance_rounded,
color: Colors.white,
size: 23,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
account.account,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
),
const SizedBox(height: 4),
Text(
'${account.accountClass} • ${account.subClass}',
style: const TextStyle(
fontSize: 11,
color: Color(0xFF667085),
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
'Report date: ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
style: const TextStyle(
fontSize: 10,
color: Color(0xFF98A2B3),
),
),
],
),
),
],
),
);
}

// =============================================================
// DETAILS SUMMARY
// =============================================================

Widget _detailsSummary() {
final items = [
_SummaryData(
title: 'Opening Balance',
value: account.openingBalance,
icon:
Icons.account_balance_wallet_outlined,
),
_SummaryData(
title: 'Debit',
value: account.debit,
icon: Icons.arrow_upward_rounded,
),
_SummaryData(
title: 'Credit',
value: account.credit,
icon: Icons.arrow_downward_rounded,
),
_SummaryData(
title: 'Closing Balance',
value: account.closingBalance,
icon: Icons.account_balance_rounded,
),
];

return LayoutBuilder(
builder: (context, constraints) {
final columns =
constraints.maxWidth >= 1000
? 4
    : constraints.maxWidth >= 650
? 2
    : 2;

return GridView.builder(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount: items.length,
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: columns,
crossAxisSpacing: 10,
mainAxisSpacing: 10,
mainAxisExtent: 100,
),
itemBuilder: (_, index) {
return _detailSummaryCard(
items[index],
);
},
);
},
);
}

Widget _detailSummaryCard(
_SummaryData data,
) {
return Container(
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Row(
children: [
Icon(
data.icon,
size: 15,
color: const Color(0xFF315CF6),
),
const SizedBox(width: 6),
Expanded(
child: Text(
data.title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 9,
color: Color(0xFF667085),
fontWeight: FontWeight.w600,
),
),
),
],
),
const SizedBox(height: 7),
Text(
money(data.value),
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
),
],
),
);
}

// =============================================================
// TRANSACTION TABLE
// =============================================================

Widget _transactionTable(
BuildContext context,
List<LedgerTransaction> transactions,
) {
return Container(
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.all(20),
child: Row(
children: [
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Transactions',
style: TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w800,
color:
Color(0xFF101828),
),
),
SizedBox(height: 3),
Text(
'Transactions affecting this account',
style: TextStyle(
fontSize: 10,
color:
Color(0xFF98A2B3),
),
),
],
),
),
],
),
),
const Divider(
height: 1,
color: Color(0xFFE4E7EC),
),
if (transactions.isEmpty)
const Padding(
padding: EdgeInsets.all(40),
child: Center(
child: Text(
'No transactions for this date.',
style: TextStyle(
fontSize: 11,
color:
Color(0xFF98A2B3),
),
),
),
)
else
SingleChildScrollView(
scrollDirection:
Axis.horizontal,
child: DataTable(
headingRowHeight: 45,
dataRowMinHeight: 68,
dataRowMaxHeight: 80,
columnSpacing: 25,
horizontalMargin: 20,
columns: const [
DataColumn(
label: Text('DATE'),
),
DataColumn(
label: Text('ACTIVITY'),
),
DataColumn(
label: Text('DESCRIPTION'),
),
DataColumn(
label: Text('DEBIT'),
numeric: true,
),
DataColumn(
label: Text('CREDIT'),
numeric: true,
),
DataColumn(
label: Text('STAFF'),
),
DataColumn(
label: Text(''),
),
],
rows: transactions
    .map(
(transaction) =>
DataRow(
cells: [
DataCell(
Text(
DateFormat(
'dd/MM/yyyy HH:mm',
).format(
transaction.createdAt,
),
style:
const TextStyle(
fontSize: 9.5,
color: Color(
0xFF475467,
),
),
),
),
DataCell(
Text(
transaction
    .activityType,
style:
const TextStyle(
fontSize: 10,
fontWeight:
FontWeight.w700,
color: Color(
0xFF101828,
),
),
),
),
DataCell(
SizedBox(
width: 220,
child: Text(
transaction
    .studentName
    .isNotEmpty
? transaction
    .studentName
    : transaction
    .note,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize: 9.5,
color: Color(
0xFF667085,
),
),
),
),
),
DataCell(
Text(
money(
transaction
    .accountDebit(
account.account,
),
),
style:
const TextStyle(
fontSize: 10,
fontWeight:
FontWeight.w700,
),
),
),
DataCell(
Text(
money(
transaction
    .accountCredit(
account.account,
),
),
style:
const TextStyle(
fontSize: 10,
fontWeight:
FontWeight.w700,
),
),
),
DataCell(
Text(
transaction.staff,
style:
const TextStyle(
fontSize: 9.5,
color: Color(
0xFF667085,
),
),
),
),
DataCell(
IconButton(
tooltip:
'View transaction',
onPressed: () {
_showTransaction(
context,
transaction,
);
},
icon:
const Icon(
Icons
    .visibility_outlined,
size: 17,
color: Color(
0xFF315CF6,
),
),
),
),
],
),
)
    .toList(),
),
),
],
),
);
}

// =============================================================
// MOBILE TRANSACTIONS
// =============================================================

Widget _transactionCards(
BuildContext context,
List<LedgerTransaction> transactions,
) {
if (transactions.isEmpty) {
return Container(
padding: const EdgeInsets.all(30),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(15),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: const Center(
child: Text(
'No transactions for this date.',
style: TextStyle(
fontSize: 11,
color: Color(0xFF98A2B3),
),
),
),
);
}

return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Transactions',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
),
const SizedBox(height: 12),
...transactions.map(
(transaction) => Padding(
padding:
const EdgeInsets.only(
bottom: 10,
),
child: InkWell(
onTap: () {
_showTransaction(
context,
transaction,
);
},
borderRadius:
BorderRadius.circular(14),
child: Container(
padding:
const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: const Color(
0xFFE4E7EC,
),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 36,
height: 36,
decoration:
BoxDecoration(
color: const Color(
0xFFEFF2FF,
),
borderRadius:
BorderRadius
    .circular(9),
),
child: const Icon(
Icons
    .receipt_long_outlined,
size: 17,
color: Color(
0xFF315CF6,
),
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
transaction
    .activityType,
style:
const TextStyle(
fontSize: 11.5,
fontWeight:
FontWeight
    .w800,
color: Color(
0xFF101828,
),
),
),
const SizedBox(
height: 3,
),
Text(
DateFormat(
'dd MMM yyyy • HH:mm',
).format(
transaction
    .createdAt,
),
style:
const TextStyle(
fontSize: 9,
color: Color(
0xFF98A2B3,
),
),
),
],
),
),
const Icon(
Icons
    .chevron_right_rounded,
size: 20,
color: Color(
0xFF98A2B3,
),
),
],
),
const SizedBox(height: 13),
if (transaction
    .studentName
    .isNotEmpty)
_detailLine(
'Student',
transaction
    .studentName,
),
if (transaction
    .feeName
    .isNotEmpty)
_detailLine(
'Fee',
transaction.feeName,
),
const SizedBox(height: 10),
Row(
children: [
Expanded(
child: _transactionAmount(
'DEBIT',
transaction
    .accountDebit(
account.account,
),
),
),
Expanded(
child:
_transactionAmount(
'CREDIT',
transaction
    .accountCredit(
account.account,
),
),
),
],
),
],
),
),
),
),
),
],
);
}

Widget _detailLine(
String label,
String value,
) {
return Padding(
padding:
const EdgeInsets.only(bottom: 5),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
SizedBox(
width: 65,
child: Text(
label,
style: const TextStyle(
fontSize: 9,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w600,
),
),
),
Expanded(
child: Text(
value,
style: const TextStyle(
fontSize: 9.5,
color: Color(0xFF475467),
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}

Widget _transactionAmount(
String label,
double amount,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
fontSize: 7.5,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w800,
letterSpacing: .4,
),
),
const SizedBox(height: 3),
Text(
money(amount),
style: const TextStyle(
fontSize: 10,
color: Color(0xFF344054),
fontWeight: FontWeight.w800,
),
),
],
);
}

// =============================================================
// TRANSACTION DIALOG
// =============================================================

void _showTransaction(
BuildContext context,
LedgerTransaction transaction,
) {
showDialog(
context: context,
builder: (_) {
return Dialog(
backgroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(18),
),
child: ConstrainedBox(
constraints:
const BoxConstraints(
maxWidth: 560,
),
child: SingleChildScrollView(
padding:
const EdgeInsets.all(24),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color: const Color(
0xFFEFF2FF,
),
borderRadius:
BorderRadius.circular(
11,
),
),
child: const Icon(
Icons
    .receipt_long_rounded,
color: Color(
0xFF315CF6,
),
size: 20,
),
),
const SizedBox(width: 11),
const Expanded(
child: Text(
'Transaction Details',
style: TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w800,
color: Color(
0xFF101828,
),
),
),
),
IconButton(
onPressed: () {
Navigator.of(
context,
).pop();
},
icon: const Icon(
Icons.close_rounded,
size: 19,
),
),
],
),
const SizedBox(height: 20),
_dialogSection(
'Transaction',
[
_dialogRow(
'Activity',
transaction
    .activityType,
),
_dialogRow(
'Date',
DateFormat(
'dd MMMM yyyy • HH:mm',
).format(
transaction
    .createdAt,
),
),
_dialogRow(
'Transaction ID',
transaction
    .transactionId,
),
],
),
const SizedBox(height: 14),
_dialogSection(
'Account Movement',
[
_dialogRow(
'Account',
account.account,
),
_dialogRow(
'Account Class',
account.accountClass,
),
_dialogRow(
'Sub Class',
account.subClass,
),
_dialogRow(
'Debit',
money(
transaction
    .accountDebit(
account.account,
),
),
),
_dialogRow(
'Credit',
money(
transaction
    .accountCredit(
account.account,
),
),
),
],
),
if (transaction
    .studentName
    .isNotEmpty ||
transaction
    .studentId
    .isNotEmpty) ...[
const SizedBox(height: 14),
_dialogSection(
'Student',
[
_dialogRow(
'Name',
transaction
    .studentName,
),
_dialogRow(
'Student ID',
transaction
    .studentId,
),
_dialogRow(
'Level',
transaction.level,
),
_dialogRow(
'Year Group',
transaction.yeargroup,
),
_dialogRow(
'Term',
transaction.term,
),
],
),
],
const SizedBox(height: 14),
_dialogSection(
'Additional Information',
[
_dialogRow(
'Fee',
transaction.feeName,
),
_dialogRow(
'Staff',
transaction.staff,
),
_dialogRow(
'Note',
transaction.note,
),
_dialogRow(
'Billing ID',
transaction.billedId,
),
],
),
],
),
),
),
);
},
);
}

Widget _dialogSection(
String title,
List<Widget> children,
) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: const Color(0xFFF8F9FC),
borderRadius:
BorderRadius.circular(12),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 9.5,
fontWeight: FontWeight.w800,
color: Color(0xFF667085),
letterSpacing: .3,
),
),
const SizedBox(height: 9),
...children,
],
),
);
}

Widget _dialogRow(
String label,
String value,
) {
return Padding(
padding:
const EdgeInsets.only(bottom: 7),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
SizedBox(
width: 105,
child: Text(
label,
style: const TextStyle(
fontSize: 9.5,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w600,
),
),
),
Expanded(
child: Text(
value.isEmpty ? '-' : value,
style: const TextStyle(
fontSize: 9.5,
color: Color(0xFF344054),
fontWeight: FontWeight.w700,
),
),
),
],
),
);
}
}


/// ===============================================================
/// LEDGER TRANSACTION MODEL
/// ===============================================================

class LedgerTransaction {
final String documentId;

final String transactionId;
final String activityType;

final DateTime createdAt;

final String schoolId;

final String studentId;
final String studentName;

final String feeName;
final String level;
final String term;
final String yeargroup;

final String note;
final String staff;

final String billedId;

final String debitAccount;
final String debitAccountClass;
final String debitSubClass;
final double debitValue;

final String creditAccount;
final String creditAccountClass;
final String creditSubClass;
final double creditValue;

LedgerTransaction({
required this.documentId,
required this.transactionId,
required this.activityType,
required this.createdAt,
required this.schoolId,
required this.studentId,
required this.studentName,
required this.feeName,
required this.level,
required this.term,
required this.yeargroup,
required this.note,
required this.staff,
required this.billedId,
required this.debitAccount,
required this.debitAccountClass,
required this.debitSubClass,
required this.debitValue,
required this.creditAccount,
required this.creditAccountClass,
required this.creditSubClass,
required this.creditValue,
});

factory LedgerTransaction.fromFirestore(
String documentId, Map<String, dynamic> data,
) {
  final accounts = Map<String, dynamic>.from(
    data['accounts'] ?? {},
  );
final debit = Map<String, dynamic>.from(accounts['debit'] ?? {},);

final credit = Map<String, dynamic>.from(accounts['credit'] ?? {},
);

return LedgerTransaction(
documentId: documentId,

transactionId:data['transactionId']?.toString() ??documentId,

activityType:data['activityType']?.toString() ??'',

createdAt:
_parseDate(data['createdAt']),

schoolId:
data['schoolId']
    ?.toString() ??
'',

studentId:
data['studentId']
    ?.toString() ??
'',

studentName:
data['studentName']
    ?.toString() ??
'',

feeName:
data['feeName']
    ?.toString() ??
'',

level:
data['level']
    ?.toString() ??
'',

term:
data['term']
    ?.toString() ??
'',

yeargroup:
data['yeargroup']
    ?.toString() ??
'',

note:
data['note']
    ?.toString() ??
'',

staff:
data['staff']
    ?.toString() ??
'',

billedId:
data['billedId']
    ?.toString() ??
'',

debitAccount:debit['account']
    ?.toString() ??
'',

debitAccountClass:debit['accountClass']
    ?.toString() ??
'',

debitSubClass:
debit['subClass']
    ?.toString() ??
'',

debitValue:
_toDouble(debit['value']),

creditAccount:
credit['account']
    ?.toString() ??
'',

creditAccountClass:
credit['accountClass']
    ?.toString() ??
'',

creditSubClass:
credit['subClass']
    ?.toString() ??
'',

creditValue:
_toDouble(credit['value']),
);
}

static DateTime _parseDate(dynamic value) {
if (value is Timestamp) {
return value.toDate();
}

if (value is DateTime) {
return value;
}

if (value is String) {
return DateTime.tryParse(value) ??
DateTime(2000);
}

return DateTime(2000);
}

static double _toDouble(dynamic value) {
if (value == null) return 0;

if (value is num) {
return value.toDouble();
}

return double.tryParse(
value
    .toString()
    .replaceAll(',', '')
    .trim(),
) ??
0;
}

double accountDebit(String account) {
if (debitAccount == account) {
return debitValue;
}

return 0;
}

double accountCredit(String account) {
if (creditAccount == account) {
return creditValue;
}

return 0;
}
}


class LedgerAccountSummary {
final String account;
final String accountClass;
final String subClass;

double openingDebit;
double openingCredit;

double debit;
double credit;

final List<LedgerTransaction> transactions;

LedgerAccountSummary({
required this.account,
required this.accountClass,
required this.subClass,
this.openingDebit = 0,
this.openingCredit = 0,
this.debit = 0,
this.credit = 0,
List<LedgerTransaction>? transactions,
}) : transactions =
transactions ?? [];


double get openingBalance {
if (_isDebitNormal) {
return openingDebit - openingCredit;
}

return openingCredit - openingDebit;
}


double get closingBalance {
if (_isDebitNormal) {
return openingBalance +
debit -
credit;
}

return openingBalance +
credit -
debit;
}

bool get _isDebitNormal {
final normalized =
accountClass
    .trim()
    .toLowerCase();

return normalized == 'assets' ||
normalized == 'asset' ||
normalized == 'expenses' ||
normalized == 'expense' ||
normalized == 'cost of sales' ||
normalized == 'cost of goods sold';
}
}


class _SummaryData {
final String title;
final double value;
final IconData icon;

const _SummaryData({
required this.title,
required this.value,
required this.icon,
});
}



class _LoadingView extends StatelessWidget {
const _LoadingView();

@override
Widget build(BuildContext context) {
return const Center(
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
SizedBox(
width: 28,
height: 28,
child:
CircularProgressIndicator(
strokeWidth: 2.5,
valueColor:
AlwaysStoppedAnimation<
Color>(
Color(0xFF315CF6),
),
),
),
SizedBox(height: 14),
Text(
'Loading ledger report...',
style: TextStyle(
fontSize: 11,
color: Color(0xFF667085),
fontWeight: FontWeight.w600,
),
),
],
),
);
}
}

class _ErrorView extends StatelessWidget {
final String error;
final VoidCallback onRetry;

const _ErrorView({
required this.error,
required this.onRetry,
});

@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Container(
constraints:
const BoxConstraints(
maxWidth: 500,
),
padding:
const EdgeInsets.all(24),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: const Color(
0xFFE4E7EC,
),
),
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color:
const Color(0xFFFEF3F2),
borderRadius:
BorderRadius.circular(
14,
),
),
child: const Icon(
Icons.error_outline_rounded,
color:
Color(0xFFD92D20),
),
),
const SizedBox(height: 14),
const Text(
'Unable to load ledger',
style: TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w800,
color:
Color(0xFF101828),
),
),
const SizedBox(height: 7),
Text(
error,
textAlign:
TextAlign.center,
style: const TextStyle(
fontSize: 10.5,
color:
Color(0xFF667085),
),
),
const SizedBox(height: 18),
ElevatedButton.icon(
onPressed: onRetry,
icon: const Icon(
Icons.refresh_rounded,
size: 17,
),
label: const Text(
'Try Again',
),
style:
ElevatedButton.styleFrom(
backgroundColor:
const Color(
0xFF315CF6,
),
foregroundColor:
Colors.white,
elevation: 0,
padding:
const EdgeInsets
    .symmetric(
horizontal: 18,
vertical: 12,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
10,
),
),
),
),
],
),
),
),
);
}
}

class _EmptyView extends StatelessWidget {
const _EmptyView();

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
vertical: 55,
horizontal: 20,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: Column(
children: [
Container(
width: 55,
height: 55,
decoration: BoxDecoration(
color:
const Color(0xFFF2F4F7),
borderRadius:
BorderRadius.circular(15),
),
child: const Icon(
Icons.account_balance_outlined,
size: 25,
color: Color(0xFF98A2B3),
),
),
const SizedBox(height: 14),
const Text(
'No ledger accounts found',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w800,
color: Color(0xFF344054),
),
),
const SizedBox(height: 5),
const Text(
'Try another date or search term.',
style: TextStyle(
fontSize: 10.5,
color: Color(0xFF98A2B3),
),
),
],
),
);
}
}

String money(double value) {
final formatter =
NumberFormat('#,##0.00');

return '${formatter.format(value)}';
}

class LedgerPdfService {
  static const PdfColor primary =
  PdfColor.fromInt(0xFF315CF6);

  static const PdfColor dark =
  PdfColor.fromInt(0xFF101828);

  static const PdfColor grey =
  PdfColor.fromInt(0xFF667085);

  static const PdfColor light =
  PdfColor.fromInt(0xFFF4F7FF);

  static String amount(double value) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }

  static Future<Uint8List> buildLedgerReportPdf({
    required List<LedgerAccountSummary> accounts,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final totalOpening = accounts.fold<double>(
      0,
          (sum, account) => sum + account.openingBalance,
    );

    final totalDebit = accounts.fold<double>(
      0,
          (sum, account) => sum + account.debit,
    );

    final totalCredit = accounts.fold<double>(
      0,
          (sum, account) => sum + account.credit,
    );

    final totalClosing = accounts.fold<double>(
      0,
          (sum, account) => sum + account.closingBalance,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),

        header: (context) => _reportHeader(
          'Ledger Report',
          '${DateFormat('dd MMM yyyy').format(startDate)} - '
              '${DateFormat('dd MMM yyyy').format(endDate)}',
        ),

        footer: (context) => _footer(context),

        build: (context) => [
          pw.SizedBox(height: 15),

          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: light,
              borderRadius:
              pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                _summaryBox(
                  'Accounts',
                  '${accounts.length}',
                ),
                _summaryBox(
                  'Opening',
                  amount(totalOpening),
                ),
                _summaryBox(
                  'Debit',
                  amount(totalDebit),
                ),
                _summaryBox(
                  'Credit',
                  amount(totalCredit),
                ),
                _summaryBox(
                  'Closing',
                  amount(totalClosing),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            'Ledger Accounts',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.TableHelper.fromTextArray(
            headers: [
              'ACCOUNT',
              'CLASS',
              'SUB CLASS',
              'OPENING',
              'DEBIT',
              'CREDIT',
              'BALANCE',
            ],

            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),

            headerDecoration:
            const pw.BoxDecoration(
              color: primary,
            ),

            cellStyle: const pw.TextStyle(
              fontSize: 8,
              color: dark,
            ),

            cellPadding:
            const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),

            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: .5,
                ),
              ),
            ),

            data: accounts.map((account) {
              return [
                account.account,
                account.accountClass,
                account.subClass,
                amount(account.openingBalance),
                amount(account.debit),
                amount(account.credit),
                amount(account.closingBalance),
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 18),

          pw.Container(
            padding:
            const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius:
              pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Closing Balance: ',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                    pw.FontWeight.bold,
                    color: grey,
                  ),
                ),
                pw.Text(
                  amount(totalClosing),
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight:
                    pw.FontWeight.bold,
                    color: dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> buildAccountPdf({
    required LedgerAccountSummary account,
    required DateTime selectedDate,
    required List<LedgerTransaction> transactions,
  }) async {
    final pdf = pw.Document();

    transactions = List<LedgerTransaction>.from(
      transactions,
    );

    transactions.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),

        header: (context) => _reportHeader(
          account.account,
          '${account.accountClass} • ${account.subClass}',
        ),

        footer: (context) => _footer(context),

        build: (context) => [
          pw.SizedBox(height: 15),

          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: light,
              borderRadius:
              pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                _summaryBox(
                  'Opening Balance',
                  amount(account.openingBalance),
                ),
                _summaryBox(
                  'Debit',
                  amount(account.debit),
                ),
                _summaryBox(
                  'Credit',
                  amount(account.credit),
                ),
                _summaryBox(
                  'Closing Balance',
                  amount(account.closingBalance),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            'Transactions',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),

          pw.SizedBox(height: 10),

          if (transactions.isEmpty)
            pw.Padding(
              padding:
              const pw.EdgeInsets.all(20),
              child: pw.Text(
                'No transactions for this date.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: grey,
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: [
                'DATE',
                'ACTIVITY',
                'DESCRIPTION',
                'DEBIT',
                'CREDIT',
                'STAFF',
              ],

              headerStyle: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),

              headerDecoration:
              const pw.BoxDecoration(
                color: primary,
              ),

              cellStyle: const pw.TextStyle(
                fontSize: 7.5,
                color: dark,
              ),

              cellPadding:
              const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),

              data: transactions.map((transaction) {
                return [
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(
                    transaction.createdAt,
                  ),

                  transaction.activityType,

                  _description(transaction),

                  amount(
                    transaction.accountDebit(
                      account.account,
                    ),
                  ),

                  amount(
                    transaction.accountCredit(
                      account.account,
                    ),
                  ),

                  transaction.staff,
                ];
              }).toList(),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> buildTransactionPdf({
    required LedgerAccountSummary account,
    required LedgerTransaction transaction,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        header: (context) => _reportHeader(
          'Transaction Details',
          transaction.activityType,
        ),

        footer: (context) => _footer(context),

        build: (context) => [
          _section(
            'Transaction',
            [
              _row(
                'Activity',
                transaction.activityType,
              ),
              _row(
                'Date',
                DateFormat(
                  'dd MMMM yyyy • HH:mm',
                ).format(
                  transaction.createdAt,
                ),
              ),
              _row(
                'Transaction ID',
                transaction.transactionId,
              ),
            ],
          ),

          pw.SizedBox(height: 14),

          _section(
            'Account Movement',
            [
              _row(
                'Account',
                account.account,
              ),
              _row(
                'Account Class',
                account.accountClass,
              ),
              _row(
                'Sub Class',
                account.subClass,
              ),
              _row(
                'Debit',
                amount(
                  transaction.accountDebit(
                    account.account,
                  ),
                ),
              ),
              _row(
                'Credit',
                amount(
                  transaction.accountCredit(
                    account.account,
                  ),
                ),
              ),
            ],
          ),

          if (transaction.studentName.isNotEmpty ||
              transaction.studentId.isNotEmpty) ...[
            pw.SizedBox(height: 14),

            _section(
              'Student',
              [
                _row(
                  'Name',
                  transaction.studentName,
                ),
                _row(
                  'Student ID',
                  transaction.studentId,
                ),
                _row(
                  'Level',
                  transaction.level,
                ),
                _row(
                  'Year Group',
                  transaction.yeargroup,
                ),
                _row(
                  'Term',
                  transaction.term,
                ),
              ],
            ),
          ],

          pw.SizedBox(height: 14),

          _section(
            'Additional Information',
            [
              _row(
                'Fee',
                transaction.feeName,
              ),
              _row(
                'Staff',
                transaction.staff,
              ),
              _row(
                'Note',
                transaction.note,
              ),
              _row(
                'Billing ID',
                transaction.billedId,
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _reportHeader(
      String title,
      String subtitle,
      ) {
    return pw.Container(
      padding:
      const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 32,
            height: 32,
            decoration: pw.BoxDecoration(
              color: primary,
              borderRadius:
              pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text(
                'L',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),
            ),
          ),

          pw.SizedBox(width: 10),

          pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                  pw.FontWeight.bold,
                  color: dark,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                subtitle,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryBox(
      String title,
      String value,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 7,
            color: grey,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: dark,
          ),
        ),
      ],
    );
  }

  static pw.Widget _section(
      String title,
      List<pw.Widget> children,
      ) {
    return pw.Container(
      width: double.infinity,
      padding:
      const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius:
        pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight:
              pw.FontWeight.bold,
              color: grey,
            ),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _row(
      String label,
      String value,
      ) {
    return pw.Padding(
      padding:
      const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 8,
                color: grey,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight:
                pw.FontWeight.bold,
                color: dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(
      pw.Context context,
      ) {
    return pw.Container(
      padding:
      const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColors.grey300,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Ledger Report',
            style: const pw.TextStyle(
              fontSize: 7,
              color: grey,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 7,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }

  static String _description(
      LedgerTransaction transaction,
      ) {
    final parts = <String>[];

    if (transaction.studentName.isNotEmpty) {
      parts.add(
        'Student: ${transaction.studentName}',
      );
    }

    if (transaction.feeName.isNotEmpty) {
      parts.add(
        'Fee: ${transaction.feeName}',
      );
    }

    if (transaction.note.isNotEmpty) {
      parts.add(transaction.note);
    }

    return parts.isEmpty
        ? '-'
        : parts.join(' • ');
  }
}



