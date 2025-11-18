import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/iteRegModel.dart';
import '../controller/routes.dart';
import '../controller/myprovider.dart';

class Sales extends StatefulWidget {
  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  String purchaseMode = 'Cash';
  String schoolId = '';
  String staff = '';
  List<ItemRegModel> allItems = [];
  List<ItemRegModel> filteredItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  List<Map<String, dynamic>> students = [];

  Map<String, dynamic>? selectedStudent;
  String? selectedLevel;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.fetchdepart();
      schoolId = provider.schoolid;
      staff = provider.name;
    });
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

  Future<void> fetchStudents(String level) async {
    if (selectedLevel == null) {
      setState(() {
        students = [];
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("students")
        .where("department", isEqualTo: level)
        .get();
    setState(() {
      students = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['studentid'] ?? '',
          'name': data['name'] ?? '',
          'displayText': "${data['name']} (${data['studentid']})",
        };
      }).toList();
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
    if (selectedLevel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a level first")));
      return;
    }
    if (selectedStudent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a student first")));
      return;
    }
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No items to save")));
      return;
    }

    // Check stock balance for each item before proceeding
    List<String> insufficientStockItems = [];

    for (var item in selectedItems) {
      final barcode = item['barcode']?.toString() ?? '';
      final requestedQty = item['qty'] ?? 1;

      if (barcode.isNotEmpty) {
        try {
          final stockDoc = await FirebaseFirestore.instance
              .collection("stockStatement")
              .doc('${barcode}_$schoolId')
              .get();

          if (stockDoc.exists) {
            final stockData = stockDoc.data()!;
            final availableBalance = stockData['balance'] ?? 0;

            if (availableBalance < requestedQty) {
              final itemName = item['name'] ?? 'Unknown Item';
              insufficientStockItems.add(
                '$itemName (Available: $availableBalance, Requested: $requestedQty)',
              );
            }
          } else {
            // No stock record found - treat as zero balance
            final itemName = item['name'] ?? 'Unknown Item';
            insufficientStockItems.add('$itemName (No stock record found)');
          }
        } catch (e) {
          print('Error checking stock for barcode $barcode: $e');
          final itemName = item['name'] ?? 'Unknown Item';
          insufficientStockItems.add('$itemName (Error checking stock)');
        }
      }
    }

    // If there are insufficient stock items, show error and return
    if (insufficientStockItems.isNotEmpty) {
      String errorMessage = "Insufficient stock for the following items:\n\n";
      for (String item in insufficientStockItems) {
        errorMessage += "• $item\n";
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Insufficient Stock",
              style: TextStyle(color: Colors.red),
            ),
            content: SingleChildScrollView(child: Text(errorMessage)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    final docRef = FirebaseFirestore.instance.collection("sales").doc();

    double cumulativeCost = 0;
    for (var item in selectedItems) {
      double cost = double.tryParse(item['costPrice']?.toString() ?? '0') ?? 0;
      int qty = item['qty'] ?? 1;
      cumulativeCost += cost * qty;
      item['totalCost'] = cost * qty;
    }
    await docRef.set({
      'level': selectedLevel,
      'studentId': selectedStudent?['id'],
      'studentName': selectedStudent?['name'],
      'timestamp': FieldValue.serverTimestamp(),
      'items': selectedItems,
      'purchaseMode': purchaseMode,
      'cumulativeCost': cumulativeCost,
      'staff': staff,
      'schoolId': schoolId,
    });

    setState(() {
      selectedItems.clear();
      filteredItems = [];
      searchController.clear();
      selectedLevel = null;
      selectedStudent = null;
      students = [];
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Stocking list saved successfully")));
  }

  // Cache for stock balances to improve performance
  Map<String, int> stockBalanceCache = {};

  Future<int> getStockBalance(String barcode) async {
    // Return cached value if available
    if (stockBalanceCache.containsKey(barcode)) {
      return stockBalanceCache[barcode]!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('stockStatement')
          .doc('${barcode}_$schoolId')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final balance = (data['balance'] as num?)?.toInt() ?? 0;
        // Cache the result
        stockBalanceCache[barcode] = balance;
        return balance;
      }

      // Cache zero balance for items not in stock
      stockBalanceCache[barcode] = 0;
      return 0;
    } catch (e) {
      print('Error fetching stock balance for $barcode: $e');
      return 0;
    }
  }

  void refreshStockBalances() {
    // Clear cache to force refresh of stock balances
    stockBalanceCache.clear();
    setState(() {
      // Trigger rebuild to refresh FutureBuilders
    });
  }

  @override
  Widget build(BuildContext context) {
    double cumulativeCost = 0;
    for (var item in selectedItems) {
      double cost = double.tryParse(item['costPrice']?.toString() ?? '0') ?? 0;
      int qty = item['qty'] ?? 1;
      cumulativeCost += cost * qty;
    }
    return Consumer<Myprovider>(
      builder: (context, provider, child) {
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
                        "Total Cost: GHC ${cumulativeCost.toStringAsFixed(2)}",
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
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                //alignment: WrapAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 700,
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
                      if (searchController.text.trim().isNotEmpty &&
                          filteredItems.isNotEmpty)
                        SizedBox(
                          width: 700,
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
                                  //height: MediaQuery.of(context).size.height * 0.3,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      return Column(
                                        children: [
                                          FutureBuilder<int>(
                                            future: getStockBalance(
                                              item.barcode,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return ListTile(
                                                  title: Text(item.name),
                                                  subtitle: Text(
                                                    "Barcode: ${item.barcode}\nChecking stock...",
                                                  ),
                                                  trailing: const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              }

                                              final balance =
                                                  snapshot.data ?? 0;
                                              final hasStock = balance > 0;
                                              final isLowStock =
                                                  balance > 0 && balance <= 10;

                                              Color statusColor = hasStock
                                                  ? (isLowStock
                                                  ? Colors.orange
                                                  : Colors.green)
                                                  : Colors.red;

                                              return ListTile(
                                                title: Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    color: hasStock
                                                        ? Colors.black
                                                        : Colors.grey,
                                                    fontWeight: hasStock
                                                        ? FontWeight.normal
                                                        : FontWeight.w300,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "Barcode: ${item.barcode}\nStock Balance: $balance${!hasStock
                                                      ? ' (Out of Stock)'
                                                      : isLowStock
                                                      ? ' (Low Stock)'
                                                      : ''}",
                                                  style: TextStyle(
                                                    color: hasStock
                                                        ? Colors.black87
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                leading: Container(
                                                  width: 4,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      2,
                                                    ),
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(
                                                    hasStock
                                                        ? Icons.add_circle
                                                        : Icons.block,
                                                    color: statusColor,
                                                  ),
                                                  onPressed: hasStock
                                                      ? () =>
                                                      addItemToStock(item)
                                                      : () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${item.name} is out of stock',
                                                        ),
                                                        backgroundColor:
                                                        Colors.red,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                tileColor: hasStock
                                                    ? null
                                                    : Colors.red.shade50,
                                              );
                                            },
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
                    ],
                  ),
                  Column(
                    children: [
                      if (selectedItems.isNotEmpty ||
                          searchController.text.trim().isNotEmpty)
                        SizedBox(
                          width: 700,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: selectedLevel,
                                  decoration: const InputDecoration(
                                    labelText: "Select Level",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.layers),
                                  ),
                                  items: provider.departments.map((dept) {
                                    return DropdownMenuItem<String>(
                                      value: dept.name,
                                      child: Text(dept.name),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedLevel = val;
                                      selectedStudent =
                                      null; // Reset student selection
                                      students = []; // Clear students list
                                    });
                                    if (val != null) {
                                      fetchStudents(
                                        selectedLevel!,
                                      ); // Fetch students for selected level
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                DropdownSearch<Map<String, dynamic>>(
                                  selectedItem: selectedStudent,
                                  items: (filter, infiniteScrollProps) =>
                                  students,
                                  enabled: selectedLevel != null,
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: selectedLevel == null
                                          ? "Select Level first"
                                          : "Select Student",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.school),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: const TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search student",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    itemBuilder:
                                        (
                                        context,
                                        item,
                                        isDisabled,
                                        isSelected,
                                        ) {
                                      return ListTile(
                                        title: Text(
                                          item['displayText'] ?? '',
                                        ),
                                        selected: isSelected,
                                      );
                                    },
                                    showSelectedItems: true,
                                    fit: FlexFit.loose,
                                    constraints: const BoxConstraints(
                                      maxHeight: 300,
                                    ),
                                  ),
                                  onChanged: (val) =>
                                      setState(() => selectedStudent = val),
                                  filterFn: (item, filter) =>
                                      (item['displayText'] ?? '')
                                          .toLowerCase()
                                          .contains(filter.toLowerCase()),
                                  itemAsString: (item) =>
                                  item['displayText'] ?? '',
                                  compareFn: (item1, item2) =>
                                  item1['id'] == item2['id'],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: purchaseMode,
                                  decoration: const InputDecoration(
                                    labelText: "Purchase Mode",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Cash',
                                      child: Text('Cash'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Credit',
                                      child: Text('Credit'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null)
                                      setState(() => purchaseMode = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (selectedItems.isNotEmpty)
                      // SizedBox(
                      //   width: 600,
                      //   child: Card(
                      //     color: Colors.white,
                      //     margin: const EdgeInsets.all(8),
                      //     child: Column(
                      //       children: [
                      //         Container(
                      //           padding: const EdgeInsets.all(8),
                      //           color: Colors.deepPurple.shade100,
                      //           child: const Center(
                      //             child: Text(
                      //               "Stocking List",
                      //               style: TextStyle(
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.deepPurple,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           //height: MediaQuery.of(context).size.height * 0.3,
                      //           child: ListView.builder(
                      //             shrinkWrap: true,
                      //             physics: NeverScrollableScrollPhysics(),
                      //             itemCount: selectedItems.length,
                      //             itemBuilder: (context, index) {
                      //               final sel = selectedItems[index];
                      //               final double cost = double.tryParse(sel['costPrice']?.toString() ?? '0') ?? 0;
                      //               final int qty = sel['qty'] ?? 1;
                      //               final double totalCost = cost * qty;
                      //               return Column(
                      //                 children: [
                      //                   ListTile(
                      //                     title: Text(sel['name']),
                      //                     subtitle: Text(
                      //                       "Barcode: ${sel['barcode']}\nUnit Cost: $cost\nQty: $qty\nTotal Cost: $totalCost",
                      //                     ),
                      //                     trailing: Row(
                      //                       mainAxisSize: MainAxisSize.min,
                      //                       children: [
                      //                         IconButton(
                      //                           icon: const Icon(Icons.remove_circle, color: Colors.red),
                      //                           onPressed: () {
                      //                             setState(() {
                      //                               if (sel['qty'] > 1) sel['qty']--;
                      //                             });
                      //                           },
                      //                         ),
                      //                         Text(sel['qty'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      //                         IconButton(
                      //                           icon: const Icon(Icons.add_circle, color: Colors.green),
                      //                           onPressed: () {
                      //                             setState(() => sel['qty']++);
                      //                           },
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                   Divider(
                      //                     color: Colors.deepPurple.shade100,
                      //                     endIndent: 30,
                      //                     indent: 30,
                      //                   ),
                      //                 ],
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: Colors.deepPurple,
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(10),
                      //               ),
                      //               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      //             ),
                      //             onPressed: saveStockingList,
                      //             child: const Text("Save", style: TextStyle(color: Colors.white)),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                        SizedBox(
                          width: 700,
                          child: Card(
                            color: Colors.white,
                            margin: EdgeInsets.all(8),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                bool isWideScreen = constraints.maxWidth > 500;

                                if (isWideScreen) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      children: [
                                        DataTable(
                                          headingRowColor:
                                          MaterialStateProperty.all(
                                            Colors.deepPurple.shade100,
                                          ),
                                          columns: const [
                                            DataColumn(
                                              label: Text(
                                                'Name',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Barcode',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Unit Cost',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Qty',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Total Cost',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Actions',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                          rows: selectedItems.map((sel) {
                                            final double cost =
                                                double.tryParse(
                                                  sel['costPrice']
                                                      ?.toString() ??
                                                      '0',
                                                ) ??
                                                    0;
                                            final int qty = sel['qty'] ?? 1;
                                            final double totalCost = cost * qty;
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    sel['name'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    sel['barcode'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    cost.toStringAsFixed(2),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    qty.toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    totalCost.toStringAsFixed(
                                                      2,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.remove_circle,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (sel['qty'] > 1)
                                                              sel['qty']--;
                                                          });
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.add_circle,
                                                          color: Colors.green,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          setState(
                                                                () => sel['qty']++,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              Colors.deepPurple,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 30,
                                                vertical: 14,
                                              ),
                                            ),
                                            onPressed: saveStockingList,
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Card(
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
                                          //height: MediaQuery.of(context).size.height * 0.3,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                            NeverScrollableScrollPhysics(),
                                            itemCount: selectedItems.length,
                                            itemBuilder: (context, index) {
                                              final sel = selectedItems[index];
                                              final double cost =
                                                  double.tryParse(
                                                    sel['costPrice']
                                                        ?.toString() ??
                                                        '0',
                                                  ) ??
                                                      0;
                                              final int qty = sel['qty'] ?? 1;
                                              final double totalCost =
                                                  cost * qty;
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    title: Text(sel['name']),
                                                    subtitle: Text(
                                                      "Barcode: ${sel['barcode']}\nUnit Cost: $cost\nQty: $qty\nTotal Cost: $totalCost",
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.remove_circle,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              if (sel['qty'] >
                                                                  1)
                                                                sel['qty']--;
                                                            });
                                                          },
                                                        ),
                                                        Text(
                                                          sel['qty'].toString(),
                                                          style:
                                                          const TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.add_circle,
                                                            color: Colors.green,
                                                          ),
                                                          onPressed: () {
                                                            setState(
                                                                  () =>
                                                              sel['qty']++,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Colors
                                                        .deepPurple
                                                        .shade100,
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
                                              backgroundColor:
                                              Colors.deepPurple,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 30,
                                                vertical: 14,
                                              ),
                                            ),
                                            onPressed: saveStockingList,
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}