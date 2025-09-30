import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/itemCategoryModel.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/termmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class ItemCategory extends StatefulWidget {
  final itemCategoryModel? category;
  const ItemCategory({super.key, this.category});

  @override
  State<ItemCategory> createState() => _ItemCategoryState();
}

class _ItemCategoryState extends State<ItemCategory> {
  final termname = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final data = widget.category;
    if (data != null) {
      termname.text = data.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFF2C2C3C);
    final isEdit = widget.category != null;

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
                    isEdit ? 'Edit Term' : 'Register Term',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: const Color(0xFFffffff),
                      margin: const EdgeInsets.all(30.0),
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: termname,
                                decoration: InputDecoration(
                                  labelText: "Item Category",
                                  hintText: "Enter Item Category ",
                                  labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                  hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[700]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[700]!,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF00496d),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  filled: false,
                                  fillColor: inputFill,
                                ),
                                style: const TextStyle(fontSize: 14),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Item Category is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            final progress = ProgressHUD.of(context);
                                            progress!.show();

                                            String category = termname.text.trim();
                                            String docid=category.replaceAll(RegExp(r'\s+'), '').toLowerCase();
                                            final data = itemCategoryModel(name: category, staff: value.name, schoolId: value.schoolid).toMap();
                                            await value.db.collection('itemcategory').doc("${value.schoolid}$docid").set(data);
                                            progress.dismiss();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Category registered successfully'), backgroundColor: Colors.green),
                                            );

                                            if (!isEdit) {
                                              termname.clear();
                                            }
                                          }
                                        },
                                        icon: Icon(
                                          isEdit ? Icons.update : Icons.save,
                                        ),
                                        label: Text(
                                          isEdit ? 'Update Term' : 'Register Term',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF00496d),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          textStyle: const TextStyle(fontSize: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 5,
                                        ),
                                      ),
                                      //const SizedBox(width: 20),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          context.go(Routes.viewterm);
                                        },
                                        icon: const Icon(
                                          Icons.list,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'View Terms',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF00496d),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          textStyle: const TextStyle(fontSize: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 5,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
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
