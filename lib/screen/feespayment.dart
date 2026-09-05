import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/feePaymentModel.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:ksoftsms/widgets/dropdown.dart';

class Feepayment extends StatefulWidget {
const Feepayment({super.key});

@override
State<Feepayment> createState() => _FeepaymentState();
}

class _FeepaymentState extends State<Feepayment> {

final receiptNumberController = TextEditingController();
final accountController = TextEditingController();
final searchController = TextEditingController();
final noteController = TextEditingController();

final _formKey = GlobalKey<FormState>();

String? receiptNumber;
String? selectedTerm;
String? selectedfee;
String? selectedpaymentmethod;
String? selectedLinkedAccount;

@override
void initState() {
super.initState();

accountController.addListener(_refreshAmount);

WidgetsBinding.instance.addPostFrameCallback((_) async {
final provider = Provider.of<Myprovider>(
context,
listen: false,
);

provider.getdata();
provider.fetchterms();
provider.fetchFess();
provider.paymentmethodslist();
provider.generatereceiptnumber();

receiptNumberController.text = provider.receiptno;

if (mounted) {
setState(() {});
}
});
}

void _refreshAmount() {
if (mounted) {
setState(() {});
}
}

@override
void dispose() {
receiptNumberController.dispose();
accountController.removeListener(_refreshAmount);
accountController.dispose();
searchController.dispose();
noteController.dispose();
super.dispose();
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return ProgressHUD(
child: Builder(
builder: (context) {
return Consumer<Myprovider>(
builder: (
BuildContext context,
value,
Widget? child,
) {
return Scaffold(
backgroundColor: const Color(0xFFF4F6FA),
appBar: _buildAppBar(context, value),
body: LayoutBuilder(
builder: (context, constraints) {
if (constraints.maxWidth >= 1180) {
return _buildDesktop(context, value);
}

if (constraints.maxWidth >= 760) {
return _buildTablet(context, value);
}

return _buildMobile(context, value);
},
),
);
},
);
},
),
);
}

// ============================================================
// APP BAR
// ============================================================

PreferredSizeWidget _buildAppBar(
BuildContext context,
Myprovider value,
) {
return AppBar(
backgroundColor: Colors.white,
surfaceTintColor: Colors.white,
elevation: 0,
toolbarHeight: 70,
leadingWidth: 62,
leading: Padding(
padding: const EdgeInsets.only(left: 14),
child: IconButton(
tooltip: 'Back to dashboard',
onPressed: () {
context.go(Routes.dashboard);
},
icon: const Icon(
Icons.arrow_back_rounded,
color: Color(0xFF344054),
),
),
),
titleSpacing: 4,
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
borderRadius: BorderRadius.circular(13),
boxShadow: [
BoxShadow(
color: const Color(0xFF315CF6).withOpacity(.18),
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
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Receive School Payment',
style: TextStyle(
color: Color(0xFF101828),
fontSize: 15,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 3),
Text(
value.name.isEmpty
? 'Cashier payment terminal'
    : 'Cashier • ${value.name}',
style: const TextStyle(
color: Color(0xFF98A2B3),
fontSize: 10.5,
fontWeight: FontWeight.w500,
),
),
],
),
],
),

actions: [
_TopBarStatus(
receipt: receiptNumberController.text,
value: value,
receiptNumberController: receiptNumberController,
),

  const SizedBox(width: 10),

  Padding(
  padding: const EdgeInsets.only(right: 18),
  child: OutlinedButton.icon(
  onPressed: () {
  context.go(Routes.feepaymentview);
  },
  icon: const Icon(
  Icons.receipt_long_rounded,
  size: 17,
  ),
  label: const Text(
  'Payment History',
  style: TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 12,
  ),
  ),
  style: OutlinedButton.styleFrom(
  foregroundColor: const Color(0xFF315CF6),
  side: const BorderSide(
  color: Color(0xFFD0D5DD),
  ),
  padding: const EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 11,
  ),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(11),
  ),
  ),
  ),
  ),
  ],


);
}

// ============================================================
// DESKTOP
// ============================================================

Widget _buildDesktop(
BuildContext context,
Myprovider value,
) {
return SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 1000,
),
child: Form(
key: _formKey,
child: Column(
children: [
//_buildPageIntro(value),

const SizedBox(height: 22),

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
flex: 7,
child: Column(
children: [
_buildStudentSection(
context,
value,
),
const SizedBox(height: 18),
_buildPaymentSection(
context,
value,
),
const SizedBox(height: 18),
_buildNoteSection(),
],
),
),
const SizedBox(width: 20),
SizedBox(
width: 365,
child: Column(
children: [
_buildSummarySection(
context,
value,
),
const SizedBox(height: 16),
_buildCashierCard(value),
const SizedBox(height: 16),
_buildSecurityCard(),
],
),
),
],
),
],
),
),
),
),
);
}

