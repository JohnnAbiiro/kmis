import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class SingleBillingView extends StatefulWidget {
  const SingleBillingView({super.key});

  @override
  State<SingleBillingView> createState() => _SingleBillingViewState();
}

class _SingleBillingViewState extends State<SingleBillingView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchSingleBilled();

    });
  }

  void editSingleBillingDialog(BuildContext context, singleBilled){
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
                              "Edit Single Billing Details",
                              style: TextStyle(
                                color: Colors.white,
                                //fontSize: 14,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

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
                                child: const Text("Update Billing", style: TextStyle(color: Colors.white),),
                                onPressed: () async {
                                  // if (!_formKey.currentState!.validate()) return;
                                  //
                                  // await FirebaseFirestore.instance
                                  //     .collection('expense')
                                  //     .doc(suppliers.id)
                                  //     .update({
                                  //   'supplier': _supplierController.text,
                                  //   'expenseType': _expenseTypeController.text,
                                  //   'expenseName': _expenseCategoryController.text,
                                  //   'name': _expenseNameController.text,
                                  //   'fees': _expenseAmountController.text,
                                  //   'term': _expenseTermController.text,
                                  // });

                                  context.read<Myprovider>().fetchSingleBilled();
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
                      title: Text("Single Billing"),
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
                                    future: FirebaseFirestore.instance.collection('singlebilled').get(),
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

                                      //final activityDocs = snapshot.data!.docs;

                                      // Future<void> deleteSingleBilling(String id) async {
                                      //   try {
                                      //     await FirebaseFirestore.instance.collection('singlebilled').doc(id).delete();
                                      //     ScaffoldMessenger.of(context).showSnackBar(
                                      //       const SnackBar(content: Text("deleted successfully")),
                                      //     );
                                      //   } catch (e) {
                                      //     ScaffoldMessenger.of(context).showSnackBar(
                                      //       SnackBar(content: Text("Error deleting: $e")),
                                      //     );
                                      //   }
                                      // }

                                      if (isWideScreen){
                                        return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                              border: TableBorder.all(color: Colors.grey.shade300),
                                              columns: [
                                                DataColumn(label: Text('Student Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Activity Type', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Billed Amount', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Fee Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Level', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Student ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Term', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Year Group', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: value.singlebilledlist.map((doc){
                                                //final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(doc.studentName)),
                                                      DataCell(Text(doc.activityType)),
                                                      DataCell(Text(doc.amount)),
                                                      DataCell(Text(doc.feeName)),
                                                      DataCell(Text(doc.level)),
                                                      DataCell(Text(doc.schoolId)),
                                                      DataCell(Text(doc.studentId)),
                                                      DataCell(Text(doc.term)),
                                                      DataCell(Text(doc.yeargroup)),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                  onTap: (){}
                                                                  //=>deleteSingleBilling(doc.id)
                                                              ),
                                                              SizedBox(width: 8),
                                                              InkWell(
                                                                onTap: (){
                                                                  editSingleBillingDialog(context, doc);
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
                                                      child: Text("Single Billing", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: value.singlebilledlist.length,
                                                    itemBuilder: (context, index){
                                                      final doc=value.singlebilledlist[index];
                                                      //final data = activityDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Student Name: ${doc.studentName}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Activity Type: ${doc.activityType}'),
                                                                Text('Billed Amount: ${doc.amount}'),
                                                                Text('Fee Name: ${doc.feeName}'),
                                                                Text('Level: ${doc.level}'),
                                                                Text('School ID: ${doc.schoolId}'),
                                                                Text('Student ID: ${doc.studentId}'),
                                                                Text('Term: ${doc.term}'),
                                                                Text('Year Group: ${doc.yeargroup}'),
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
                                                                  //=>deleteSingleBilling(doc.id),
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
