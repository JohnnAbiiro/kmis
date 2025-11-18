import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/SupplierModel.dart';

import 'package:ksoftsms/controller/dbmodels/feeSetUpModel.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class SupplierForm extends StatefulWidget {
  final ComponentModel? component;
  const SupplierForm({super.key, this.component});

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final feeNameController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showSupplierContainer = false;

  String schoolid = "";
  String schoolname = "";
  String userid = "";

  @override
  void dispose() {
    feeNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.getdata();
      provider.getfetchRegions();
      provider.fetchdepart();
      provider.fetchclass();
      provider.fetchterms();
    });
  }


  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context,  value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                  title: Text(
                    '${value.currentschool.toUpperCase()} FEES BILLING ',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                body: SingleChildScrollView(
                  child: LayoutBuilder(
                      builder: (context, constraints){
                        bool isWideScreen = constraints.maxWidth > 500;
                        return Center(
                          child: Wrap(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: Container(
                                  color: const Color(0xFFffffff),
                                  margin: const EdgeInsets.all(20),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            controller: feeNameController,
                                            decoration: InputDecoration(
                                              labelText: "Supplier Name ",
                                              hintText: "Supplier Name ",
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey[700]!),
                                              ),
                                            ),
                                            validator: (value) =>
                                            value == null || value.trim().isEmpty ? "Amount is required" : null,
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly, // ✅ only integers
                                            ],
                                            keyboardType: TextInputType.phone,
                                            controller: phoneController,
                                            decoration: InputDecoration(
                                              labelText: "Supplier Phone Number ",
                                              hintText: "Supplier Phone Number ",
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey[700]!),
                                              ),
                                            ),
                                            validator: (value) =>
                                            value == null || value.trim().isEmpty||value.length>14 ? "Valid Phone Number is required" : null,
                                          ),
                                          const SizedBox(height: 10),
                                          // Save Button
                                          Row(
                                            children: [
                                              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00496d), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                                                onPressed: () async {
                                                  if (_formKey.currentState!.validate()) {
                                                    final progress = ProgressHUD.of(context);
                                                    progress!.show();
                                                    String name=feeNameController.text.trim();
                                                    String phonetxt=phoneController.text.trim();
                                                    String id = name.replaceAll(RegExp(r'\s+'), '').toLowerCase();

                                                    try {
                                                      final data=SupplierModel(phone:phonetxt,name: name, staff: value.name,  dateCreated: DateTime.now(),  schoolId: value.schoolid, id: '').toJson();
                                                      await value.db.collection("supplier").doc('${value.schoolid}_$id').set(data);
                                                      progress.dismiss();
                                                      feeNameController.clear();

                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text("Data Saved Successfully"),
                                                          backgroundColor: Colors.green,
                                                        ),
                                                      );


                                                    } catch (e) {
                                                      progress.dismiss();
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text("Failed to save data: $e"),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                icon: const Icon(Icons.save, color: Colors.white),
                                                label: const Text("Save Supplier",
                                                    style: TextStyle(color: Colors.white)),
                                              ),
                                              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00496d), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                                                onPressed: () {
                                                  context.go(Routes.supplierview);
                                                },
                                                icon: const Icon(Icons.save, color: Colors.white),
                                                label: const Text("View Suppliers",
                                                    style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              if (_showSupplierContainer)
                                Container(
                                  color: Colors.white,
                                  width: 600,
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
                                              width: 600,
                                              child: DataTable(
                                                //columnSpacing: 25,
                                                  headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                                  border: TableBorder.all(color: Colors.grey.shade300),
                                                  columns: [
                                                    DataColumn(label: Text('Supplier Name', style: TextStyle(color: Colors.white),)),
                                                    DataColumn(label: Text('Supplier Contact', style: TextStyle(color: Colors.white),)),
                                                    DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                                  ],
                                                  rows: supplierDocs.map((doc){
                                                    final data = doc.data() as Map<String, dynamic>;
                                                    return DataRow(cells: [
                                                      DataCell(Text(data['name'] ?? '')),
                                                      DataCell(Text(data['phone'] ?? '')),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                onTap: () => deleteSupplier(doc.id),
                                                              ),
                                                              SizedBox(width: 8),
                                                              Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
                                                            ],
                                                          )
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
                                                      itemCount: supplierDocs.length,
                                                      itemBuilder: (context, index){
                                                        final data = supplierDocs[index].data() as Map<String, dynamic>;
                                                        return Column(
                                                          children: [
                                                            ListTile(
                                                              title: Text("Name: ${data['name'] ?? ''}"),
                                                              subtitle: Text("Phone: ${data['phone'] ?? ''}"),
                                                              trailing: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(Icons.edit, color: Colors.orangeAccent),
                                                                  const SizedBox(width: 8),
                                                                  const Icon(Icons.delete_forever, color: Colors.red),
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
                                )
                            ],
                          ),
                        );
                      }
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
