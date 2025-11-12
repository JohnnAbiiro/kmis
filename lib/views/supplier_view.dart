import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class SupplierView extends StatefulWidget {
  const SupplierView({super.key});

  @override
  State<SupplierView> createState() => _SupplierViewState();
}

class _SupplierViewState extends State<SupplierView> {

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchSupplier();

    });
  }

  Future<void> editStaffDialog(BuildContext context, String docId, Map<String, dynamic> data) async {
    final nameController = TextEditingController(text: data['name']);
    final contactController = TextEditingController(text: data['phone']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Supplier"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Supplier Name"),
                ),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: "Phone"),
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
                await FirebaseFirestore.instance.collection('supplier').doc(docId).update({
                  'name': nameController.text.trim(),
                  'phone': contactController.text.trim(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Supplier updated successfully")),
                );

                setState(() {});
              },
              child: const Text("Update"),
            ),
          ],
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
                builder: (BuildContext context,  value, Widget? child){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Supplier"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Container(
                                color: Colors.white,
                                width: 800,
                                //height: 400,
                                margin: const EdgeInsets.all(20),
                                child: FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance.collection('supplier').get(),
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
                                            'No Supplier found.',
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        );
                                      }

                                      final supplierDocs = snapshot.data!.docs;

                                      Future<void> deleteSupplier(String id) async {
                                        try {
                                          await FirebaseFirestore.instance.collection('supplier').doc(id).delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Supplier deleted successfully")),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error deleting supplier: $e")),
                                          );
                                        }
                                      }


                                      if (isWideScreen){
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            width: 800,
                                            child: DataTable(
                                              //columnSpacing: 25,
                                                headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                                border: TableBorder.all(color: Colors.grey.shade300),
                                                columns: [
                                                  DataColumn(label: Text('Supplier Name', style: TextStyle(color: Colors.white),)),
                                                  DataColumn(label: Text('Supplier Contact', style: TextStyle(color: Colors.white),)),
                                                  DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                                  DataColumn(label: Text('Staff ID', style: TextStyle(color: Colors.white),)),
                                                  DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                                ],
                                                rows: value.supplierlist.map((doc){
                                                  //final data = doc.data() as Map<String, dynamic>;
                                                  return DataRow(cells: [
                                                    DataCell(Text(doc.name ?? '')),
                                                    DataCell(Text(doc.phone ?? '')),
                                                    DataCell(Text(doc.schoolId ?? '')),
                                                    DataCell(Text(doc.staff ?? '')),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                              child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                              onTap: () {}

                                                            //=> deleteSupplier(doc.id),
                                                          ),
                                                          SizedBox(width: 8),
                                                          InkWell(
                                                              child: Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
                                                              onTap: (){}
                                                            //=> editStaffDialog(context, doc.id, data),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]);
                                                }).toList()
                                            ),
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
                                                      child: Text("Supplier Lists", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: value.supplierlist.length,
                                                    itemBuilder: (context, index){

                                                      final data = value.supplierlist[index];

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text('Name: ${data.name?? ''}'),
                                                            subtitle: Column(
                                                              children: [
                                                                Text("Phone: ${data.phone ?? ''}"),
                                                                Text("School ID: ${data.schoolId ?? ''}"),
                                                                Text("Staff ID: ${data.staff ?? ''}"),
                                                              ],
                                                            ),
                                                            trailing: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                const Icon(Icons.edit, color: Colors.orangeAccent),
                                                                const SizedBox(width: 8),
                                                                InkWell(
                                                                    child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                    onTap: () {}
                                                                  //=> deleteSupplier(doc.id),
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
