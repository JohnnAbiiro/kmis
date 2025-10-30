import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/expenseModel.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import '../widgets/dropdown.dart';

// ... keep your imports

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
  bool _showExpenseContainer = false;

  String? receiptNumber;
  String? selectedExpense;
  String? selectedfee;
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
    accountController.dispose();
    expensename.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    return ProgressHUD(
      child: Builder(builder: (context) {
        return Consumer<Myprovider>(
          builder: (BuildContext context, value, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF00273a),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go(Routes.dashboard),
                ),
                title: const Text(
                  'SCHOOL EXPENSE ENTRY',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                    builder: (context, constraints){
                      bool isWideScreen = constraints.maxWidth > 500;
                      return Center(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 400),
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
                                            receiptNumberController.text =
                                                value.receiptno;
                                          },
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Supplier Dropdown (always show)
                                    buildDropdown(value: selectedSupplier, items: value.supplierList.map((e) => e.name).toList(),
                                      label: "Supplier",
                                      fillColor: inputFill,
                                      onChanged: (v) {
                                        setState(() {
                                          selectedSupplier = v;
                                        });
                                      },
                                      validatorMsg: "Select Supplier",
                                    ),
                                    const SizedBox(height: 10),


                                    TextField(
                                      controller: expensename,
                                      decoration: const InputDecoration(
                                        labelText: "Expense Name",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    TextFormField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      controller: accountController,
                                      decoration: const InputDecoration(
                                        labelText: "Billed Amount",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) => value == null || value.trim().isEmpty
                                          ? "Amount is required"
                                          : null,
                                    ),
                                    const SizedBox(height: 20),

                                    buildDropdown(value: selectedExpenseType, items: expenseTypes, label: "Expense Type",
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
                                    const SizedBox(height: 10),

                                    // Show only if Paid 👇
                                    if (selectedExpenseType == "Paid") ...[
                                      buildDropdown(
                                        value: selectedpaymentmethod != null &&
                                            value.paymethodlist.any((e) => e.name == selectedpaymentmethod)
                                            ? selectedpaymentmethod
                                            : null,
                                        items: value.paymethodlist.map((e) => e.name).toList(),
                                        label: "Payment Method",
                                        fillColor: inputFill,
                                        onChanged: (v) async {
                                          setState(() {
                                            selectedpaymentmethod = v;
                                            selectedLinkedAccount = null;
                                          });
                                          if (v != null) {
                                            await value.fetchLinkedAccounts(v);
                                          }
                                        },
                                        validatorMsg: 'Select Payment Method',
                                      ),
                                      const SizedBox(height: 10),

                                      if (value.linkedAccounts.isNotEmpty)
                                        buildDropdown(
                                          value: selectedLinkedAccount,
                                          items: value.linkedAccounts.map((acc) => acc["name"]!).toList(),
                                          label: "Receiving Account",
                                          fillColor: inputFill,
                                          onChanged: (v) {
                                            setState(() {
                                              selectedLinkedAccount = v;
                                            });
                                          },
                                          validatorMsg: "Select Receiving Account",
                                        ),
                                      if (value.linkedAccounts.isNotEmpty)
                                        const SizedBox(height: 10),
                                    ],

                                    // Expense category
                                    buildDropdown(
                                      value: selectedExpense,
                                      items: value.expenselist.map((e) => e.name).toList(),
                                      label: "Expense Category",
                                      fillColor: inputFill,
                                      onChanged: (v) {
                                        String nn = "Being expense made on ${expensename.text.trim()}";
                                        noteController.text = nn;
                                        setState(() => selectedExpense = v);
                                      },
                                      validatorMsg: "Select Expense Category",
                                    ),
                                    const SizedBox(height: 10),

                                    TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: noteController,
                                      decoration: const InputDecoration(
                                        labelText: "Note (Optional)",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    buildDropdown(value: selectedTerm, items: value.terms.map((e) => e.name).toList(), label: "Select Your Term",
                                      fillColor: inputFill,
                                      onChanged: (v) {
                                        setState(() {
                                          selectedTerm = v;
                                        });
                                      },
                                      validatorMsg: "Select Expense Type",
                                    ),
                                    const SizedBox(height: 20),


                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00496d),
                                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              final progress = ProgressHUD.of(context);
                                              progress!.show();

                                              try {
                                                String id = receiptNumberController.text.trim();
                                                final dataexist = await value.db.collection("expense").doc(id).get();

                                                if (dataexist.exists) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Receipt ID $id already exists."),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  progress.dismiss();
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
                                                  paymentmethod: selectedExpenseType == "Paid"
                                                      ? selectedpaymentmethod ?? ''
                                                      : '',
                                                  paidAccount: selectedExpenseType == "Paid"
                                                      ? selectedLinkedAccount ?? ''
                                                      : '',
                                                  note: noteController.text.trim(),
                                                  staff: value.name,
                                                  amount: accountController.text.trim(),
                                                  expenseType: selectedExpenseType ?? "Unpaid",
                                                  expenseName: selectedExpense.toString(),
                                                ).toJson();

                                                await value.db.collection("expense").doc(id).set(data);

                                                progress.dismiss();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Expense saved."),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );

                                                // reset form
                                                accountController.clear();
                                                expensename.clear();
                                                noteController.clear();
                                                selectedfee = null;
                                                selectedExpense = null;
                                                selectedpaymentmethod = null;
                                                selectedLinkedAccount = null;
                                                selectedExpenseType = null;
                                                value.linkedAccounts.clear();
                                                setState(() {});
                                              } catch (e) {
                                                progress.dismiss();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Failed: $e"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.save, color: Colors.white),
                                          label: const Text(
                                            "Save Expense",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00496d),
                                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                          ),
                                          onPressed: () {
                                            context.go(Routes.expenseview);
                                          },
                                          icon: const Icon(Icons.save, color: Colors.white),
                                          label: const Text(
                                            "View Expense",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (_showExpenseContainer)
                              Container(
                                color: Colors.white,
                                width: 700,
                                height: 400,
                                child: FutureBuilder(
                                    future: FirebaseFirestore.instance.collection('expense').get(),
                                    builder: (context, snapshot){
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text('Error: ${snapshot.error}',
                                              style: const TextStyle(color: Colors.red)),
                                        );
                                      }

                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'No Supplier found.',
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        );
                                      }

                                      final expenseDocs = snapshot.data!.docs;

                                      if (isWideScreen){
                                        return SingleChildScrollView(
                                          child: DataTable(
                                              headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                              border: TableBorder.all(color: Colors.grey.shade300),
                                              columns: [
                                                DataColumn(label: Text('Supplier Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Expense Category', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Expense Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Fee', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Expense Type', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: expenseDocs.map((doc){
                                                final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(data['supplier'] ?? '')),
                                                      DataCell(Text(data['expenseName'] ?? '')),
                                                      DataCell(Text(data['name'] ?? '')),
                                                      DataCell(Text(data['fees'] ?? '')),
                                                      DataCell(Text(data['expenseType'] ?? '')),
                                                    ]
                                                );

                                              }
                                            ).toList(),
                                          )
                                        );
                                      }
                                      else {
                                        return Card();
                                      }
                                    }
                                ),
                              )
                          ],
                        ),
                      );
                    }
                )
              ),
            );
          },
        );
      }),
    );
  }
}

