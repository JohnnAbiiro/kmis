import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/feePaymentModel.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import '../components/receiptpdf.dart';
import '../widgets/dropdown.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class Feepayment extends StatefulWidget {
  const Feepayment({super.key});

  @override
  State<Feepayment> createState() => _FeepaymentState();
}

class _FeepaymentState extends State<Feepayment> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.getdata();
      provider.fetchterms();
      provider.fetchFess();
      provider.paymentmethodslist();
      provider.generatereceiptnumber();
      receiptNumberController.text = provider.receiptno; // update field

    });
  }
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
  void dispose() {
    accountController.dispose();
    searchController.dispose();
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
                title:  Text('SCHOOL FEES PAYMENT', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              body: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                       SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                          child: Padding(
                           padding: const EdgeInsets.all(20),
                           child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
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
                                      onPressed: () async{
                                        await value.generatereceiptnumber(); // call provider method
                                        receiptNumberController.text = value.receiptno; // update field
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    labelText: "Search Student by Name",
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () => value.searchStudents(
                                          searchController.text.trim()),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (q) {
                                    if (q.isEmpty) {
                                      value.emptysearchResults();
                                    } else {
                                      value.searchStudents(q);
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                if (value.searchResults.isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: value.searchResults.length,
                                    itemBuilder: (context, index) {
                                      final student = value.searchResults[index];
                                      return Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 2, color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(student.name ?? ""),
                                          subtitle:
                                          Text("ID: ${student.studentid}"),
                                          trailing: Icon(value.selectedStudents.any((s) =>
                                            s.studentid ==
                                                student.studentid)
                                                ? Icons.check_circle
                                                : Icons.add_circle_outline,
                                            color: value.selectedStudents.any((s) =>
                                            s.studentid ==
                                                student.studentid)
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          onTap: () {
                                            value.selectedStudents.clear();
                                            value.addStudent(student);
                                            searchController.clear();
                                            value.emptysearchResults();

                                          },
                                        ),
                                      );
                                    },
                                  ),
                                if (value.selectedStudents.isNotEmpty)
                                  Column(
                                    children: value.selectedStudents.map(
                                          (s) => Card(
                                        color: Colors.blue[50],
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: ListTile(
                                          title: Text(s.name ?? ""),
                                          subtitle: Text(
                                              "Class: ${s.level}, Year: ${s.yeargroup}"),
                                          trailing: IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red),
                                            onPressed: () {
                                              value.removeStudent(
                                                  s.studentid);
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                  ),

                                const SizedBox(height: 20),

                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  controller: accountController,
                                  decoration: const InputDecoration(
                                    labelText: "Billed Amount",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value == null ||
                                      value.trim().isEmpty
                                      ? "Amount is required"
                                      : null,
                                ),
                                const SizedBox(height: 20),

                                buildDropdown(value: selectedpaymentmethod != null && value.paymethodlist.any((e) => e.name == selectedpaymentmethod)
                                      ? selectedpaymentmethod
                                      : null,
                                  items: value.paymethodlist.map((e) => e.name).toList(),
                                  label: "Payment Method",
                                  fillColor: inputFill,
                                  onChanged: (v) async {
                                    setState(() {
                                      selectedpaymentmethod = v;
                                      selectedLinkedAccount = null; // reset linked account when method changes
                                    });
                                    if (v != null) {
                                      await value.fetchLinkedAccounts(v);
                                    }
                                  },
                                  validatorMsg: 'Select Payment Method',
                                ),

                                const SizedBox(height: 10),

                                if (value.linkedAccounts.isNotEmpty)
                                  buildDropdown(value: selectedLinkedAccount, items: value.linkedAccounts.map((acc) => acc["name"]!).toList(), label: "Receiving Account", fillColor: inputFill, onChanged: (v) {
                                    setState(() {
                                        selectedLinkedAccount = v;
                                      });
                                    },
                                    validatorMsg: "Select Receiving Account",
                                  ),
                                if (value.linkedAccounts.isNotEmpty)

                                  const SizedBox(height: 10),
                                buildDropdown(value: selectedfee, items: value.fees.map((e) => e.name).toList(), label: "FEES", fillColor: inputFill, onChanged: (v) => setState(() => selectedfee = v), validatorMsg: 'Select Fees'),
                                const SizedBox(height: 10),

                                buildDropdown(value: selectedTerm, items: value.terms.map((e) => e.name).toList(), label: "Term", fillColor: inputFill, onChanged: (v) {
                                    String nn="Being $selectedfee payment  for  $v term".toString();
                                     noteController.text=nn;
                                    setState(() => selectedTerm = v);
                                  },
                                  validatorMsg: "Select Term",
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: noteController,
                                  decoration: const InputDecoration(
                                    labelText: "Note (Optional)",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value == null ||
                                      value.trim().isEmpty
                                      ? "Note is required"
                                      : null,
                                ),
                                const SizedBox(height: 20),

                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00496d),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate() &&
                                        value.selectedStudents.isNotEmpty) {
                                      final progress = ProgressHUD.of(context);
                                      progress!.show();

                                      try {
                                        String amount = accountController.text.trim();
                                        String note = noteController.text.trim();

                                        for (var student in value.selectedStudents)
                                        {
                                          String id =receiptNumberController.text.trim().toString();
                                          final dataexist = await value.db.collection("feepayment").doc(id).get();
                                          if (dataexist.exists) {
                                            final existingData = dataexist.data() as Map<String, dynamic>;
                                            final existingFees = Map<String, dynamic>.from(existingData["fees"] ?? {});
                                            if(existingData['studentID']!=student.studentid){
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receipt ID $id already exists for another student."), backgroundColor: Colors.red,));
                                              progress.dismiss();
                                              return;
                                            }

                                            // Only add if fee does not already exist
                                           else if (!existingFees.containsKey(selectedfee)) {
                                              existingFees[selectedfee.toString()] = double.tryParse(amount) ?? 0;
                                              await value.db.collection("feepayment").doc(id).update({"fees": existingFees});
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fee '${selectedfee}' added to Receipt $id"), backgroundColor: Colors.green,));
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Fee '$selectedfee' already exists in Receipt $id"),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                            }

                                            progress.dismiss();
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
                                            paymentmethod: selectedpaymentmethod ?? '',
                                            receivedaccount: selectedLinkedAccount ?? '',
                                            note: note,
                                            staff: value.name,
                                            fees: {
                                              selectedfee.toString(): double.tryParse(amount) ?? 0,
                                            }, // ✅ add first fee
                                          ).toJson();
                                          //await docRef.set(data);
                                          await value.db.collection("feepayment").doc(id).set(data);
                                        }

                                        progress.dismiss();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Received completed"),
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
                                        setState(() {});
                                      } catch (e) {
                                        progress.dismiss();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Failed: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.save,
                                      color: Colors.white),
                                  label: const Text("Save Payment",
                                      style: TextStyle(color: Colors.white)),
                                ),

                                ElevatedButton(onPressed: ()async{
                                  //await value.setreceiptnumber(receiptNumberController.text.trim());

                                  context.go(Routes.receipt);
                                }, child: Text("Print Receipt"))

                              ],
                                                       ),
                                                        ),
                           ),
                                                    ),
                  ),
                     ],
              ),
            );
          },
        );
      }),
    );
  }
}
