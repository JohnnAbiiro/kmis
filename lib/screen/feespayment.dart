import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/feePaymentModel.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import '../widgets/dropdown.dart';
import '../controller/dbmodels/contestantsmodel.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.getdata();
      provider.paymentmethodslist();
      provider.fetchFess();
      provider.fetchterms();
    });
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
    final inputFill = colors.surface;
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SCHOOL FEES PAYMENT'),
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
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: "Search Student by Name",
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () => provider.searchStudents(searchController.text.trim()),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (q) {
                                if (q.isEmpty) {
                                  provider.emptysearchResults();
                                } else {
                                  provider.searchStudents(q);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            if (provider.searchResults.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.searchResults.length,
                                itemBuilder: (context, index) {
                                  final student = provider.searchResults[index];
                                  return ListTile(
                                    title: Text(student.name),
                                    subtitle: Text("ID: ${student.studentid} | Class: ${student.level}"),
                                    trailing: const Icon(Icons.add_circle_outline),
                                    onTap: () {
                                      setState(() {
                                        selectedStudent = student;
                                        provider.emptysearchResults();
                                        searchController.text = student.name;
                                      });
                                    },
                                  );
                                },
                              ),
                            if (selectedStudent != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Selected: ${selectedStudent!.name} (${selectedStudent!.studentid})",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(() => selectedStudent = null),
                                    )
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedpaymentmethod,
                              items: provider.paymethodlist.map((e) => e.name).toList(),
                              label: "Payment Method",
                              fillColor: inputFill,
                              onChanged: (v) async {
                                setState(() {
                                  selectedpaymentmethod = v;
                                  selectedLinkedAccount = null;
                                });
                                if (v != null) {
                                  await provider.fetchLinkedAccounts(v);
                                }
                              },
                              validatorMsg: 'Select Payment Method',
                            ),
                            const SizedBox(height: 10),
                            if (provider.linkedAccounts.isNotEmpty)
                              DropdownWidget.buildDropdown(
                                dropdownContext: context,
                                value: selectedLinkedAccount,
                                items: provider.linkedAccounts.map((acc) => acc["name"]!).toList(),
                                label: "Receiving Account",
                                fillColor: inputFill,
                                onChanged: (v) => setState(() => selectedLinkedAccount = v),
                                validatorMsg: "Select Receiving Account",
                              ),
                            const SizedBox(height: 20),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedfee,
                              items: provider.fees.map((e) => e.name).toList(),
                              label: "Fee Type",
                              fillColor: inputFill,
                              onChanged: (v) => setState(() => selectedfee = v),
                              validatorMsg: 'Select Fees',
                            ),
                            const SizedBox(height: 20),
                            DropdownWidget.buildDropdown(
                              dropdownContext: context,
                              value: selectedTerm,
                              items: provider.terms.map((e) => e.name).toList(),
                              label: "Academic Term",
                              fillColor: inputFill,
                              onChanged: (v) => setState(() => selectedTerm = v),
                              validatorMsg: "Select Term",
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              controller: amountController,
                              decoration: const InputDecoration(
                                labelText: "Amount Paid",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? "Amount is required" : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                labelText: "Payment Note (Optional)",
                                border: OutlineInputBorder(),
                              ),
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
                                      if (_formKey.currentState!.validate() && selectedStudent != null) {
                                        final progress = ProgressHUD.of(context);
                                        progress!.show();
                                        try {
                                          await provider.generatereceiptnumber();
                                          String id = provider.receiptno;
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
                                            fees: {selectedfee.toString(): double.parse(amountController.text.trim())},
                                            level: selectedStudent!.level,
                                            yeargroup: selectedStudent!.yeargroup,
                                            ledgerid: id,
                                            activityType: "Fee Payment",
                                          ).toJson();
                                          
                                          await provider.db.collection("feepayment").doc(id).set(data);
                                          progress.dismiss();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Payment Saved Successfully"), backgroundColor: Colors.green),
                                            );
                                          }
                                          
                                          amountController.clear();
                                          noteController.clear();
                                          searchController.clear();
                                          setState(() {
                                            selectedStudent = null;
                                            selectedfee = null;
                                            selectedTerm = null;
                                          });
                                        } catch (e) {
                                          progress.dismiss();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
                                          );
                                        }
                                      } else if (selectedStudent == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please select a student"), backgroundColor: Colors.orange),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text("Save Payment", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => Navigator.pushNamed(context, Routes.feepaymentview),
                                    icon: const Icon(Icons.list_alt),
                                    label: const Text("View Payments"),
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
