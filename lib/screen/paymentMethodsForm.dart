import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/paymentMethodsModel.dart';

class PaymentMethodForm extends StatefulWidget {
  const PaymentMethodForm({super.key});

  @override
  State<PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<PaymentMethodForm> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LoginProvider>(context, listen: false);
      provider.getdata();
      provider.fetchFess();
      provider.fetchCurrentAccounts();
    });
  }
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _staffController = TextEditingController();
  final TextEditingController _subTypeController = TextEditingController();

  String? _accountType;
  final List<String> _selectedAccounts = []; // store selected IDs


  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Consumer<LoginProvider>(
        builder: (BuildContext context, LoginProvider value, Widget? child) {
          return  Scaffold(
            appBar: AppBar(title: const Text("Add Payment Method")),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter payment method name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Input Payment Method Name",
                              border: const OutlineInputBorder(),
                            ),
      
                          ),
                          const Text("Select Linked Accounts"),
                          MultiSelectDialogField<String>(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            searchable: true,
                            items: value.currentaccounts.map((acc) => MultiSelectItem<String>(acc, acc)).toList(),
                            title: const Text("Linked Accounts"),
                            buttonText: const Text("Choose Accounts"),
                            initialValue: _selectedAccounts,
                            listType: MultiSelectListType.LIST,
                            onConfirm: (values) {
                              setState(() {
                                _selectedAccounts.clear();
                                _selectedAccounts.addAll(values);
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: ()async{
                              try{
                                if(_formKey.currentState!.validate()==false) return;
                                 final progress= ProgressHUD.of(context);
                                 progress!.show();
                                 final paymentMethod = PaymentMethodModel(
                                  linkedAccounts: _selectedAccounts,
                                  staff: value.name,
                                  name: _nameController.text.trim(),
                                  schoolId: value.schoolid, // replace with actual schoolId
                                  accountType: _accountType ?? "",
                                  subType: _subTypeController.text.trim(),
                                  dateCreated: DateTime.now(),
                                );

                                String docid=_nameController.text.trim().replaceAll(" ", "_").toLowerCase();
                                await value.db.collection("paymentmethod").doc(docid).set(paymentMethod.toJson());
                                progress.dismiss();
                              }catch(e){
                                final progress= ProgressHUD.of(context);
                                progress!.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                              }

      
                            },
      
                            child: const Text("Save Payment Method"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