// ============================================================
// TABLET
// ============================================================

Widget _buildTablet(
BuildContext context,
Myprovider value,
) {
return SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Form(
key: _formKey,
child: Column(
children: [
//_buildPageIntro(value),

const SizedBox(height: 20),

_buildStudentSection(
context,
value,
),

const SizedBox(height: 18),

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
children: [
_buildPaymentSection(
context,
value,
),
const SizedBox(height: 18),
_buildNoteSection(),
],
),
),
const SizedBox(width: 18),
SizedBox(
width: 300,
child: _buildSummarySection(
context,
value,
),
),
],
),

const SizedBox(height: 18),

_buildCashierCard(value),
],
),
),
);
}

// ============================================================
// MOBILE
// ============================================================

Widget _buildMobile(
BuildContext context,
Myprovider value,
) {
return SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
12,
14,
12,
35,
),
child: Form(
key: _formKey,
child: Column(
children: [
//_buildPageIntro(value),

const SizedBox(height: 15),

_buildStudentSection(
context,
value,
),

const SizedBox(height: 14),

_buildPaymentSection(
context,
value,
),

const SizedBox(height: 14),

_buildNoteSection(),

const SizedBox(height: 14),

_buildSummarySection(
context,
value,
),

const SizedBox(height: 14),

_buildCashierCard(value),

const SizedBox(height: 14),

_buildSecurityCard(),
],
),
),
);
}

// ============================================================
// PAGE INTRO
// ============================================================

Widget _buildPageIntro(Myprovider value) {
return Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Collect a payment',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.w900,
color: Color(0xFF101828),
letterSpacing: -.4,
),
),
const SizedBox(height: 5),
const Text(
'Find the student, enter the payment details, then review and confirm.',
style: TextStyle(
fontSize: 12,
color: Color(0xFF667085),
),
),
],
),
),
_StepIndicator(
number: '01',
label: 'Student',
active: true,
),
_StepLine(),
_StepIndicator(
number: '02',
label: 'Payment',
active: true,
),
_StepLine(),
_StepIndicator(
number: '03',
label: 'Confirm',
active: true,
),
],
);
}

// ============================================================
// STUDENT
// ============================================================

Widget _buildStudentSection(
BuildContext context,
Myprovider value,
) {
final hasStudent =
value.selectedStudents.isNotEmpty;

return _PremiumCard(
child: Padding(
padding: const EdgeInsets.all(22),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_SectionTitle(
icon: Icons.person_search_rounded,
title: 'Student',
subtitle:
'Search for the student making this payment.',
badge: hasStudent
? 'Student selected'
    : 'Required',
badgePositive: hasStudent,
),

const SizedBox(height: 18),

Container(
decoration: BoxDecoration(
color: const Color(0xFFF7F8FC),
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
),
child: TextField(
controller: searchController,
onChanged: (q) {
if (q.isEmpty) {
value.emptysearchResults();
} else {
value.searchStudents(q);
}

setState(() {});
},
textInputAction: TextInputAction.search,
decoration: InputDecoration(
hintText:
'Search by student name, ID or admission number...',
hintStyle: const TextStyle(
color: Color(0xFF98A2B3),
fontSize: 12,
),
prefixIcon: Container(
margin: const EdgeInsets.all(8),
width: 38,
height: 38,
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(10),
),
child: const Icon(
Icons.search_rounded,
size: 20,
color: Color(0xFF315CF6),
),
),
suffixIcon:
searchController.text.isNotEmpty
? IconButton(
onPressed: () {
searchController.clear();
value.emptysearchResults();
setState(() {});
},
icon: const Icon(
Icons.close_rounded,
size: 18,
),
)
    : null,
border: InputBorder.none,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 8,
vertical: 17,
),
),
),
),

if (value.searchResults.isNotEmpty) ...[
const SizedBox(height: 10),
_buildSearchResults(value),
],

if (hasStudent) ...[
const SizedBox(height: 16),
...value.selectedStudents.map(
(student) => _buildSelectedStudent(
value,
student,
),
),
],
],
),
),
);
}

