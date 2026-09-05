import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/singleBilledModel.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:ksoftsms/widgets/dropdown.dart';
import '../components/billingpdf.dart';
import 'package:pdf/pdf.dart';
import '../controller/dbmodels/contestantsmodel.dart';

class SingleBilling extends StatefulWidget {
  const SingleBilling({super.key});

  @override
  State<SingleBilling> createState() => _SingleBillingState();
}

class _SingleBillingState extends State<SingleBilling> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
      await provider.getdata();
      await provider.fetchterms();
      provider.fetchFess();

      if (mounted && provider.term.isNotEmpty) {
        setState(() {
          selectedTerm = provider.term;
        });
      }
    });
    accountController.addListener(() => setState(() {}));
  }

  final accountController = TextEditingController();
  final searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedTerm;
  String? selectedfee;
  Map<String, String> customAmounts = {};

  @override
  void dispose() {
    accountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _showAdjustAmountDialog(BuildContext context, StudentModel student, ColorScheme colors) async {
    final controller = TextEditingController(text: customAmounts[student.studentid] ?? accountController.text);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Adjust Fee for ${student.name}"),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: const InputDecoration(
            labelText: "Custom Amount (GHS)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              final numVal = double.tryParse(val);
              final defaultVal = double.tryParse(accountController.text.trim()) ?? 0.0;

              if (val.isNotEmpty && numVal != null) {
                setState(() {
                  if (numVal == defaultVal) {
                    customAmounts.remove(student.studentid);
                  } else {
                    customAmounts[student.studentid] = val;
                  }
                });
              }
              Navigator.pop(ctx);
            }, 
            child: const Text("SAVE")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            appBar: AppBar(
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              title: Text(
                '${provider.currentschool.toUpperCase()} MULTI-STUDENT BILLING',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 1000;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: isMobile 
                        ? _buildMobileLayout(context, provider, colors)
                        : _buildDesktopLayout(context, provider, colors),
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Myprovider provider, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        children: [
          if (provider.loadterms)
            const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT: Selection Section
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildFormContent(context, provider, colors),
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant, thickness: 1.5),
                  // RIGHT: Preview Section
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: colors.primaryContainer.withOpacity(0.03),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildPreviewContent(context, provider, colors),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildActionButtons(context, provider, colors),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Myprovider provider, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (provider.loadterms)
            const Padding(padding: EdgeInsets.only(bottom: 16), child: LinearProgressIndicator(minHeight: 2)),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildFormContent(context, provider, colors),
                ),
                Divider(height: 1, color: colors.outlineVariant, thickness: 1.5),
                Container(
                  color: colors.primaryContainer.withOpacity(0.03),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPreviewContent(context, provider, colors),
                      const SizedBox(height: 24),
                      _buildActionButtons(context, provider, colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, Myprovider provider, ColorScheme colors) {
    final inputFill = colors.surface;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_alt_1_outlined, color: colors.primary),
              const SizedBox(width: 12),
              const Text("Student Selection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Search Student by Name",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  provider.emptysearchResults();
                },
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (q) {
              if (q.isEmpty) {
                provider.emptysearchResults();
              } else {
                provider.searchStudents(q);
              }
            },
          ),
          
          if (provider.searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = provider.searchResults[index];
                  final isSelected = provider.selectedStudents.any((s) => s.studentid == student.studentid);
                  return ListTile(
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${student.studentid} • ${student.level}"),
                    trailing: Icon(
                      isSelected ? Icons.check_circle : Icons.add_circle_outline,
                      color: isSelected ? Colors.green : Colors.grey,
                    ),
                    onTap: () => provider.addStudent(student),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 32),
          _buildSectionLabel("Billing Details"),
          const SizedBox(height: 16),
          TextFormField(
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: accountController,
            decoration: const InputDecoration(
              labelText: "Billed Amount (GHS)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            validator: (value) => value == null || value.trim().isEmpty ? "Amount is required" : null,
          ),
          const SizedBox(height: 20),
          _buildTwoInRow(
            DropdownWidget.buildDropdown(
              dropdownContext: context,
              value: selectedfee,
              items: provider.fees.map((e) => e.name).toList(),
              label: "FEE CATEGORY",
              fillColor: inputFill,
              onChanged: (v) => setState(() => selectedfee = v),
              validatorMsg: 'Select Fees',
            ),
            DropdownWidget.buildDropdown(
              dropdownContext: context,
              value: selectedTerm,
              items: provider.terms.map((e) => e.name).toList(),
              label: "ACADEMIC TERM",
              fillColor: inputFill,
              onChanged: (v) => setState(() => selectedTerm = v),
              validatorMsg: "Select Term",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context, Myprovider provider, ColorScheme colors) {
    final defaultAmount = accountController.text.isEmpty ? 0.0 : double.tryParse(accountController.text) ?? 0.0;
    
    double totalValue = 0;
    for (var s in provider.selectedStudents) {
      if (customAmounts.containsKey(s.studentid)) {
        totalValue += double.tryParse(customAmounts[s.studentid]!) ?? 0.0;
      } else {
        totalValue += defaultAmount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: colors.primary, size: 20),
            const SizedBox(width: 10),
            Text("BILLING SUMMARY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: colors.primary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 24),
        _previewItem("FEE CATEGORY", selectedfee ?? "---"),
        _previewItem("ACADEMIC TERM", selectedTerm ?? "---"),
        
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.group_outlined, color: colors.primary, size: 18),
            const SizedBox(width: 8),
            const Text("SELECTED STUDENTS", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant, width: 1),
          ),
          child: provider.selectedStudents.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_outlined, color: colors.outline, size: 32),
                    const SizedBox(height: 8),
                    Text("No students selected", style: TextStyle(color: colors.outline, fontSize: 12)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: provider.selectedStudents.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: colors.outlineVariant.withOpacity(0.5)),
                itemBuilder: (context, index) {
                  final s = provider.selectedStudents[index];
                  final customAmount = customAmounts[s.studentid];

                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: colors.primary.withOpacity(0.1),
                      child: Text(s.name[0].toUpperCase(), style: TextStyle(fontSize: 9, color: colors.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(s.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      customAmount != null ? "GHS $customAmount (CUSTOM)" : "${s.studentid} • ${s.level}", 
                      style: TextStyle(fontSize: 9, color: customAmount != null ? colors.primary : null, fontWeight: customAmount != null ? FontWeight.bold : null)
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 16, color: colors.primary),
                          onPressed: () async {
                            await _showAdjustAmountDialog(context, s, colors);
                            // Main screen will rebuild via the setState inside the dialog
                          },
                          tooltip: "Adjust Fee",
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                          onPressed: () {
                            provider.removeStudent(s.studentid);
                            setState(() => customAmounts.remove(s.studentid));
                          },
                          tooltip: "Remove",
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TOTAL BILL VALUE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                Text("For ${provider.selectedStudents.length} Students", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            Text("GHS ${provider.numberFormat.format(totalValue)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.primary)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Myprovider provider, ColorScheme colors) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => _handleSave(context, provider),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("GENERATE BILLS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        if (provider.selectedStudents.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _downloadReport(provider, accountController.text.trim()),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text("DOWNLOAD BILLING LIST", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, Routes.singlebillingview),
            icon: const Icon(Icons.list_alt, size: 20),
            label: const Text("VIEW BILLING HISTORY", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildTwoInRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));
  }

  Widget _previewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, Myprovider value) async {
    if (value.selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select at least one student")));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    
    final progress = ProgressHUD.of(context);
    progress!.show();

    try {
      String defaultAmount = accountController.text.trim();
      int successCount = 0;

      for (var student in value.selectedStudents) {
        String yearGroup = student.yeargroup;
        String department = student.department;
        String level = student.level;
        String sid = student.studentid;
        String ids = "single-${value.schoolid}$yearGroup$selectedTerm$department$level$selectedfee$sid";
        String id = ids.replaceAll(RegExp(r'\s+'), '').toLowerCase();

        final dataexist = await value.db.collection("singlebilled").doc(id).get();

        if (!dataexist.exists) {
          String billingAmount = customAmounts[student.studentid] ?? defaultAmount;
          
          final data = SingleBilledModel(
            level: student.level,
            yeargroup: student.yeargroup,
            amount: billingAmount,
            activityType: "Fee Billing",
            term: selectedTerm.toString(),
            schoolId: value.schoolid,
            staff: value.name,
            staffId: value.staffid,
            dateCreated: DateTime.now(),
            feeName: selectedfee.toString(),
            studentId: student.studentid,
            studentName: student.name,
            ledgerid: id
          ).toJson();

          await value.db.collection("singlebilled").doc(id).set(data);
          successCount++;
        }
      }

      progress.dismiss();
      
      if (successCount > 0) {
        if (context.mounted) {
          _showSuccessDialog(context, value, defaultAmount, successCount);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selected students already billed for this fee")));
        }
      }
    } catch (e) {
      progress.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadReport(Myprovider provider, String defaultAmount) async {
    final amountPerStudent = double.tryParse(defaultAmount) ?? 0.0;
    
    List<Map<String, dynamic>> studentsData = [];
    double totalValue = 0;

    for (var s in provider.selectedStudents) {
      double billed = customAmounts.containsKey(s.studentid) 
          ? (double.tryParse(customAmounts[s.studentid]!) ?? 0.0) 
          : amountPerStudent;
          
      studentsData.add({
        'studentId': s.studentid,
        'name': s.name,
        'sex': s.sex,
        'amount': provider.numberFormat.format(billed),
      });
      totalValue += billed;
    }

    final printer = BillingReportPrinter(
      schoolName: provider.currentschool,
      schoolAddress: "BOLGA, UPPER EAST", 
      schoolEmail: "info@kologsoft.com",
      schoolWebsite: "www.kologsoft.com",
      schoolPhone: "+233 553 354 349",
      logoAssetPath: "assets/images/logo.png",
      term: selectedTerm ?? "---",
      feeName: selectedfee ?? "---",
      targetGroup: "Multi-Student Selection",
      students: studentsData,
      totalAmount: provider.numberFormat.format(totalValue),
    );

    final pdfBytes = await printer.generatePdf(PdfPageFormat.a4, "Billing-Report");
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  void _showSuccessDialog(BuildContext context, Myprovider provider, String amount, int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Billing Successful", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("GHS $amount has been billed to $count student(s)."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                accountController.clear();
                selectedfee = null;
                provider.clearSelectedStudents();
                customAmounts.clear();
              });
            }, 
            child: const Text("OK")
          ),
          ElevatedButton.icon(
            onPressed: () => _downloadReport(provider, amount),
            icon: const Icon(Icons.download),
            label: const Text("DOWNLOAD REPORT"),
          ),
        ],
      ),
    );
  }
}

