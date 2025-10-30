import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/accountsModel.dart';
import 'package:ksoftsms/controller/dbmodels/iteRegModel.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';

class ItemReg extends StatefulWidget {
  final ComponentModel? component;
  const ItemReg({super.key, this.component});

  @override
  State<ItemReg> createState() => _RevenueGridPageState();
}

class _RevenueGridPageState extends State<ItemReg> {
  final barcodeController = TextEditingController();
  final itemController = TextEditingController();
  final costPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final openingStockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;




  @override
  void dispose() {
    itemController.dispose();
    costPriceController.dispose();
    sellingPriceController.dispose();
    openingStockController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
      context.read<Myprovider>().fetchtemCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (BuildContext context, Myprovider value, Widget? child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                  title: Text(
                    'Register Item',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                body: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
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
                                controller: barcodeController,
                                decoration: InputDecoration(
                                  labelText: "Input Barcode/Code",
                                  hintText: "Enter Product Code",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Enter Item Barcode/Code" : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: itemController,
                                decoration: InputDecoration(
                                  labelText: "Item Name ",
                                  hintText: "Enter Product",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Account Name is required" : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: sellingPriceController,
                                decoration: InputDecoration(
                                  labelText: "Selling Price ",
                                  hintText: "Enter Selling Price",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Selling Price is required" : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: costPriceController,
                                decoration: InputDecoration(
                                  labelText: "Cost Price ",
                                  hintText: "Enter Cost Price",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Selling Price is required" : null,
                              ),
                              const SizedBox(height: 10),
                              buildDropdown(value: _selectedCategory, items: value.itemCategorList.map((e)=>e.name).toList(), label: "Item Category", fillColor: inputFill, onChanged: (v) => setState(() => _selectedCategory = v), validatorMsg: "Select Item Category"),
                              const SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                controller: openingStockController,
                                decoration: InputDecoration(
                                  labelText: "Opening Stock ",
                                  hintText: "Enter opening Stock",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.trim().isEmpty ? "Selling" : null,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00496d),
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final progress = ProgressHUD.of(context);
                                        progress!.show();

                                        try {
                                          String barcodeTxt = barcodeController.text.trim();
                                          String nameTxt = itemController.text.trim();
                                          String costPrice = costPriceController.text.trim();
                                          String sellingPrice = sellingPriceController.text.trim();
                                          String openingStock = openingStockController.text.trim();
                                          String ids = "${value.schoolid.toString().toLowerCase()}";
                                          String id = "$ids${nameTxt.replaceAll(' ', '').toLowerCase()}";
                                          final data = ItemRegModel(name: nameTxt, costPrice: costPrice, sellingPrice: sellingPrice, openningStock: openingStock, category: _selectedCategory.toString(), staff: value.name, schioolid:value.schoolid, barcode: barcodeTxt);
                                          await value.db.collection("itemReg").doc(id).set(data.toJson());
                                          progress.dismiss();
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Saved Successfully"), backgroundColor: Colors.green,));
                                          itemController.clear();
                                          costPriceController.clear();
                                          sellingPriceController.clear();
                                          openingStockController.clear();

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
                                    label: const Text("Save Account", style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00496d),
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                    ),
                                    onPressed: () {
                                      context.go(Routes.itemregview);
                                    },
                                    icon: const Icon(Icons.save, color: Colors.white),
                                    label: const Text("View Account", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