Widget _buildSearchResults(Myprovider value) {
return Container(
constraints: const BoxConstraints(
maxHeight: 290,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: const Color(0xFFE4E7EC),
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.04),
blurRadius: 20,
offset: const Offset(0, 7),
),
],
),
child: ListView.separated(
shrinkWrap: true,
padding: const EdgeInsets.symmetric(
vertical: 5,
),
itemCount: value.searchResults.length,
separatorBuilder: (_, __) =>
const Divider(
height: 1,
indent: 68,
color: Color(0xFFF0F2F5),
),
itemBuilder: (context, index) {
final student =
value.searchResults[index];

final isSelected = value.selectedStudents.any(
(s) => s.studentid == student.studentid,
);

return Material(
color: Colors.transparent,
child: InkWell(
onTap: () {
value.selectedStudents.clear();
value.addStudent(student);
searchController.clear();
value.emptysearchResults();

setState(() {});
},
child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 13,
vertical: 11,
),
child: Row(
children: [
_StudentAvatar(
name: student.name ?? '',
selected: isSelected,
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
student.name ?? '',
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
),
const SizedBox(height: 4),
Text(
'ID: ${student.studentid}',
style: const TextStyle(
fontSize: 10.5,
color: Color(0xFF667085),
),
),
],
),
),
Text(
'${student.level ?? ''}',
style: const TextStyle(
fontSize: 10,
fontWeight: FontWeight.w700,
color: Color(0xFF667085),
),
),
const SizedBox(width: 12),
Icon(
isSelected
? Icons.check_circle_rounded
    : Icons.arrow_forward_ios_rounded,
size: isSelected ? 19 : 12,
color: isSelected
? const Color(0xFF12B76A)
    : const Color(0xFF98A2B3),
),
],
),
),
),
);
},
),
);
}

Widget _buildSelectedStudent(
Myprovider value,
dynamic student,
) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Color(0xFFEEF4FF),
Color(0xFFF5F8FF),
],
),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFD6E0FF),
),
),
child: Row(
children: [
_StudentAvatar(
name: student.name ?? '',
selected: true,
large: true,
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Flexible(
child: Text(
student.name ?? '',
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w900,
color: Color(0xFF101828),
),
),
),
const SizedBox(width: 8),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 7,
vertical: 3,
),
decoration: BoxDecoration(
color: const Color(0xFFECFDF3),
borderRadius:
BorderRadius.circular(20),
),
child: const Text(
'VERIFIED',
style: TextStyle(
color: Color(0xFF039855),
fontSize: 8,
fontWeight: FontWeight.w900,
letterSpacing: .5,
),
),
),
],
),
const SizedBox(height: 6),
Text(
'Student ID: ${student.studentid}',
style: const TextStyle(
fontSize: 10.5,
color: Color(0xFF667085),
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 3),
Text(
'${student.level ?? ''}  •  ${student.yeargroup ?? ''}',
style: const TextStyle(
fontSize: 10.5,
color: Color(0xFF667085),
),
),
],
),
),
IconButton(
tooltip: 'Change student',
onPressed: () {
value.removeStudent(
student.studentid,
);
setState(() {});
},
icon: const Icon(
Icons.swap_horiz_rounded,
color: Color(0xFF315CF6),
),
),
],
),
);
}

// ============================================================
// PAYMENT
// ============================================================

Widget _buildPaymentSection(
BuildContext context,
Myprovider value,
) {
return _PremiumCard(
child: Padding(
padding: const EdgeInsets.all(22),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_SectionTitle(
icon: Icons.payments_rounded,
title: 'Payment Details',
subtitle:
'Specify what the student is paying for and how the payment was received.',
badge: selectedpaymentmethod ??
'Payment method',
badgePositive:
selectedpaymentmethod != null,
),

const SizedBox(height: 22),

// ====================================================
// AMOUNT
// ====================================================

_FieldLabel(
label: 'Amount Received',
requiredField: true,
),

const SizedBox(height: 8),

Container(
decoration: BoxDecoration(
color: const Color(0xFFF8FAFF),
borderRadius: BorderRadius.circular(17),
border: Border.all(
color: const Color(0xFFD6DEFF),
),
),
child: TextFormField(
controller: accountController,
inputFormatters: [
FilteringTextInputFormatter.allow(
RegExp(r'^\d+\.?\d{0,2}'),
),
],
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
style: const TextStyle(
fontSize: 30,
fontWeight: FontWeight.w900,
color: Color(0xFF101828),
letterSpacing: -.7,
),
decoration: InputDecoration(
prefixIcon: const Padding(
padding: EdgeInsets.only(
left: 18,
right: 5,
),
child: Center(
widthFactor: 1,
child: Text(
'GH₵',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.w800,
color: Color(0xFF315CF6),
),
),
),
),
hintText: '0.00',
hintStyle: const TextStyle(
color: Color(0xFFD0D5DD),
fontSize: 30,
fontWeight: FontWeight.w900,
),
suffixText: 'GHS',
suffixStyle: const TextStyle(
color: Color(0xFF98A2B3),
fontSize: 10,
fontWeight: FontWeight.w800,
),
border: InputBorder.none,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 19,
),
),
validator: (value) =>
value == null ||
value.trim().isEmpty
? 'Amount is required'
    : null,
),
),

const SizedBox(height: 11),

// QUICK AMOUNTS
Wrap(
spacing: 8,
runSpacing: 8,
children: [
_QuickAmount(
amount: 50,
onTap: () =>
_setAmount('50'),
),
_QuickAmount(
amount: 100,
onTap: () =>
_setAmount('100'),
),

_QuickAmount(
amount: 200,
onTap: () =>
_setAmount('200'),
),_QuickAmount(
amount: 300,
onTap: () =>
_setAmount('300'),
),_QuickAmount(
amount: 400,
onTap: () =>
_setAmount('400'),
),
_QuickAmount(
amount: 500,
onTap: () =>
_setAmount('500'),
),
_QuickAmount(
amount: 1000,
onTap: () =>
_setAmount('1000'),
),
],
),

const SizedBox(height: 24),

// ====================================================
// PAYMENT GRID
// ====================================================

LayoutBuilder(
builder: (context, constraints) {
final compact =
constraints.maxWidth < 520;

if (compact) {
return Column(
children: [
_buildPaymentMethod(
context,
value,
),
const SizedBox(height: 14),
_buildReceivingAccount(
context,
value,
),
const SizedBox(height: 14),
_buildFee(value),
const SizedBox(height: 14),
_buildTerm(value),
],
);
}

return Column(
children: [
Row(
children: [
Expanded(
child: _buildPaymentMethod(
context,
value,
),
),
const SizedBox(width: 14),
Expanded(
child:
_buildReceivingAccount(
context,
value,
),
),
],
),
const SizedBox(height: 14),
Row(
children: [
Expanded(
child: _buildFee(value),
),
const SizedBox(width: 14),
Expanded(
child: _buildTerm(value),
),
],
),
],
);
},
),
],
),
),
);
}

