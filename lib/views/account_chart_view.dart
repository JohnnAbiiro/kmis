import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class AccountChartView extends StatefulWidget {
  const AccountChartView({super.key});

  @override
  State<AccountChartView> createState() => _AccountChartViewState();
}

class _AccountChartViewState extends State<AccountChartView> {

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchAccountList();

    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
          builder: (context){
            return Consumer<Myprovider>(
                builder: (context, value, child, ){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Accounts List"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Container(

                                margin: const EdgeInsets.all(20),
                                color: Colors.white,
                                child: FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance.collection('mainaccounts').get(),
                                  builder: (context, snapshot) {
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
                                          'No staff found.',
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      );
                                    }

                                    //final staffDocs = snapshot.data!.docs;

                                    // Future<void> deleteAccounts(String id) async {
                                    //   try {
                                    //     await FirebaseFirestore.instance.collection('mainaccounts').doc(id).delete();
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
                                          columnSpacing: 25,
                                          headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                          border: TableBorder.all(color: Colors.grey.shade300),
                                          columns: const [
                                            DataColumn(label: Text('Account Name', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Account Class', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Account Sub-Type', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                          ],
                                          rows: value.accountlist.map((doc) {
                                            //final data = doc.data() as Map<String, dynamic>;
                                            return DataRow(cells: [
                                              DataCell(Text(doc.name)),
                                              DataCell(Text(doc.schoolId)),
                                              DataCell(Text(doc.accountType)),
                                              DataCell(Text(doc.subType)),

                                              DataCell(
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                          child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                        onTap: (){}
                                                        //=> deleteAccounts(doc.id),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
                                                    ],
                                                  )
                                              ),
                                            ]);
                                          }).toList(),
                                        ),
                                      );
                                    }
                                    else{
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
                                                    child: Text("Accounts Lists", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: value.accountlist.length,
                                                  itemBuilder: (context, index){
                                                    final doc = value.accountlist[index];
                                                    //final data = staffDocs[index].data() as Map<String, dynamic>;

                                                    return Column(
                                                      children: [
                                                        ListTile(
                                                          title: RichText(
                                                              text: TextSpan(
                                                                  text: "Account Name: ",
                                                                children: [
                                                                  TextSpan(
                                                                    text: doc.name
                                                                  )
                                                                ]
                                                              ),
                                                          ),
                                                          // Text(
                                                          //   'Account Name: ${data['name'] ?? ''}'
                                                          // ),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('School ID: ${doc.schoolId}'),
                                                              Text('Account Class: ${doc.accountType}'),
                                                              Text('Account Sub-Type: ${doc.subType}'),
                                                            ],
                                                          ),
                                                          trailing: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(Icons.edit, color: Colors.orangeAccent),
                                                              const SizedBox(width: 8),
                                                              InkWell(
                                                                  child: const Icon(Icons.delete_forever, color: Colors.red),
                                                                onTap: (){}
                                                                //=> deleteAccounts(doc.id),
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
                                  },
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
