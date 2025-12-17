import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class FeePaymentView extends StatefulWidget {
  const FeePaymentView({super.key});

  @override
  State<FeePaymentView> createState() => _FeePaymentViewState();
}

class _FeePaymentViewState extends State<FeePaymentView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchFeePayment();

    });
  }

  void editFeePaymentDialog(BuildContext context, feepament){
    final _formKey = GlobalKey<FormState>();
    final value = context.read<Myprovider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, modalSetState){
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 15,
                      spreadRadius: 2,
                      color: Colors.black26,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Container(
                          width: 60,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFF00496d)
                          ),
                          child: const Center(
                            child: Text(
                              "Edit Fee Payment Details",
                              style: TextStyle(
                                color: Colors.white,
                                //fontSize: 14,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // buildDropdown(
                        //   value: selectedSupplier,
                        //   items: value.supplierList.map((e) => e.name).toList(),
                        //   label: "Suppliers",
                        //   fillColor: Colors.grey.shade100,
                        //   onChanged: (v) {
                        //     modalSetState(() {
                        //       selectedSupplier = v;
                        //       _supplierController.text = v ?? "";
                        //     });
                        //   },
                        //   validatorMsg: "Select Supplier",
                        // ),
                        //
                        // // customField(
                        // //   controller: _supplierController,
                        // //   label: "Supplier Name",
                        // //   //icon: Icons.person,
                        // //   validator: (v) => v!.isEmpty ? "Name required" : null,
                        // // ),
                        // const SizedBox(height: 12),
                        // buildDropdown(
                        //   value: selectedExpenseType,
                        //   items: expenseTypes,
                        //   label: "Expense Type",
                        //   fillColor: Colors.grey.shade100,
                        //   onChanged: (v) {
                        //     modalSetState(() {
                        //       selectedExpenseType = v;
                        //       _expenseTypeController.text = v ?? "";
                        //       selectedpaymentmethod = null;
                        //       selectedLinkedAccount = null;
                        //     });
                        //   },
                        //   validatorMsg: "Select Expense Type",
                        // ),
                        //
                        // const SizedBox(height: 12),
                        //
                        // if (selectedExpenseType == "Paid") ...[
                        //   buildDropdown(
                        //     value: selectedpaymentmethod != null &&
                        //         value.paymethodlist.any((e) => e.name == selectedpaymentmethod)
                        //         ? selectedpaymentmethod
                        //         : null,
                        //     items: value.paymethodlist.map((e) => e.name).toList(),
                        //     label: "Payment Method",
                        //     fillColor: Colors.grey.shade100,
                        //     onChanged: (v) async {
                        //       modalSetState(() {
                        //         selectedpaymentmethod = v;
                        //         _expensePaymentMethodController.text = v ?? "";
                        //         selectedLinkedAccount = null;
                        //       });
                        //       if (v != null) {
                        //         await value.fetchLinkedAccounts(v);
                        //       }
                        //     },
                        //     validatorMsg: 'Select Payment Method',
                        //   ),
                        //   const SizedBox(height: 10),
                        //
                        //   if (value.linkedAccounts.isNotEmpty)
                        //     buildDropdown(
                        //       value: selectedLinkedAccount,
                        //       items: value.linkedAccounts.map((acc) => acc["name"]!).toList(),
                        //       label: "Receiving Account",
                        //       fillColor: Colors.grey.shade100,
                        //       onChanged: (v) {
                        //         modalSetState(() {
                        //           selectedLinkedAccount = v;
                        //           _expensePaidAccountController.text = v ?? "";
                        //         });
                        //       },
                        //       validatorMsg: "Select Receiving Account",
                        //     ),
                        //   if (value.linkedAccounts.isNotEmpty)
                        //     const SizedBox(height: 12),
                        // ],
                        // //const SizedBox(height: 12),
                        //
                        // customField(
                        //   controller: _expenseCategoryController,
                        //   label: "Expense Category",
                        //   //icon: Icons.phone_android,
                        //   validator: (v) => v!.isEmpty ? "Expense Category required" : null,
                        // ),
                        // const SizedBox(height: 12),
                        //
                        // customField(
                        //   controller: _expenseNameController,
                        //   label: "Expense Name",
                        //   //icon: Icons.phone_android,
                        //   validator: (v) => v!.isEmpty ? "Expense Name required" : null,
                        // ),
                        // const SizedBox(height: 12),
                        //
                        // customField(
                        //   controller: _expenseAmountController,
                        //   label: "Expense Amount",
                        //   //icon: Icons.phone_android,
                        //   validator: (v) => v!.isEmpty ? "Expense Amount required" : null,
                        // ),
                        //
                        // const SizedBox(height: 12),
                        // buildDropdown(
                        //   value: selectedTerm,
                        //   items: value.terms.map((e) => e.name).toList(),
                        //   label: "Select Your Term",
                        //   fillColor: Colors.grey.shade100,
                        //   onChanged: (v) {
                        //     modalSetState(() {
                        //       selectedTerm = v;
                        //       _expenseTermController.text = v ?? "";
                        //     });
                        //   },
                        //   validatorMsg: "Select Expense Type",
                        // ),
                        // const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  foregroundColor: Color(0xFF00496d),
                                  side: const BorderSide(
                                    color: Color(0xFF00496d),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text("Cancel", style: TextStyle(color: Color(0xFF00496d)),),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: const Color(0xFF00496d),
                                ),
                                child: const Text("Update Payment", style: TextStyle(color: Colors.white),),
                                onPressed: () async {
                                  context.read<Myprovider>().fetchFeePayment();
                                  Navigator.pop(context);
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
          builder: (context){
            return Consumer<Myprovider>(
                builder: (BuildContext context, value, Widget? child){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Fee Payment View"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Container(
                                margin: EdgeInsets.all(20),
                                color: Colors.white,
                                //width: 700,
                                //height: 400,
                                child: FutureBuilder(
                                    future: FirebaseFirestore.instance.collection('feepayment').get(),
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
                                            'Not found.',
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        );
                                      }

                                      //final feeDocs = snapshot.data!.docs;
                                      // Future<void> deleteFeePayment(String id) async {
                                      //   try {
                                      //     await FirebaseFirestore.instance.collection('feemayment').doc(id).delete();
                                      //     ScaffoldMessenger.of(context).showSnackBar(
                                      //       const SnackBar(content: Text("deleted successfully")),
                                      //     );
                                      //   } catch (e) {
                                      //     ScaffoldMessenger.of(context).showSnackBar(
                                      //       SnackBar(content: Text("Error deleting: $e")),
                                      //     );
                                      //   }
                                      // }

                                      double total = 0;
                                      for (var doc in snapshot.data!.docs) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        final amount = (data['amount'] ?? 0).toString();
                                        total += double.tryParse(amount) ?? 0;
                                      }

                                      if (isWideScreen){
                                        return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                              border: TableBorder.all(color: Colors.grey.shade300),
                                              columns: [
                                                DataColumn(label: Text('Student Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Student ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Term', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Payment Method', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Received Account', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Ledger ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Level', style: TextStyle(color: Colors.white),)),
                                                //DataColumn(label: Text('Fees', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: value.feepaymentlist.map((doc){

                                                //final data = doc.data() as Map<String, dynamic>;
                                              //  // print();
                                              //   Map mapdata =data['fees'];
                                              //  // print(mapdata.length);
                                              //   for(int i=0; i<mapdata.length;i++){
                                              //    List aa=(mapdata[i].values);
                                              //    for(int a=0;a<aa.length;a++){
                                              //      print(aa[a]);
                                              //    }
                                              //   //final aa= mapdata[i];
                                              // //  print(aa);
                                              //
                                              //
                                              //   }
                                              //   //data['fees']
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(doc.studentName)),
                                                      DataCell(Text(doc.studentId)),
                                                      DataCell(Text(doc.term)),
                                                      DataCell(Text(doc.paymentmethod)),
                                                      DataCell(Text(doc.receivedaccount)),
                                                      DataCell(Text(doc.ledgerid)),
                                                      DataCell(Text(doc.level)),
                                                      //DataCell(Text(data['fees'][0] ?? '')),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                onTap: (){}
                                                                //=>deleteFeePayment(doc.id)
                                                              ),
                                                              SizedBox(width: 8),
                                                              InkWell(
                                                                onTap: (){
                                                                  editFeePaymentDialog(context, doc);
                                                                },
                                                                  child: Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                                                              ),
                                                            ],
                                                          )
                                                      ),


                                                    ]
                                                );

                                              }
                                              ).toList(),
                                            )
                                        );
                                      }
                                      else {
                                        return Card(
                                          color: Colors.white,
                                          margin: EdgeInsets.all(8),
                                          child: Column(
                                            children: [
                                              Container(
                                                color: Colors.deepPurple.shade100,
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Text("Fee Payment View", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: value.feepaymentlist.length,
                                                    itemBuilder: (context, index){
                                                      final doc = value.feepaymentlist[index];
                                                      //final data = feeDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Student Name: ${doc.studentName}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Student ID: ${doc.studentId}'),
                                                                Text('Term: ${doc.term}'),
                                                                Text('Payment Method: ${doc.paymentmethod}'),
                                                                Text('Received Account: ${doc.receivedaccount}'),
                                                                Text('Ledger ID: ${doc.ledgerid}'),
                                                                Text('level: ${doc.level}'),
                                                              ],
                                                            ),
                                                            trailing: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.edit, color: Colors.orangeAccent),
                                                                SizedBox(width: 8),
                                                                InkWell(
                                                                    child: Icon(Icons.delete_forever, color: Colors.red),
                                                                  onTap: (){}
                                                                  //=>deleteFeePayment(doc.id),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Divider()
                                                        ],
                                                      );
                                                    }
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}