Widget _buildPaymentMethod(
BuildContext context,
Myprovider value,
) {
return DropdownWidget.buildDropdown(value: selectedpaymentmethod != null && value.paymethodlist.any(
(e) =>
e.name ==
selectedpaymentmethod,
)
? selectedpaymentmethod
    : null,
items: value.paymethodlist
    .map((e) => e.name)
    .toList(),
label: 'Payment Method',
fillColor: Colors.white,
onChanged: (v) async {
setState(() {
selectedpaymentmethod = v;
selectedLinkedAccount = null;
});

if (v != null) {
await value.fetchLinkedAccounts(v);
}

if (mounted) {
setState(() {});
}
},
validatorMsg: 'Select Payment Method', dropdownContext: context,
);
}

Widget _buildReceivingAccount(
BuildContext context,
Myprovider value,
) {
if (value.linkedAccounts.isEmpty) {
return _InactiveField(
label: 'Receiving Account',
text: selectedpaymentmethod == null
? 'Select payment method first'
    : 'No linked account required',
icon: Icons.account_balance_wallet_outlined,
);
}

return DropdownWidget.buildDropdown(
value: selectedLinkedAccount,
items: value.linkedAccounts
    .map(
(acc) => acc["name"]!,
)
    .toList(),
label: 'Receiving Account',
fillColor: Colors.white,
onChanged: (v) {
setState(() {
selectedLinkedAccount = v;
});
},
validatorMsg:
'Select Receiving Account', dropdownContext: context,
);
}

Widget _buildFee(Myprovider value) {
return DropdownWidget.buildDropdown(
value: selectedfee,
items: value.fees
    .map((e) => e.name)
    .toList(),
label: 'Fee Type',
fillColor: Colors.white,
onChanged: (v) {
setState(() {
selectedfee = v;

if (selectedTerm != null &&
v != null) {
noteController.text =
'Being $v payment for $selectedTerm term';
}
});
},
validatorMsg: 'Select Fees', dropdownContext: context,
);
}

Widget _buildTerm(Myprovider value) {
return DropdownWidget.buildDropdown(
value: selectedTerm,
items: value.terms
    .map((e) => e.name)
    .toList(),
label: 'Academic Term',
fillColor: Colors.white,
onChanged: (v) {
if (v != null) {
final nn =
'Being $selectedfee payment for $v term';

noteController.text = nn;
}

setState(() {
selectedTerm = v;
});
},
validatorMsg: 'Select Term', dropdownContext: context,
);
}

void _setAmount(String amount) {
accountController.text = amount;
accountController.selection =
TextSelection.fromPosition(
TextPosition(
offset: accountController.text.length,
),
);
setState(() {});
}

// ============================================================
// NOTE
// ============================================================

