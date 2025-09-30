import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart'; // <-- add in pubspec.yaml

class StockForm extends StatefulWidget {
  @override
  _StockFormState createState() => _StockFormState();
}

class _StockFormState extends State<StockForm> {
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  List<String> suppliers = [];

  String? selectedSupplier;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchItems();
    fetchSuppliers();
  }

  Future<void> fetchItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("itemReg")
        .get();
    setState(() {
      allItems = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      filteredItems = List.from(allItems);
    });
  }

  Future<void> fetchSuppliers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("supplier")
        .get();
    setState(() {
      suppliers = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  void filterItems(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredItems = [];
      } else {
        filteredItems = allItems
            .where(
              (item) =>
                  item['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item['barcode'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void addItemToStock(Map<String, dynamic> item) {
    setState(() {
      final existingIndex = selectedItems.indexWhere(
        (sel) => sel['id'] == item['id'],
      );
      if (existingIndex != -1) {
        selectedItems[existingIndex]['qty']++;
      } else {
        selectedItems.add({
          'id': item['id'],
          'barcode': item['barcode'],
          'name': item['name'],
          'qty': 1,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item['name']} added to stocking list")),
    );
  }

  Future<void> saveStockingList() async {
    if (selectedSupplier == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a supplier first")));
      return;
    }
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No items to save")));
      return;
    }

    final docRef = FirebaseFirestore.instance.collection("stockingLists").doc();

    await docRef.set({
      'supplier': selectedSupplier,
      'timestamp': FieldValue.serverTimestamp(),
      'items': selectedItems,
    });

    setState(() {
      selectedItems.clear();
      filteredItems = [];
      searchController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Stocking list saved successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stocking Form"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: saveStockingList),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (selectedItems.isNotEmpty ||
                searchController.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  value: selectedSupplier,
                  decoration: InputDecoration(
                    labelText: "Select Supplier",
                    border: OutlineInputBorder(),
                  ),
                  items: suppliers.map((supplier) {
                    return DropdownMenuItem<String>(
                      value: supplier,
                      child: Text(supplier),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedSupplier = val),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search item",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterItems,
              ),
            ),

            if (searchController.text.trim().isNotEmpty &&
                filteredItems.isNotEmpty)
              Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.deepPurple.shade100,
                      child: Center(
                        child: Text(
                          "Available Items",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height:
                          MediaQuery.of(context).size.height *
                          0.3, // mobile-friendly
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text("Barcode: ${item['barcode']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => addItemToStock(item),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Stocking list (stacked below)
            if (selectedItems.isNotEmpty)
              Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.deepPurple.shade100,
                      child: Center(
                        child: Text(
                          "Stocking List",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.builder(
                        itemCount: selectedItems.length,
                        itemBuilder: (context, index) {
                          final sel = selectedItems[index];
                          return ListTile(
                            title: Text(sel['name']),
                            subtitle: Text("Barcode: ${sel['barcode']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (sel['qty'] > 1) {
                                        sel['qty']--;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  sel['qty'].toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      sel['qty']++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

      // ✅ Floating save button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveStockingList,
        label: Text("Save"),
        icon: Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
