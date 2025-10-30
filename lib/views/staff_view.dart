import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class StaffView extends StatefulWidget {
  const StaffView({super.key});

  @override
  State<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {
  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
          builder: (context){
            return Consumer<Myprovider>(
                builder: (context, value, child, ){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Staff List"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Container(
                                //width: 800,
                                //height: 400,
                                padding: const EdgeInsets.all(12),
                                color: Colors.white,
                                child: FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance.collection('staff').get(),
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

                                    final staffDocs = snapshot.data!.docs;
                                    Future<void> deleteStaff(String id) async {
                                      try {
                                        await FirebaseFirestore.instance.collection('staff').doc(id).delete();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("deleted successfully")),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error deleting: $e")),
                                        );
                                      }
                                    }


                                    Future<void> editStaffDialog(BuildContext context, String docId, Map<String, dynamic> data) async {
                                      final nameController = TextEditingController(text: data['name']);
                                      final phoneController = TextEditingController(text: data['phone']);
                                      final emailController = TextEditingController(text: data['email']);
                                      final regionController = TextEditingController(text: data['region']);
                                      final sexController = TextEditingController(text: data['sex']);
                                      final accessController = TextEditingController(text: data['accessLevel']);

                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Edit Staff"),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: nameController,
                                                    decoration: const InputDecoration(labelText: "Name"),
                                                  ),
                                                  TextField(
                                                    controller: phoneController,
                                                    decoration: const InputDecoration(labelText: "Phone"),
                                                  ),
                                                  TextField(
                                                    controller: emailController,
                                                    decoration: const InputDecoration(labelText: "Email"),
                                                  ),
                                                  TextField(
                                                    controller: regionController,
                                                    decoration: const InputDecoration(labelText: "Region"),
                                                  ),
                                                  TextField(
                                                    controller: sexController,
                                                    decoration: const InputDecoration(labelText: "Sex"),
                                                  ),
                                                  TextField(
                                                    controller: accessController,
                                                    decoration: const InputDecoration(labelText: "Access Level"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance.collection('staff').doc(docId).update({
                                                    'name': nameController.text.trim(),
                                                    'phone': phoneController.text.trim(),
                                                    'email': emailController.text.trim(),
                                                    'region': regionController.text.trim(),
                                                    'sex': sexController.text.trim(),
                                                    'accessLevel': accessController.text.trim(),
                                                  });

                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Staff updated successfully")),
                                                  );

                                                  setState(() {}); // refresh data
                                                },
                                                child: const Text("Save"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }



                                    if (isWideScreen){
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 25,
                                          headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                          border: TableBorder.all(color: Colors.grey.shade300),
                                          columns: const [
                                            DataColumn(label: Text('Staff Name', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Phone', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Email', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Sex', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Region', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Access Level', style: TextStyle(color: Colors.white))),
                                            DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
                                          ],
                                          rows: staffDocs.map((doc) {
                                            final data = doc.data() as Map<String, dynamic>;
                                            return DataRow(cells: [
                                              DataCell(Text(data['name'] ?? '')),
                                              DataCell(Text(data['phone'] ?? '')),
                                              DataCell(Text(data['email'] ?? '')),
                                              DataCell(Text(data['sex'] ?? '')),
                                              DataCell(Text(data['region'] ?? '')),
                                              DataCell(Text(data['accessLevel'] ?? '')),
                                              DataCell(
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                          child: Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                                        onTap: ()=>deleteStaff(doc.id),
                                                      ),
                                                      SizedBox(width: 8),
                                                      InkWell(
                                                        child: const Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                                                        onTap: () => editStaffDialog(context, doc.id, data),
                                                      ),

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
                                                    child: Text("Staff Lists", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: staffDocs.length,
                                                  itemBuilder: (context, index){

                                                    final doc = staffDocs[index];
                                                    final data = staffDocs[index].data() as Map<String, dynamic>;

                                                    return Column(
                                                      children: [
                                                        ListTile(
                                                          title: Text(
                                                            data['name'] ?? '',
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('Phone: ${data['phone'] ?? ''}'),
                                                              Text('Email: ${data['email'] ?? ''}'),
                                                              Text('Sex: ${data['sex'] ?? ''}'),
                                                              Text('Region: ${data['region'] ?? ''}'),
                                                              Text('Access Level: ${data['accessLevel'] ?? ''}'),
                                                            ],
                                                          ),
                                                          trailing: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.edit, color: Colors.orangeAccent),
                                                              SizedBox(width: 8),
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red),
                                                                onTap: ()=>deleteStaff(doc.id),
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
