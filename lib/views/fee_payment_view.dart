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

                                      final feeDocs = snapshot.data!.docs;
                                      Future<void> deleteFeePayment(String id) async {
                                        try {
                                          await FirebaseFirestore.instance.collection('feemayment').doc(id).delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("deleted successfully")),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error deleting: $e")),
                                          );
                                        }
                                      }

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
                                              rows: feeDocs.map((doc){
                                                final data = doc.data() as Map<String, dynamic>;
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
                                                      DataCell(Text(data['studentName'] ?? '')),
                                                      DataCell(Text(data['studentId'] ?? '')),
                                                      DataCell(Text(data['term'] ?? '')),
                                                      DataCell(Text(data['paymentmethod'] ?? '')),
                                                      DataCell(Text(data['receivedaccount'] ?? '')),
                                                      DataCell(Text(data['ledgerid'] ?? '')),
                                                      DataCell(Text(data['level'] ?? '')),
                                                      //DataCell(Text(data['fees'][0] ?? '')),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                onTap: ()=>deleteFeePayment(doc.id)
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
                                                      child: Text("Fee Payment View", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: feeDocs.length,
                                                    itemBuilder: (context, index){
                                                      final doc = feeDocs[index];
                                                      final data = feeDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Student Name: ${data['studentName'] ?? ''}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Student ID: ${data['studentID'] ?? ''}'),
                                                                Text('Term: ${data['term'] ?? ''}'),
                                                                Text('Payment Method: ${data['paymentmethod'] ?? ''}'),
                                                                Text('Received Account: ${data['receivedaccount'] ?? ''}'),
                                                                Text('Ledger ID: ${data['ledgerId'] ?? ''}'),
                                                                Text('level: ${data['level'] ?? ''}'),
                                                              ],
                                                            ),
                                                            trailing: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.edit, color: Colors.orangeAccent),
                                                                SizedBox(width: 8),
                                                                InkWell(
                                                                    child: Icon(Icons.delete_forever, color: Colors.red),
                                                                  onTap: ()=>deleteFeePayment(doc.id),
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
