import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class BillingView extends StatefulWidget {
  const BillingView({super.key});

  @override
  State<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends State<BillingView> {

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchBilled();

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
                      title: Text("Fees Billing"),
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
                                    future: FirebaseFirestore.instance.collection('billed').get(),
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

                                      final activityDocs = snapshot.data!.docs;
                                      Future<void> deleteFeeBilling(String id) async {
                                        try {
                                          await FirebaseFirestore.instance.collection('billed').doc(id).delete();
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
                                                DataColumn(label: Text('Fee Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Activity Type', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Billed Amount', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Level', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Term', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Year Group', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: value.billedlist.map((doc){
                                                //final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(doc.feeName)),
                                                      DataCell(Text(doc.activityType)),
                                                      DataCell(Text(doc.amount)),
                                                      DataCell(Text(doc.level)),
                                                      DataCell(Text(doc.schoolId)),
                                                      DataCell(Text(doc.term)),
                                                      DataCell(Text(doc.yeargroup)),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                  onTap: (){}
                                                                  //=> deleteFeeBilling(doc.id),
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
                                                      child: Text("System Activity Accounts", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: activityDocs.length,
                                                    itemBuilder: (context, index){
                                                      final doc = value.billedlist[index];
                                                      //final data = activityDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Fee Name: ${doc.feeName}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Activity Type: ${doc.activityType}'),
                                                                Text('Billed Amount: ${doc.amount}'),
                                                                Text('Level: ${doc.level}'),
                                                                Text('School ID: ${doc.schoolId}'),
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
                                                                  //=>deleteFeeBilling(doc.id),
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