Widget _buildNoteSection() {
return _PremiumCard(
child: Padding(
padding: const EdgeInsets.all(22),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_SectionTitle(
icon: Icons.notes_rounded,
title: 'Payment Note',
subtitle:
'Add a description for the transaction.',
),

const SizedBox(height: 17),

TextFormField(
controller: noteController,
maxLines: 3,
keyboardType: TextInputType.text,
decoration: InputDecoration(
hintText:
'Payment description or additional note...',
hintStyle: const TextStyle(
color: Color(0xFF98A2B3),
fontSize: 12,
),
filled: true,
fillColor: const Color(0xFFF8F9FC),
contentPadding:
const EdgeInsets.all(15),
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(13),
borderSide: const BorderSide(
color: Color(0xFFE4E7EC),
),
),
enabledBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(13),
borderSide: const BorderSide(
color: Color(0xFFE4E7EC),
),
),
focusedBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(13),
borderSide: const BorderSide(
color: Color(0xFF315CF6),
width: 1.4,
),
),
),
validator: (value) =>
value == null ||
value.trim().isEmpty
? 'Note is required'
    : null,
),
],
),
),
);
}

// ============================================================
// SUMMARY
// ============================================================

Widget _buildSummarySection(
BuildContext context,
Myprovider value,
) {
final amount =
double.tryParse(
accountController.text.trim(),
) ??
0;

final studentName =
value.selectedStudents.isNotEmpty
? value.selectedStudents.first.name ??
''
    : 'No student selected';

final hasStudent =
value.selectedStudents.isNotEmpty;

return _PremiumCard(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 39,
height: 39,
decoration: BoxDecoration(
color: const Color(0xFFECFDF3),
borderRadius:
BorderRadius.circular(11),
),
child: const Icon(
Icons.receipt_long_rounded,
color: Color(0xFF12B76A),
size: 20,
),
),
const SizedBox(width: 11),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Review Payment',
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w900,
color: Color(0xFF101828),
),
),
SizedBox(height: 3),
Text(
'Check before receiving',
style: TextStyle(
color: Color(0xFF98A2B3),
fontSize: 10,
),
),
],
),
),
],
),

const SizedBox(height: 18),

// TOTAL
Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
17,
16,
17,
18,
),
decoration: BoxDecoration(
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFF101828),
Color(0xFF182B4A),
],
),
borderRadius:
BorderRadius.circular(17),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'AMOUNT TO RECEIVE',
style: TextStyle(
color: Color(0xFF98A2B3),
fontSize: 9,
fontWeight: FontWeight.w800,
letterSpacing: 1,
),
),
const SizedBox(height: 7),
FittedBox(
alignment: Alignment.centerLeft,
fit: BoxFit.scaleDown,
child: Text(
'GH₵ ${amount.toStringAsFixed(2)}',
style: const TextStyle(
color: Colors.white,
fontSize: 29,
fontWeight: FontWeight.w900,
letterSpacing: -.8,
),
),
),
],
),
),

const SizedBox(height: 17),

_SummaryStudent(
name: studentName,
selected: hasStudent,
),

const SizedBox(height: 13),

const Divider(
height: 1,
color: Color(0xFFE4E7EC),
),

const SizedBox(height: 10),

_ReviewRow(
icon: Icons.receipt_outlined,
label: 'Receipt',
value:
receiptNumberController.text.isEmpty
? 'Generating...'
    : receiptNumberController.text,
),

_ReviewRow(
icon: Icons.category_outlined,
label: 'Fee',
value: selectedfee ??
'Not selected',
),

_ReviewRow(
icon: Icons.calendar_month_outlined,
label: 'Term',
value: selectedTerm ??
'Not selected',
),

_ReviewRow(
icon: Icons.payments_outlined,
label: 'Method',
value:
selectedpaymentmethod ??
'Not selected',
),

if (selectedLinkedAccount != null)
_ReviewRow(
icon:
Icons.account_balance_outlined,
label: 'Account',
value:
selectedLinkedAccount!,
),

const SizedBox(height: 14),

// RECEIVE BUTTON
SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
onPressed: () async {
await _receivePayment(
context,
value,
);
},
style: ElevatedButton.styleFrom(
backgroundColor:
const Color(0xFF12B76A),
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(13),
),
),
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: const [
Icon(
Icons.check_circle_rounded,
size: 20,
),
SizedBox(width: 9),
Text(
'Receive Payment',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w800,
),
),
],
),
),
),

const SizedBox(height: 9),

SizedBox(
width: double.infinity,
height: 44,
child: OutlinedButton.icon(
onPressed: () {
context.go(Routes.receipt);
},
icon: const Icon(
Icons.print_outlined,
size: 17,
),
label: const Text(
'Print Receipt',
style: TextStyle(
fontSize: 11.5,
fontWeight: FontWeight.w700,
),
),
style: OutlinedButton.styleFrom(
foregroundColor:
const Color(0xFF344054),
side: const BorderSide(
color: Color(0xFFD0D5DD),
),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(11),
),
),
),
),

const SizedBox(height: 5),

