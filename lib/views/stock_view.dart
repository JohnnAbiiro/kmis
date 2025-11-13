import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockView> {
  String searchQuery = '';
  bool sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock List", style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF00496d),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or barcode...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),


          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('stock').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No stock data found"));
                }

                // Flatten all 'items' from every document
                final allItems = snapshot.data!.docs.expand((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final items = (data['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
                  return items.map((item) {
                    return {
                      'docId': doc.id,
                      'barcode': item['barcode'] ?? '',
                      'name': item['name'] ?? '',
                      'qty': item['qty'] ?? 0,
                      'costPrice': item['costPrice'] ?? '0',
                      'totalCost': item['totalCost'] ?? 0,
                    };
                  });
                }).toList();

                // search filter
                final filteredItems = allItems.where((item) {
                  final name = item['name'].toString().toLowerCase();
                  final barcode = item['barcode'].toString().toLowerCase();
                  return name.contains(searchQuery) || barcode.contains(searchQuery);
                }).toList();

                // Sort by name or totalCost
                filteredItems.sort((a, b) {
                  if (sortAscending) {
                    return a['name'].toString().compareTo(b['name'].toString());
                  } else {
                    return b['name'].toString().compareTo(a['name'].toString());
                  }
                });

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortAscending: sortAscending,
                    sortColumnIndex: 1, // sort by name
                    headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnSpacing: 25,
                    columns: [
                      const DataColumn(
                        label: Text('Barcode', style: TextStyle(color: Colors.white)),
                      ),
                      DataColumn(
                        label: const Text('Item Name', style: TextStyle(color: Colors.white)),
                        onSort: (columnIndex, ascending) {
                          setState(() => sortAscending = ascending);
                        },
                      ),
                      const DataColumn(label: Text('Qty', style: TextStyle(color: Colors.white))),
                      const DataColumn(label: Text('Cost Price', style: TextStyle(color: Colors.white))),
                      const DataColumn(label: Text('Total Cost', style: TextStyle(color: Colors.white))),
                    ],
                    rows: filteredItems.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['barcode'].toString())),
                          DataCell(Text(item['name'].toString())),
                          DataCell(Text(item['qty'].toString())),
                          DataCell(Text(item['costPrice'].toString())),
                          DataCell(Text(item['totalCost'].toString())),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
