import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart'; // <-- add in pubspec.yaml
import '../controller/dbmodels/iteRegModel.dart';

class StockForm extends StatefulWidget {
  @override
  _StockFormState createState() => _StockFormState();
}

class _StockFormState extends State<StockForm> {
  String purchaseMode = 'Cash';
  List<ItemRegModel> allItems = [];
  List<ItemRegModel> filteredItems = [];
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
      allItems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['barcode'] = data['barcode'] ?? '';
        return ItemRegModel.fromMap(data);
      }).toList();
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
                  item.name.toLowerCase().contains(query.toLowerCase()) ||
                  item.barcode.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void addItemToStock(ItemRegModel item) {
    setState(() {
      final existingIndex = selectedItems.indexWhere(
        (sel) => sel['barcode'] == item.barcode,
      );
      if (existingIndex != -1) {
        selectedItems[existingIndex]['qty']++;
      } else {
        selectedItems.add({
          'barcode': item.barcode,
          'name': item.name,
          'qty': 1,
          'costPrice': item.costPrice,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.name} added to stocking list")),
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

    double cumulativeCost = 0;
    for (var item in selectedItems) {
      double cost = double.tryParse(item['costPrice']?.toString() ?? '0') ?? 0;
      int qty = item['qty'] ?? 1;
      cumulativeCost += cost * qty;
      item['totalCost'] = cost * qty;
    }
    await docRef.set({
      'supplier': selectedSupplier,
      'timestamp': FieldValue.serverTimestamp(),
      'items': selectedItems,
      'purchaseMode': purchaseMode,
      'cumulativeCost': cumulativeCost,
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
    double cumulativeCost = 0;
    for (var item in selectedItems) {
      double cost = double.tryParse(item['costPrice']?.toString() ?? '0') ?? 0;
      int qty = item['qty'] ?? 1;
      cumulativeCost += cost * qty;
    }
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
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
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
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: purchaseMode,
                      decoration: InputDecoration(
                        labelText: "Purchase Mode",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => purchaseMode = val);
                      },
                    ),
                  ],
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
                            title: Text(item.name),
                            subtitle: Text("Barcode: ${item.barcode}"),
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
                          double cost = double.tryParse(sel['costPrice']?.toString() ?? '0') ?? 0;
                          int qty = sel['qty'] ?? 1;
                          double totalCost = cost * qty;
                          return ListTile(
                            title: Text(sel['name']),
                            subtitle: Text("Barcode: ${sel['barcode']}\nUnit Cost: $cost\nQty: $qty\nTotal Cost: $totalCost"),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Cumulative Cost: ₦${cumulativeCost.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
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
