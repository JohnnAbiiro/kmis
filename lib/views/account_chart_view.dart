import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/widgets/dropdown.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class AccountChartView extends StatefulWidget {
  const AccountChartView({super.key});

  @override
  State<AccountChartView> createState() => _AccountChartViewState();
}

class _AccountChartViewState extends State<AccountChartView> {

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchAccountList();

    });
  }

void editAccountChartDialog(BuildContext context, mainaccount) {
  final _formKey = GlobalKey<FormState>();
  final value = context.read<Myprovider>();

  final _accountNameController = TextEditingController(text: mainaccount.name);
  final _accountTypeController = TextEditingController(text: mainaccount.accountType);
  final _accountSupTypeController = TextEditingController(text: mainaccount.subType);

  String? selectedAccountClass = mainaccount.accountType;
  String? selectedSupAccountType = mainaccount.subType;

  final List<String> accounts = ["Assets", "Liability", "Equity", "Revenue", "Expense"];
  final Map<String, List<String>> accountMap = {
    "Assets": ["Current Assets", "Fixed Assets"],
    "Liability": ["Current Liabilities", "Long-term Liabilities"],
    "Equity": ["Owner's Equity", "Share Capital", "Retained Earnings", "Reserves"],
    "Revenue": ["Operating Revenue", "Non-operating Revenue"],
    "Expense": [
      "Operating Expenses",
      "Administrative Expenses",
      "Selling & Distribution Expenses",
      "Financial Expenses",
      "Depreciation & Amortization",
      "Other Expenses"
    ],
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, modalSetState) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: Offset(0, 6),
                  color: Colors.black.withOpacity(0.15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Color(0xFF00496d),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                "Edit Account Chart",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          customField(
                            controller: _accountNameController,
                            label: "Account Name",
                            validator: (v) =>
                            v!.isEmpty ? "Account Name is required" : null,
                          ),
                          const SizedBox(height: 16),

                          // Account Class
                          buildDropdown(
                            value: selectedAccountClass,
                            items: accounts,
                            label: "Account Class",
                            fillColor: Colors.grey.shade100,
                            onChanged: (v) {
                              modalSetState(() {
                                selectedAccountClass = v;
                                _accountTypeController.text = v ?? "";
                                selectedSupAccountType = null;
                                _accountSupTypeController.text = "";
                              });
                            },
                            validatorMsg: "Select Account Class",
                          ),
                          const SizedBox(height: 16),

                          if (selectedAccountClass != null)
                            DropdownButtonFormField<String>(
                              value: selectedSupAccountType,
                              items: accountMap[selectedAccountClass]!
                                  .map((subType) => DropdownMenuItem(
                                value: subType,
                                child: Text(subType),
                              ))
                                  .toList(),
                              onChanged: (v) {
                                modalSetState(() {
                                  selectedSupAccountType = v;
                                  _accountSupTypeController.text = v ?? "";
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Account Sub-Type",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => value == null
                                  ? 'Select account sub-type'
                                  : null,
                            ),
                          const SizedBox(height: 25),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    foregroundColor: Color(0xFF00496d),
                                    side: const BorderSide(
                                      color: Color(0xFF00496d),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Color(0xFF00496d),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    "Update",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) return;

                                    await FirebaseFirestore.instance
                                        .collection('mainaccounts')
                                        .doc(mainaccount.id)
                                        .update({
                                      'name': _accountNameController.text,
                                      'accountType': selectedAccountClass,
                                      'subType': selectedSupAccountType,
                                    });

                                    context.read<Myprovider>().fetchAccountList();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
                builder: (context, value, child, ){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Accounts List"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Container(

                                margin: const EdgeInsets.all(20),
                                color: Colors.white,
                                child: FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance.collection('mainaccounts').get(),
                                  builder: (context, snapshot) {
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
                                          'No staff found.',
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      );
                                    }


                                    // Future<void> deleteAccounts(String id) async {
                                    //   try {
                                    //     await FirebaseFirestore.instance.collection('mainaccounts').doc(id).delete();
                                    //     ScaffoldMessenger.of(context).showSnackBar(
                                    //       const SnackBar(content: Text("deleted successfully")),
                                    //     );
                                    //   } catch (e) {
                                    //     ScaffoldMessenger.of(context).showSnackBar(
                                    //       SnackBar(content: Text("Error deleting: $e")),
                                    //     );
                                    //   }
                                    // }


                                    if (isWideScreen){
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 25,
                                          headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                          border: TableBorder.all(color: Colors.grey.shade300),
                                          columns: const [
                                            DataColumn(label: Text('Account Name', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('School ID', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Account Class', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Account Sub-Type', style: TextStyle(color: Colors.white),)),
                                            DataColumn(label: Text('Action', style: TextStyle(color: Colors.white),)),

                                          ],
                                          rows: value.accountlist.map((doc) {
                                            //final data = doc.data() as Map<String, dynamic>;
                                            return DataRow(cells: [
                                              DataCell(Text(doc.name)),
                                              DataCell(Text(doc.schoolId)),
                                              DataCell(Text(doc.accountType)),
                                              DataCell(Text(doc.subType)),

                                              DataCell(
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                          child: Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                        onTap: (){}
                                                        //=> deleteAccounts(doc.id),
                                                      ),
                                                      SizedBox(width: 8),
                                                      InkWell(
                                                        onTap: (){
                                                          editAccountChartDialog(context, doc);
                                                        },
                                                          child: Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            ]);
                                          }).toList(),
                                        ),
                                      );
                                    }
                                    else{
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
                                                    child: Text("Accounts Lists", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: value.accountlist.length,
                                                  itemBuilder: (context, index){
                                                    final doc = value.accountlist[index];
                                                    //final data = staffDocs[index].data() as Map<String, dynamic>;

                                                    return Column(
                                                      children: [
                                                        ListTile(
                                                          title: RichText(
                                                              text: TextSpan(
                                                                  text: "Account Name: ",
                                                                children: [
                                                                  TextSpan(
                                                                    text: doc.name
                                                                  )
                                                                ]
                                                              ),
                                                          ),
                                                          // Text(
                                                          //   'Account Name: ${data['name'] ?? ''}'
                                                          // ),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('School ID: ${doc.schoolId}'),
                                                              Text('Account Class: ${doc.accountType}'),
                                                              Text('Account Sub-Type: ${doc.subType}'),
                                                            ],
                                                          ),
                                                          trailing: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(Icons.edit, color: Colors.orangeAccent),
                                                              const SizedBox(width: 8),
                                                              InkWell(
                                                                  child: const Icon(Icons.delete_forever, color: Colors.red),
                                                                onTap: (){}
                                                                //=> deleteAccounts(doc.id),
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
                                  },
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

InputDecoration inputStyle(String label) {
  return InputDecoration(
    labelText: label,
    //prefixIcon: Icon(icon, color: const Color(0xFF00496d)),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  );
}

Widget customField({
  required TextEditingController controller,
  required String label,
  //required IconData icon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: inputStyle(label),
  );
}

}