TextButton(
onPressed: () {
context.go(
Routes.feepaymentview,
);
},
child: const Text(
'View Previous Payments',
style: TextStyle(
color: Color(0xFF315CF6),
fontSize: 11,
fontWeight: FontWeight.w700,
),
),
),
],
),
),
);
}

// ============================================================
// RECEIVE PAYMENT — BUSINESS LOGIC PRESERVED
// ============================================================

Future<void> _receivePayment(
BuildContext context,
Myprovider value,
) async {
if (!_formKey.currentState!.validate()) {
return;
}

if (value.selectedStudents.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please select a student first.',
),
backgroundColor: Colors.red,
),
);
return;
}

final progress = ProgressHUD.of(context);

progress?.show();

try {
String amount =
accountController.text.trim();

String note =
noteController.text.trim();

for (var student
in value.selectedStudents) {
String id =
receiptNumberController.text
    .trim()
    .toString();

final dataexist = await value.db
    .collection("feepayment")
    .doc(id)
    .get();

if (dataexist.exists) {
final existingData =
dataexist.data()
as Map<String, dynamic>;

final existingFees =
Map<String, dynamic>.from(
existingData["fees"] ?? {},
);

if (existingData['studentID'] !=
student.studentid) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
"Receipt ID $id already exists for another student.",
),
backgroundColor: Colors.red,
),
);

progress?.dismiss();
return;
}

// Only add if fee does not already exist
else if (!existingFees.containsKey(
selectedfee,
)) {
existingFees[
selectedfee.toString()] =
double.tryParse(amount) ?? 0;

await value.db
    .collection("feepayment")
    .doc(id)
    .update({
"fees": existingFees,
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
"Fee '$selectedfee' added to Receipt $id",
),
backgroundColor:
Colors.green,
),
);
} else {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
"Fee '$selectedfee' already exists in Receipt $id",
),
backgroundColor:
Colors.orange,
),
);
}

progress?.dismiss();
return;
}

final data = FeePaymentModel(
level: student.level,
yeargroup: student.yeargroup,
activityType: "Fee Payment",
term: selectedTerm.toString(),
schoolId: value.schoolid,
dateCreated: DateTime.now(),
studentId: student.studentid,
studentName: student.name ?? "",
ledgerid: id,
paymentmethod:
selectedpaymentmethod ?? '',
receivedaccount:
selectedLinkedAccount ?? '',
note: note,
staff: value.name,
fees: {
selectedfee.toString():
double.tryParse(amount) ?? 0,
},
).toJson();

await value.db
    .collection("feepayment")
    .doc(id)
    .set(data);
}

progress?.dismiss();

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Payment Received completed",
),
backgroundColor: Colors.green,
),
);

value.clearSelectedStudents();
accountController.clear();

selectedfee = null;
selectedTerm = null;
selectedpaymentmethod = null;
selectedLinkedAccount = null;

value.linkedAccounts.clear();

await value.generatereceiptnumber();

receiptNumberController.text =
value.receiptno;

setState(() {});
} catch (e) {
progress?.dismiss();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Failed: $e",
),
backgroundColor: Colors.red,
),
);
}
}

// ============================================================
// CASHIER
// ============================================================

Widget _buildCashierCard(Myprovider value) {
return _PremiumCard(
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [
Container(
width: 44,
height: 44,
decoration: BoxDecoration(
color: const Color(0xFFEFF2FF),
borderRadius:
BorderRadius.circular(13),
),
child: const Icon(
Icons.person_rounded,
color: Color(0xFF315CF6),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'CURRENT CASHIER',
style: TextStyle(
fontSize: 8.5,
fontWeight: FontWeight.w800,
letterSpacing: .7,
color: Color(0xFF98A2B3),
),
),
const SizedBox(height: 4),
Text(
value.name.isEmpty
? 'Current staff'
    : value.name,
style: const TextStyle(
fontSize: 12.5,
fontWeight: FontWeight.w800,
color: Color(0xFF101828),
),
),
],
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 9,
vertical: 6,
),
decoration: BoxDecoration(
color: const Color(0xFFECFDF3),
borderRadius:
BorderRadius.circular(20),
),
child: const Row(
children: [
Icon(
Icons.verified_rounded,
color: Color(0xFF12B76A),
size: 13,
),
SizedBox(width: 4),
Text(
'ACTIVE',
style: TextStyle(
color: Color(0xFF039855),
fontSize: 8,
fontWeight: FontWeight.w900,
),
),
],
),
),
],
),
),
);
}

// ============================================================
// SECURITY / HELP
// ============================================================

