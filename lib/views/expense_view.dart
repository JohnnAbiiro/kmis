import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class ExpenseView extends StatefulWidget {
  const ExpenseView({super.key});

  @override
  State<ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchExpense();

    });
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
                      title: Text("Expenses"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 20, left: 100, right: 100, bottom: 20),
                                color: Colors.white,
                                //width: 700,
                                //height: 400,
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
                                            'Not found.',
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        );
                                      }

                                      final expenseDocs = snapshot.data!.docs;
                                      Future<void> deleteExpense(String id) async {
                                        try {
                                          await FirebaseFirestore.instance.collection('expense').doc(id).delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("deleted successfully")),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error deleting: $e")),
                                          );
                                        }
                                      }

                                      if (isWideScreen){
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                              border: TableBorder.all(color: Colors.grey.shade300),
                                              columns: [
                                                DataColumn(label: Text('Supplier Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Expense Category', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Expense Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Fee Amount', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Expense Type', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Payment Method', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Receiving Account', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Ledger No.', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Term', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Staff', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: value.expenselists.map((doc){
                                                //final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(doc.supplier)),
                                                      DataCell(Text(doc.expenseName)),
                                                      DataCell(Text(doc.name)),
                                                      DataCell(Text(doc.fees)),
                                                      DataCell(Text(doc.expenseType)),
                                                      DataCell(Text(doc.paymentmethod)),
                                                      DataCell(Text(doc.paidAccount)),
                                                      DataCell(Text(doc.ledgerid)),
                                                      DataCell(Text(doc.term)),
                                                      DataCell(Text(doc.schoolId)),
                                                      DataCell(Text(doc.staff)),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                onTap: (){}
                                                                //=> deleteExpense(doc.id)
                                                              ),
                                                              SizedBox(width: 8),
                                                              Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
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
                                                      child: Text("Expense View", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: value.expenselists.length,
                                                    itemBuilder: (context, index){
                                                      final data = value.expenselists[index];

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Supplier Name: ${data.supplier}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Expense Category: ${data.expenseName}'),
                                                                Text('Expense Name: ${data.name}'),
                                                                Text('Fee Amount: ${data.fees}'),
                                                                Text('Expense Type: ${data.expenseType}'),
                                                                Text('Payment Method: ${data.paymentmethod}'),
                                                                Text('Receiving Account: ${data.paidAccount}'),
                                                                Text('Ledger No.: ${data.ledgerid}'),
                                                                Text('Term.: ${data.term}'),
                                                                Text('School ID.: ${data.schoolId}'),
                                                                Text('Staff.: ${data.staff}'),
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
                                                                  //=> deleteExpense(doc.id),
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
