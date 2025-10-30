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
                                              rows: activityDocs.map((doc){
                                                final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(data['name'] ?? '')),
                                                      DataCell(Text(data['drAccount'] ?? '')),
                                                      DataCell(Text(data['drAccountClass'] ?? '')),
                                                      DataCell(Text(data['drAccountSubClass'] ?? '')),
                                                      DataCell(Text(data['crAccount'] ?? '')),
                                                      DataCell(Text(data['crAccountClass'] ?? '')),
                                                      DataCell(Text(data['crAccountSubClass'] ?? '')),
                                                      DataCell(Text(data['schoolId'] ?? '')),
                                                      DataCell(Text(data['staff'] ?? '')),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                  onTap: ()=>deleteSystemActivity(doc.id)
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
                                                      final doc = activityDocs[index];
                                                      final data = activityDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Activity Name: ${data['name'] ?? ''}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Debit Account: ${data['drAccount'] ?? ''}'),
                                                                Text('Debit Account Class: ${data['drAccountClass'] ?? ''}'),
                                                                Text('Debit Account Subclass: ${data['drAccountSubClass'] ?? ''}'),
                                                                Text('Credit Account: ${data['crAccount'] ?? ''}'),
                                                                Text('Credit Account Class: ${data['crAccountClass'] ?? ''}'),
                                                                Text('Credit Account Subclass: ${data['crAccountSubClass'] ?? ''}'),
                                                                Text('School ID: ${data['schoolId'] ?? ''}'),
                                                                Text('Staff: ${data['staff'] ?? ''}'),
                                                              ],
                                                            ),
                                                            trailing: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.edit, color: Colors.orangeAccent),
                                                                SizedBox(width: 8),
                                                                InkWell(
                                                                    child: Icon(Icons.delete_forever, color: Colors.red),
                                                                  onTap: ()=>deleteSystemActivity(doc.id),
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