Widget _buildSecurityCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: const Color(0xFF101828),
borderRadius: BorderRadius.circular(17),
),
child: const Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.shield_outlined,
color: Color(0xFF98A2B3),
size: 20,
),
SizedBox(width: 11),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Cashier verification',
style: TextStyle(
color: Colors.white,
fontSize: 11.5,
fontWeight: FontWeight.w800,
),
),
SizedBox(height: 5),
Text(
'Always confirm the student, fee type, amount and receiving account before completing the transaction.',
style: TextStyle(
color: Color(0xFF98A2B3),
fontSize: 9.5,
height: 1.5,
),
),
],
),
),
],
),
);
}
}

// ================================================================
// COMPONENTS
// ================================================================

class _PremiumCard extends StatelessWidget {
final Widget child;

const _PremiumCard({
required this.child,
});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
border: Border.all(
color: const Color(0xFFE6E9EF),
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.025),
blurRadius: 18,
offset: const Offset(0, 5),
),
],
),
child: child,
);
}
}

class _SectionTitle extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
final String? badge;
final bool badgePositive;

const _SectionTitle({
required this.icon,
required this.title,
required this.subtitle,
this.badge,
this.badgePositive = false,
});

@override
Widget build(BuildContext context) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: const Color(0xFFEFF2FF),
borderRadius:
BorderRadius.circular(12),
),
child: Icon(
icon,
color: const Color(0xFF315CF6),
size: 21,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Flexible(
child: Text(
title,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w900,
color: Color(0xFF101828),
),
),
),
if (badge != null) ...[
const SizedBox(width: 8),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 7,
vertical: 4,
),
decoration: BoxDecoration(
color: badgePositive
? const Color(0xFFECFDF3)
    : const Color(0xFFF2F4F7),
borderRadius:
BorderRadius.circular(20),
),
child: Text(
badge!,
style: TextStyle(
fontSize: 8,
fontWeight: FontWeight.w800,
color: badgePositive
? const Color(0xFF039855)
    : const Color(0xFF667085),
),
),
),
],
],
),
const SizedBox(height: 4),
Text(
subtitle,
style: const TextStyle(
color: Color(0xFF98A2B3),
fontSize: 10.5,
height: 1.4,
),
),
],
),
),
],
);
}
}

class _FieldLabel extends StatelessWidget {
final String label;
final bool requiredField;

const _FieldLabel({
required this.label,
this.requiredField = false,
});

@override
Widget build(BuildContext context) {
return Row(
children: [
Text(
label,
style: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.w800,
color: Color(0xFF344054),
),
),
if (requiredField)
const Padding(
padding: EdgeInsets.only(left: 3),
child: Text(
'*',
style: TextStyle(
color: Color(0xFFF04438),
fontWeight: FontWeight.w900,
),
),
),
],
);
}
}

class _StudentAvatar extends StatelessWidget {
final String name;
final bool selected;
final bool large;

const _StudentAvatar({
required this.name,
required this.selected,
this.large = false,
});

@override
Widget build(BuildContext context) {
final size = large ? 52.0 : 42.0;

String letter = '';

if (name.trim().isNotEmpty) {
letter = name.trim()[0].toUpperCase();
}

return Container(
width: size,
height: size,
decoration: BoxDecoration(
color: selected
? const Color(0xFF315CF6)
    : const Color(0xFFEFF2FF),
borderRadius:
BorderRadius.circular(
large ? 15 : 12,
),
),
child: Center(
child: letter.isEmpty
? Icon(
Icons.person_rounded,
size: large ? 25 : 20,
color: selected
? Colors.white
    : const Color(0xFF315CF6),
)
    : Text(
letter,
style: TextStyle(
color: selected
? Colors.white
    : const Color(0xFF315CF6),
fontSize: large ? 20 : 16,
fontWeight: FontWeight.w900,
),
),
),
);
}
}

class _QuickAmount extends StatelessWidget {
final double amount;
final VoidCallback onTap;

const _QuickAmount({
required this.amount,
required this.onTap,
});

@override
Widget build(BuildContext context) {
return Material(
color: const Color(0xFFF2F4F7),
borderRadius: BorderRadius.circular(9),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(9),
child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
child: Text(
'GH₵ ${amount.toStringAsFixed(0)}',
style: const TextStyle(
color: Color(0xFF475467),
fontSize: 10,
fontWeight: FontWeight.w800,
),
),
),
),
);
}
}

class _InactiveField extends StatelessWidget {
final String label;
final String text;
final IconData icon;

const _InactiveField({
required this.label,
required this.text,
required this.icon,
});

@override
Widget build(BuildContext context) {
return InputDecorator(
decoration: InputDecoration(
labelText: label,
filled: true,
fillColor: const Color(0xFFF8F9FC),
prefixIcon: Icon(
icon,
size: 19,
color: const Color(0xFF98A2B3),
),
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(12),
borderSide: const BorderSide(
color: Color(0xFFE4E7EC),
),
),
enabledBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(12),
borderSide: const BorderSide(
color: Color(0xFFE4E7EC),
),
),
),
child: Text(
text,
style: const TextStyle(
fontSize: 11,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w600,
),
),
);
}
}

