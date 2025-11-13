import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class ItemRegView extends StatefulWidget {
  const ItemRegView({super.key});

  @override
  State<ItemRegView> createState() => _ItemRegViewState();
}

class _ItemRegViewState extends State<ItemRegView> {

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchItemRegList();

    });
  }

  Future<void> editStaffDialog(BuildContext context, String docId, Map<String, dynamic> data) async {
    final nameController = TextEditingController(text: data['name']);
    final barcodeController = TextEditingController(text: data['barcode']);
    final sellingController = TextEditingController(text: data['costPrice']);
    final costController = TextEditingController(text: data['sellingPrice']);
    final openingController = TextEditingController(text: data['openningStock']);

    String selectedCategory = data['category'] ?? '';

    final categories = ['Books', 'Food', 'Pens', 'Best', 'Uniform'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(labelText: "Barcode"),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "name"),
                ),
                TextField(
                  controller: sellingController,
                  decoration: const InputDecoration(labelText: "Selling Price"),
                ),

                TextField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: "Cost Price"),
                ),


                DropdownButtonFormField<String>(
                  value: selectedCategory.isNotEmpty ? selectedCategory : null,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: categories.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),

                TextField(
                  controller: openingController,
                  decoration: const InputDecoration(labelText: "Opening Stock"),
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
                await FirebaseFirestore.instance.collection('itemReg').doc(docId).update({
                  'barcode': barcodeController.text.trim(),
                  'name': nameController.text.trim(),
                  'sellingPrice': sellingController.text.trim(),
                  'costPrice': costController.text.trim(),
                  'category': selectedCategory,
                  'openningStock': openingController.text.trim()
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Item updated successfully")),
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
                builder: (BuildContext context, value, Widget? child){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Register Items"),
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
                                    future: FirebaseFirestore.instance.collection('itemReg').get(),
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
                                      Future<void> deleteItemReg(String id) async {
                                        try {
                                          await FirebaseFirestore.instance.collection('itemreg').doc(id).delete();
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
                                                DataColumn(label: Text('Item Name', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Barcode', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Item Category', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Cost Price', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Selling Price', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Opening Stock', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Staff', style: TextStyle(color: Colors.white),)),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                              ],
                                              rows: value.itemreglist.map((doc){
                                                //final data = doc.data() as Map<String, dynamic>;
                                                return DataRow(
                                                    cells: [
                                                      DataCell(Text(doc.name)),
                                                      DataCell(Text(doc.barcode)),
                                                      DataCell(Text(doc.category)),
                                                      DataCell(Text(doc.costPrice)),
                                                      DataCell(Text(doc.sellingPrice)),
                                                      DataCell(Text(doc.openningStock)),
                                                      DataCell(Text(doc.schioolid)),
                                                      DataCell(Text(doc.staff)),
                                                      DataCell(
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                                  onTap: () {}
                                                                  //=> deleteItemReg(doc.id)
                                                              ),
                                                              SizedBox(width: 8),
                                                              InkWell(
                                                                  child: Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
                                                                onTap: (){}
                                                                //=> editStaffDialog(context, doc.id, data),
                                                              ),
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
                                                      child: Text("Register Items", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: value.itemreglist.length,
                                                    itemBuilder: (context, index){
                                                      final doc = value.itemreglist[index];
                                                      //final data = activityDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                                'Item Name: ${doc.name}'
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Barcode: ${doc.barcode}'),
                                                                Text('Item Category: ${doc.category}'),
                                                                Text('Cost Price: ${doc.costPrice}'),
                                                                Text('Selling Price: ${doc.sellingPrice}'),
                                                                Text('Opening Stock: ${doc.openningStock}'),
                                                                Text('School ID: ${doc.schioolid}'),
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
                                                                  //=>deleteItemReg(doc.id),
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
