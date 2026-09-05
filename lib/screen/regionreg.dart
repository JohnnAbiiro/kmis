
import 'package:ksoftsms/controller/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/regionmodel.dart';
import '../controller/myprovider.dart';

class Regionregistration extends StatefulWidget {
  final RegionModel? region;

  const Regionregistration({super.key, this.region});

  @override
  State<Regionregistration> createState() => _RegionregistrationState();
}

class _RegionregistrationState extends State<Regionregistration> {
  final regioncontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final inputFill = const Color(0xFF2C2C3C);

  String? selectedSeason;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);

    });

    final data = widget.region;
    if (data != null) {
      print("Editing Region: ${data.toMap()}");
      regioncontroller.text = data.regionname;
    } else {
      print("🆕 Registering new Region");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.region != null;
    print("isEdit = $isEdit, RegionData = ${widget.region?.toMap()}");

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D2F45),
              title: Text(
                isEdit ? "Edit Region" : "Register Region",
                style: const TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// region name
                    TextFormField(
                      controller: regioncontroller,
                      decoration: InputDecoration(
                        labelText: "Region Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: inputFill,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Region name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final progress = ProgressHUD.of(context);
                              progress!.show();

                              final idd = "${regioncontroller.text.trim()}"
                                  .replaceAll(" ", "")
                                  .toLowerCase();
                                String id ="${value.schoolid}$idd";
                              final regionData = RegionModel(
                                id: id,
                                regionname: regioncontroller.text.trim(),
                                time: DateTime.now(),
                                schoolId: value.schoolid,
                                staff: value.name,
                              ).toMap();


                              await value.db
                                  .collection("regions")
                                  .doc(id)
                                  .set(regionData, SetOptions(merge: true));

                              progress.dismiss();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit
                                      ? "Region updated successfully"
                                      : "Region registered successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              if (!isEdit) regioncontroller.clear();
                            }
                          },
                          icon: Icon(isEdit ? Icons.update : Icons.save),
                          label: Text(
                              isEdit ? "Update Region" : "Register Region"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, Routes.regionlist),
                          icon: const Icon(Icons.list),
                          label: const Text("View Regions"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
