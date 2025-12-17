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

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchSupplier();

    });
  }


void editSupplierDialog (BuildContext context, supplier){
    final _formKey = GlobalKey<FormState>();
    //final value = context.read<Myprovider>();

    final _supplierNameController = TextEditingController(text: supplier.name);
    final _supplierPhoneController = TextEditingController(text: supplier.phone);

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
                              "Edit Supplier Details",
                              style: TextStyle(
                                color: Colors.white,
                                //fontSize: 14,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        customField(
                          controller: _supplierNameController,
                          label: "Supplier Name",
                          //icon: Icons.person,
                          validator: (v) => v!.isEmpty ? "Name required" : null,
                        ),

                        const SizedBox(height: 12),

                        customField(
                          controller: _supplierPhoneController,
                          label: "Expense Category",
                          //icon: Icons.phone_android,
                          validator: (v) => v!.isEmpty ? "Expense Category required" : null,
                        ),

                        const SizedBox(height: 12),

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
                                child: const Text("Update Supplier", style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;

                                  await FirebaseFirestore.instance
                                      .collection('supplier')
                                      .doc(supplier.id)
                                      .update({
                                    'name': _supplierNameController.text,
                                    'phone': _supplierPhoneController.text,
                                  });
                                  context.read<Myprovider>().fetchSupplier();
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

  // Future<void> editStaffDialog(BuildContext context, String docId, Map<String, dynamic> data) async {
  //   final nameController = TextEditingController(text: data['name']);
  //   final contactController = TextEditingController(text: data['phone']);
  //
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Edit Supplier"),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: nameController,
  //                 decoration: const InputDecoration(labelText: "Supplier Name"),
  //               ),
  //               TextField(
  //                 controller: contactController,
  //                 decoration: const InputDecoration(labelText: "Phone"),
  //               ),
  //
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               await FirebaseFirestore.instance.collection('supplier').doc(docId).update({
  //                 'name': nameController.text.trim(),
  //                 'phone': contactController.text.trim(),
  //               });
  //
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text("Supplier updated successfully")),
  //               );
  //
  //               setState(() {});
  //             },
  //             child: const Text("Update"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
                                                rows: value.supplierlist.asMap().entries.map((entry){
                                                  final index = entry.key;
                                                  final doc = entry.value;
                                                  print(index);
                                                  //final data = doc.data() as Map<String, dynamic>;
                                                  return DataRow(cells: [
                                                    DataCell(Text(doc.name)),
                                                    DataCell(Text(doc.phone)),
                                                    DataCell(Text(doc.schoolId)),
                                                    DataCell(Text(doc.staff)),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                              child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                              onTap: () {
                                                                value.deleteStaff(doc.toString(), index, context, 'supplier');
                                                              }

                                                            //=> deleteSupplier(doc.id),
                                                          ),
                                                          SizedBox(width: 8),
                                                          InkWell(
                                                              child: Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
                                                              onTap: (){
                                                                editSupplierDialog(context, doc);
                                                              }
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
                                                                Text("Phone: ${data.phone}"),
                                                                Text("School ID: ${data.schoolId}"),
                                                                Text("Staff ID: ${data.staff}"),
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

InputDecoration inputStyle(String label) {
  return InputDecoration(
    labelText: label,
    //prefixIcon: Icon(icon, color: const Color(0xFF00496d)),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  );
}

Widget customField({
  required TextEditingController controller,
  required String label,
  //required IconData icon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: inputStyle(label),
  );
}

}
