import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class SystemAccountActivity extends StatefulWidget {
  const SystemAccountActivity({super.key});

  @override
  State<SystemAccountActivity> createState() => _SystemAccountActivityState();
}

class _SystemAccountActivityState extends State<SystemAccountActivity> {

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchActivityList();

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
                      title: Text("System Activity"),
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
                                    future: FirebaseFirestore.instance.collection('systemActivity').get(),
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
                                            'No System Activity found.',
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        );
                                      }

                                      final activityDocs = snapshot.data!.docs;
                                      Future<void> deleteSystemActivity(String id) async {
                                        try {
                                          await FirebaseFirestore.instance.collection('systemActivity').doc(id).delete();
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
                                                DataColumn(label: Text('Activity Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Debit Account', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Debit Account Class', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Debit Account Subclass', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Credit Account', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Credit Account Class', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Credit Account Subclass', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Staff', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: value.activitylist.map((doc){
                                                //final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(doc.name)),
                                                      DataCell(Text(doc.drAccount)),
                                                      DataCell(Text(doc.drAccountClass)),
                                                      DataCell(Text(doc.drAccountSubClass)),
                                                      DataCell(Text(doc.crAccount)),
                                                      DataCell(Text(doc.crAccountClass)),
                                                      DataCell(Text(doc.drAccountSubClass)),
                                                      DataCell(Text(doc.schoolId)),
                                                      DataCell(Text(doc.staff)),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                  onTap: (){}
                                                                  //=>deleteSystemActivity(doc.id)
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
                                                      final doc = value.activitylist[index];
                                                      //final data = activityDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Activity Name: ${doc.name}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Debit Account: ${doc.drAccount}'),
                                                                Text('Debit Account Class: ${doc.drAccountClass}'),
                                                                Text('Debit Account Subclass: ${doc.drAccountSubClass}'),
                                                                Text('Credit Account: ${doc.crAccount}'),
                                                                Text('Credit Account Class: ${doc.crAccountClass}'),
                                                                Text('Credit Account Subclass: ${doc.crAccountSubClass}'),
                                                                Text('School ID: ${doc.schoolId}'),
                                                                Text('Staff: ${doc.staff}'),
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
                                                                  //=>deleteSystemActivity(doc.id),
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
