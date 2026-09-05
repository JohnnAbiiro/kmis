import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/accountsModel.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/componentmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class AccountsChart extends StatefulWidget {
  final ComponentModel? component;
  const AccountsChart({super.key, this.component});

  @override
  State<AccountsChart> createState() => _RevenueGridPageState();
}

class _RevenueGridPageState extends State<AccountsChart> {
  final accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showAccountContainer = false;

  String? _selectedAccountClass;
  String? _selectedSubType;

  // For preview
  String? previewName;
  String? previewClass;
  String? previewSubType;

  final List<String> _accounts = ["Assets", "Liability", "Equity", "Revenue", "Expense"];

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

  @override
  void dispose() {
    accountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    '${value.currentschool} Add Account Chart',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [

                        Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700),
                              child: Container(
                                color: Colors.white,
                                margin: const EdgeInsets.all(20),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: accountController,
                                          decoration: const InputDecoration(
                                            labelText: "Account Name",
                                            hintText: "Enter Account Name",
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) => value == null || value.trim().isEmpty
                                              ? "Account Name is required"
                                              : null,
                                        ),
                                        const SizedBox(height: 20),

                                        DropdownButtonFormField<String>(
                                          value: _selectedAccountClass,
                                          items: _accounts.map((cat) {
                                            return DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedAccountClass = value;
                                              _selectedSubType = null;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: "Select Account Class",
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) => value == null
                                              ? 'Please select account class'
                                              : null,
                                        ),
                                        const SizedBox(height: 20),

                                        if (_selectedAccountClass != null)
                                          DropdownButtonFormField<String>(
                                            value: _selectedSubType,
                                            items: accountMap[_selectedAccountClass]!
                                                .map((subType) => DropdownMenuItem(
                                              value: subType,
                                              child: Text(subType),
                                            ))
                                                .toList(),
                                            onChanged: (value) =>
                                                setState(() => _selectedSubType = value),
                                            decoration: const InputDecoration(
                                              labelText: "Select Account Sub-Type",
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) => value == null
                                                ? 'Please select account sub-type'
                                                : null,
                                          ),
                                        const SizedBox(height: 30),

                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF00496d),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 30, vertical: 12),
                                              ),
                                              onPressed: () async {
                                                if (_formKey.currentState!.validate()) {
                                                  final progress = ProgressHUD.of(context);
                                                  progress!.show();

                                                  try {
                                                    // Save form data
                                                    String nameTxt = accountController.text.trim();

                                                    setState(() {
                                                      previewName = nameTxt;
                                                      previewClass = _selectedAccountClass;
                                                      previewSubType = _selectedSubType;
                                                    });

                                                    // Simulate save to Firebase
                                                    final data = CoaModel(
                                                      name: nameTxt,
                                                      schoolId: value.schoolid,
                                                      accountType: _selectedAccountClass!,
                                                      subType: _selectedSubType!, id: '',
                                                    );

                                                    await value.db
                                                        .collection("mainaccounts")
                                                        .doc(nameTxt)
                                                        .set(data.toJson());

                                                    progress.dismiss();

                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text("Data Saved Successfully"),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
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
                                              label: const Text(
                                                "Save Account",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF00496d),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 30, vertical: 12),
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  Navigator.pushNamed(context, Routes.accountchartview);
                                                });
                                              },
                                              icon: const Icon(Icons.view_comfy_alt_outlined, color: Colors.white),
                                              label: const Text(
                                                "View Accounts",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
        },
      ),
    );
  }
}
