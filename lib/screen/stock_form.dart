import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart'; // <-- add in pubspec.yaml
import 'package:go_router/go_router.dart';
import '../controller/dbmodels/iteRegModel.dart';
import '../controller/routes.dart';

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
    final existingIndex = selectedItems.indexWhere(
          (sel) => sel['barcode'] == item.barcode && sel['name'] == item.name,
    );
    setState(() {
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
      SnackBar(
        content: Text(
          existingIndex != -1
              ? "${item.name} quantity incremented"
              : "${item.name} added to stocking list",
        ),
      ),
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
        backgroundColor: const Color(0xFF00273a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(Routes.dashboard),
        ),
        centerTitle: true,
        title: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stock Entries',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Cumulative Cost: GHC ${cumulativeCost.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              //alignment: WrapAlignment.center,
              children: [
                // === Supplier and Mode ===
                if (selectedItems.isNotEmpty || searchController.text.trim().isNotEmpty)
                  SizedBox(
                    width: 450,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedSupplier,
                            decoration: const InputDecoration(
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
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: purchaseMode,
                            decoration: const InputDecoration(
                              labelText: "Purchase Mode",
                              border: OutlineInputBorder(),
                            ),
                            items: const [
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
                  ),

                // === Search Box ===
                SizedBox(
                  width: 450,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search item",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: filterItems,
                    ),
                  ),
                ),

                // === Available Items ===
                if (searchController.text.trim().isNotEmpty && filteredItems.isNotEmpty)
                  SizedBox(
                    width: 450,
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.deepPurple.shade100,
                            child: const Center(
                              child: Text(
                                "Available Items",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(item.name),
                                      subtitle: Text("Barcode: ${item.barcode}"),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.green),
                                        onPressed: () => addItemToStock(item),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.deepPurple.shade100,
                                      endIndent: 30,
                                      indent: 30,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // === Stocking List ===
                if (selectedItems.isNotEmpty)
                  SizedBox(
                    width: 450,
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.deepPurple.shade100,
                            child: const Center(
                              child: Text(
                                "Stocking List",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              itemCount: selectedItems.length,
                              itemBuilder: (context, index) {
                                final sel = selectedItems[index];
                                final double cost = double.tryParse(sel['costPrice']?.toString() ?? '0') ?? 0;
                                final int qty = sel['qty'] ?? 1;
                                final double totalCost = cost * qty;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(sel['name']),
                                      subtitle: Text(
                                        "Barcode: ${sel['barcode']}\nUnit Cost: $cost\nQty: $qty\nTotal Cost: $totalCost",
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                if (sel['qty'] > 1) sel['qty']--;
                                              });
                                            },
                                          ),
                                          Text(sel['qty'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle, color: Colors.green),
                                            onPressed: () {
                                              setState(() => sel['qty']++);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.deepPurple.shade100,
                                      endIndent: 30,
                                      indent: 30,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                              ),
                              onPressed: saveStockingList,
                              child: const Text("Save", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