class _SummaryStudent extends StatelessWidget {
final String name;
final bool selected;

const _SummaryStudent({
required this.name,
required this.selected,
});

@override
Widget build(BuildContext context) {
return Row(
children: [
Container(
width: 34,
height: 34,
decoration: BoxDecoration(
color: selected
? const Color(0xFFECFDF3)
    : const Color(0xFFF2F4F7),
borderRadius:
BorderRadius.circular(10),
),
child: Icon(
selected
? Icons.person_rounded
    : Icons.person_outline_rounded,
size: 17,
color: selected
? const Color(0xFF12B76A)
    : const Color(0xFF98A2B3),
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'STUDENT',
style: TextStyle(
fontSize: 8,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w800,
letterSpacing: .6,
),
),
const SizedBox(height: 3),
Text(
name,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 11.5,
fontWeight: FontWeight.w800,
color: Color(0xFF344054),
),
),
],
),
),
],
);
}
}

class _ReviewRow extends StatelessWidget {
final IconData icon;
final String label;
final String value;

const _ReviewRow({
required this.icon,
required this.label,
required this.value,
});

@override
Widget build(BuildContext context) {
return Padding(
padding:
const EdgeInsets.symmetric(vertical: 8),
child: Row(
children: [
Icon(
icon,
size: 15,
color: const Color(0xFF98A2B3),
),
const SizedBox(width: 9),
Expanded(
child: Text(
label,
style: const TextStyle(
fontSize: 10,
color: Color(0xFF98A2B3),
fontWeight: FontWeight.w600,
),
),
),
const SizedBox(width: 10),
Flexible(
child: Text(
value,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
textAlign: TextAlign.right,
style: const TextStyle(
fontSize: 10.5,
color: Color(0xFF344054),
fontWeight: FontWeight.w800,
),
),
),
],
),
);
}
}


class _TopBarStatus extends StatefulWidget {
  final String receipt;
  final bool compact;
  final Myprovider value;
  final TextEditingController receiptNumberController;

  const _TopBarStatus({
    required this.receipt,
    required this.value,
    required this.receiptNumberController,
    this.compact = false,
  });

  @override
  State<_TopBarStatus> createState() => _TopBarStatusState();
}

class _TopBarStatusState extends State<_TopBarStatus> {
  bool _loading = false;

  Future<void> _generateNewReceipt() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      await widget.value.generatereceiptnumber();

      widget.receiptNumberController.text =
          widget.value.receiptno;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate receipt number: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Click to generate a new receipt number',
      child: InkWell(
        onTap: _generateNewReceipt,
        borderRadius: BorderRadius.circular(
          widget.compact ? 9 : 10,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 9 : 11,
            vertical: widget.compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(
              widget.compact ? 9 : 10,
            ),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.compact ? 25 : 27,
                height: widget.compact ? 25 : 27,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: _loading
                    ? const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                      Color(0xFF315CF6),
                    ),
                  ),
                )
                    : Icon(
                  Icons.receipt_outlined,
                  size: widget.compact ? 13 : 15,
                  color: const Color(0xFF315CF6),
                ),
              ),

              SizedBox(
                width: widget.compact ? 6 : 7,
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECEIPT',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF98A2B3),
                      letterSpacing: .5,
                    ),
                  ),

                  const SizedBox(height: 2),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                      widget.compact ? 100 : 130,
                    ),
                    child: Text(
                      _loading
                          ? 'Generating...'
                          : widget.receipt.isEmpty
                          ? 'Generating...'
                          : widget.receipt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF344054),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.refresh_rounded,
                size: 13,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StepIndicator extends StatelessWidget {
final String number;
final String label;
final bool active;

const _StepIndicator({
required this.number,
required this.label,
required this.active,
});

@override
Widget build(BuildContext context) {
return Column(
children: [
Container(
width: 27,
height: 27,
decoration: BoxDecoration(
color: active
? const Color(0xFF315CF6)
    : const Color(0xFFF2F4F7),
shape: BoxShape.circle,
),
child: Center(
child: Text(
number,
style: TextStyle(
fontSize: 8,
fontWeight: FontWeight.w900,
color: active
? Colors.white
    : const Color(0xFF98A2B3),
),
),
),
),
const SizedBox(height: 4),
Text(
label,
style: TextStyle(
fontSize: 8,
fontWeight: FontWeight.w700,
color: active
? const Color(0xFF344054)
    : const Color(0xFF98A2B3),
),
),
],
);
}
}

class _StepLine extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Container(
width: 28,
height: 1,
margin: const EdgeInsets.only(
left: 7,
right: 7,
bottom: 16,
),
color: const Color(0xFFD0D5DD),
);
}
}



