import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/expenseModel.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import '../widgets/dropdown.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final receiptNumberController = TextEditingController();
  final accountController = TextEditingController();
  final expensename = TextEditingController();
  final noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedExpense;
  String? selectedSupplier;
  String? selectedTerm;
  String? selectedpaymentmethod;
  String? selectedLinkedAccount;
  String? selectedExpenseType;
  final List<String> expenseTypes = ["Paid", "Unpaid"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.getdata();
      provider.paymentmethodslist();
      provider.fetchexpense();
      provider.fetchsuppliers();
      provider.fetchterms();
      int now = DateTime.now().microsecondsSinceEpoch;
      receiptNumberController.text = "5$now";
    });
  }

  @override
  void dispose() {
    receiptNumberController.dispose();
    accountController.dispose();
    expensename.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final inputFill = colors.surface;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, value, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SCHOOL EXPENSE ENTRY'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: receiptNumberController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Receipt Number",
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    await value.generatereceiptnumber();
                                    receiptNumberController.text = value.receiptno;
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedSupplier,
                              items: value.supplierList.map((e) => e.name).toList(),
                              label: "Supplier",
                              fillColor: inputFill,
                              onChanged: (v) => setState(() => selectedSupplier = v),
                              validatorMsg: "Select Supplier",
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: expensename,
                              decoration: const InputDecoration(
                                labelText: "Expense Name",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              controller: accountController,
                              decoration: const InputDecoration(
                                labelText: "Billed Amount",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedExpenseType,
                              items: expenseTypes,
                              label: "Expense Type",
                              fillColor: inputFill,
                              onChanged: (v) {
                                setState(() {
                                  selectedExpenseType = v;
                                  selectedpaymentmethod = null;
                                  selectedLinkedAccount = null;
                                });
                              },
                              validatorMsg: "Select Expense Type",
                            ),
                            if (selectedExpenseType == "Paid") ...[
                              const SizedBox(height: 16),
                              DropdownWidget.buildDropdown(
                                dropdownContext: context,
                                value: selectedpaymentmethod,
                                items: value.paymethodlist.map((e) => e.name).toList(),
                                label: "Payment Method",
                                fillColor: inputFill,
                                onChanged: (v) async {
                                  setState(() {
                                    selectedpaymentmethod = v;
                                    selectedLinkedAccount = null;
                                  });
                                  if (v != null) await value.fetchLinkedAccounts(v);
                                },
                                validatorMsg: 'Select Payment Method',
                              ),
                              if (value.linkedAccounts.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                DropdownWidget.buildDropdown(
                                  dropdownContext: context,
                                  value: selectedLinkedAccount,
                                  items: value.linkedAccounts.map((acc) => acc["name"]!).toList(),
                                  label: "Receiving Account",
                                  fillColor: inputFill,
                                  onChanged: (v) => setState(() => selectedLinkedAccount = v),
                                  validatorMsg: "Select Receiving Account",
                                ),
                              ],
                            ],
                            const SizedBox(height: 16),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedExpense,
                              items: value.expenselist.map((e) => e.name).toList(),
                              label: "Expense Category",
                              fillColor: inputFill,
                              onChanged: (v) {
                                noteController.text = "Being expense made on ${expensename.text.trim()}";
                                setState(() => selectedExpense = v);
                              },
                              validatorMsg: "Select Expense Category",
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                labelText: "Note (Optional)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedTerm,
                              items: value.terms.map((e) => e.name).toList(),
                              label: "Select Your Term",
                              fillColor: inputFill,
                              onChanged: (v) => setState(() => selectedTerm = v),
                              validatorMsg: "Select Term",
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final progress = ProgressHUD.of(context);
                                        progress!.show();
                                        try {
                                          String id = receiptNumberController.text.trim();
                                          final dataexist = await value.db.collection("expense").doc(id).get();
                                          if (dataexist.exists) {
                                            progress.dismiss();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Receipt ID already exists"), backgroundColor: Colors.red));
                                          }
                                          return;
                                          }
                                          final data = ExpenseModel(
                                            supplier: selectedSupplier ?? '',
                                            name: expensename.text.trim(),
                                            activityType: "Expense Payment",
                                            term: selectedTerm.toString(),
                                            schoolId: value.schoolid,
                                            dateCreated: DateTime.now(),
                                            ledgerid: id,
                                            paymentmethod: selectedExpenseType == "Paid" ? (selectedpaymentmethod ?? '') : '',
                                            paidAccount: selectedExpenseType == "Paid" ? (selectedLinkedAccount ?? '') : '',
                                            note: noteController.text.trim(),
                                            staff: value.name,
                                            fees: accountController.text.trim(),
                                            expenseType: selectedExpenseType ?? "Unpaid",
                                            expenseName: selectedExpense.toString(), 
                                            id: '',
                                          ).toJson();
                                          await value.db.collection("expense").doc(id).set(data);
                                          progress.dismiss();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Expense saved"), backgroundColor: Colors.green));
                                          }
                                          accountController.clear();
                                          expensename.clear();
                                          noteController.clear();
                                          setState(() {
                                            selectedExpense = null;
                                            selectedpaymentmethod = null;
                                            selectedLinkedAccount = null;
                                            selectedExpenseType = null;
                                          });
                                        } catch (e) {
                                          progress.dismiss();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
                                          }
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text("Save Expense", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => Navigator.pushNamed(context, Routes.expenseview),
                                    icon: const Icon(Icons.list_alt),
                                    label: const Text("View Expenses"),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
