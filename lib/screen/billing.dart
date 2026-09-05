import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/dbmodels/billedModel.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../components/billingpdf.dart';
import '../controller/dbmodels/componentmodel.dart';
import '../controller/dbmodels/contestantsmodel.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../widgets/dropdown.dart';
import 'package:pdf/pdf.dart';

class Billing extends StatefulWidget {
  final ComponentModel? component;
  const Billing({super.key, this.component});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedLevel;
  String? selectedTerm;
  String? selecteddepart;
  String? selectedfee;
  String? selectedYearGroup;
  int targetStudentCount = 0;
  List<StudentModel> targetStudents = [];
  List<String> excludedStudents = [];
  Map<String, String> customAmounts = {};
  bool isLoadingCount = false;
  final List<String> _yeargroup = List.generate(5, (i) => (2022 + i).toString());

  String schoolid = "";
  String schoolname = "";
  String userid = "";

  @override
  void dispose() {
    accountController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudentCount(Myprovider provider) async {
    if (selectedLevel == null || selectedYearGroup == null) {
      setState(() {
        targetStudentCount = 0;
        targetStudents = [];
        excludedStudents = [];
        customAmounts = {};
      });
      return;
    }

    setState(() => isLoadingCount = true);
    try {
      final snap = await provider.db.collection("students")
          .where("schoolId", isEqualTo: provider.schoolid)
          .where("level", isEqualTo: selectedLevel)
          .where("yeargroup", isEqualTo: selectedYearGroup)
          .get();
      
      if (mounted) {
        setState(() {
          targetStudents = snap.docs.map((doc) => StudentModel.fromMap({...doc.data(), 'id': doc.id})).toList();
          targetStudentCount = snap.size;
          excludedStudents = [];
          customAmounts = {};
          isLoadingCount = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingCount = false);
    }
  }

  Future<void> _showAdjustAmountDialog(BuildContext context, StudentModel student, ColorScheme colors) async {
    final controller = TextEditingController(text: customAmounts[student.id] ?? accountController.text);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Adjust Fee for ${student.name}"),
        content: TextField(
          controller: controller,
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
                    customAmounts.remove(student.id);
                  } else {
                    customAmounts[student.id] = val;
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

  void _showStudentsModal(BuildContext context, ColorScheme colors) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 800 ? 750.0 : screenWidth * 0.95;
    
    showDialog(
      context: context,
      builder: (ctx) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredStudents = targetStudents.where((s) {
              final query = searchQuery.toLowerCase();
              return s.name.toLowerCase().contains(query) || 
                     s.studentid.toLowerCase().contains(query);
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group_outlined, color: colors.primary, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Target Students List", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("$selectedLevel • Batch $selectedYearGroup", style: TextStyle(fontSize: 13, color: colors.secondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search by name or ID...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: colors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                      ),
                      onChanged: (val) => setModalState(() => searchQuery = val),
                    ),
                  ],
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
              content: SizedBox(
                width: modalWidth,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: filteredStudents.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_outlined, size: 64, color: colors.outlineVariant),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty ? "No students found in selection" : "No matches for '$searchQuery'",
                              style: TextStyle(color: colors.outline, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 550 ? 2 : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: filteredStudents.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisExtent: 80,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              final s = filteredStudents[index];
                              final isExcluded = excludedStudents.contains(s.id);
                              final customAmount = customAmounts[s.id];
                              
                              return Opacity(
                                opacity: isExcluded ? 0.5 : 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isExcluded ? Colors.red.withOpacity(0.3) : colors.outlineVariant.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isExcluded ? Colors.red.withOpacity(0.02) : null,
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: colors.primary.withOpacity(0.1),
                                      backgroundImage: s.photourl.isNotEmpty ? NetworkImage(s.photourl) : null,
                                      child: s.photourl.isEmpty 
                                        ? Text(s.name[0].toUpperCase(), style: TextStyle(fontSize: 14, color: colors.primary, fontWeight: FontWeight.bold)) 
                                        : null,
                                    ),
                                    title: Text(
                                      s.name, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      isExcluded ? "EXCLUDED" : "GHS ${customAmount ?? accountController.text}", 
                                      style: TextStyle(
                                        fontSize: 10, 
                                        color: isExcluded ? Colors.red : (customAmount != null ? colors.primary : colors.onSurfaceVariant),
                                        fontWeight: customAmount != null || isExcluded ? FontWeight.bold : FontWeight.normal,
                                      )
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isExcluded)
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
                                            onPressed: () async {
                                              await _showAdjustAmountDialog(context, s, colors);
                                              // Refresh the modal state after the adjustment dialog closes
                                              setModalState(() {});
                                            },
                                            tooltip: "Adjust Fee",
                                          ),
                                        IconButton(
                                          icon: Icon(isExcluded ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 18, color: isExcluded ? Colors.green : Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              if (isExcluded) {
                                                excludedStudents.remove(s.id);
                                              } else {
                                                excludedStudents.add(s.id);
                                              }
                                            });
                                            setModalState(() {});
                                          },
                                          tooltip: isExcluded ? "Add back" : "Exclude",
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
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(ctx), 
                    child: const Text("DONE")
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<Myprovider>(context, listen: false);
       await provider.getdata();
       provider.getfetchRegions();
       provider.fetchdepart();
       provider.fetchclass();
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
                '${provider.currentschool.toUpperCase()} BULK BILLING',
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
          if (provider.loadterms || provider.loadschool)
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
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildFormContent(context, provider, colors),
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant, thickness: 1.5),
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
          if (provider.loadterms || provider.loadschool)
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
              Icon(Icons.auto_awesome_motion_outlined, color: colors.primary),
              const SizedBox(width: 12),
              const Text("Billing Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildSectionLabel("Fee Details"),
          const SizedBox(height: 16),
          _buildTwoInRow(
            TextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: accountController,
              decoration: const InputDecoration(
                labelText: "Amount per Student (GHS)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? "Amount is required" : null,
            ),
            DropdownWidget.buildDropdown(
              dropdownContext: context, 
              value: selectedfee, 
              items: provider.fees.map((e) => e.name).toList(), 
              label: "FEE CATEGORY", 
              fillColor: inputFill, 
              onChanged: (v) => setState(() => selectedfee = v), 
              validatorMsg: 'Select Fees',
            ),
          ),
          
          const SizedBox(height: 32),
          _buildSectionLabel("Target Audience"),
          const SizedBox(height: 16),
          _buildTwoInRow(
            DropdownWidget.buildDropdown(
              dropdownContext: context, 
              value: selectedLevel, 
              items: provider.classdata.map((e) => e.name).toList(), 
              label: "TARGET CLASS", 
              fillColor: inputFill, 
              onChanged: (v) {
                setState(() => selectedLevel = v);
                _fetchStudentCount(provider);
              }, 
              validatorMsg: 'Select class',
            ),
            DropdownWidget.buildDropdown(
              dropdownContext: context, 
              value: selectedYearGroup, 
              items: _yeargroup, 
              label: "YEAR GROUP", 
              fillColor: inputFill, 
              onChanged: (v) {
                setState(() => selectedYearGroup = v);
                _fetchStudentCount(provider);
              }, 
              validatorMsg: "Select year group",
            ),
          ),
          const SizedBox(height: 20),
          _buildTwoInRow(
            DropdownWidget.buildDropdown(
              dropdownContext: context, 
              value: selecteddepart, 
              items: provider.departments.map((e) => e.name).toList(), 
              label: "DEPARTMENT", 
              fillColor: inputFill, 
              onChanged: (v) => setState(() => selecteddepart = v), 
              validatorMsg: 'Select Department',
            ),
            DropdownWidget.buildDropdown(
              dropdownContext: context, 
              value: selectedTerm, 
              items: provider.terms.map((e)=>e.name).toList(), 
              label: "ACADEMIC TERM", 
              fillColor: inputFill, 
              onChanged: (v) => setState(() => selectedTerm = v), 
              validatorMsg: "Select term",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context, Myprovider provider, ColorScheme colors) {
    final defaultAmount = accountController.text.isEmpty ? 0.0 : double.tryParse(accountController.text) ?? 0.0;
    
    int finalCount = 0;
    double totalValue = 0;

    for (var s in targetStudents) {
      if (excludedStudents.contains(s.id)) continue;
      
      finalCount++;
      if (customAmounts.containsKey(s.id)) {
        totalValue += double.tryParse(customAmounts[s.id]!) ?? 0.0;
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
        _previewItem("TARGET GROUP", selectedLevel != null && selectedYearGroup != null ? "$selectedLevel ($selectedYearGroup)" : "---"),
        _previewItem("FEE CATEGORY", selectedfee ?? "---"),
        _previewItem("ACADEMIC TERM", selectedTerm ?? "---"),
        
        const SizedBox(height: 24),
        InkWell(
          onTap: targetStudentCount > 0 ? () => _showStudentsModal(context, colors) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: targetStudentCount > 0 ? colors.primary.withOpacity(0.5) : colors.outlineVariant,
                width: 1.5
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.group_outlined, color: targetStudentCount > 0 ? colors.primary : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("STUDENTS TO BE BILLED", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      if (isLoadingCount)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else
                        Text("$finalCount Students ${excludedStudents.isNotEmpty ? '(${excludedStudents.length} excluded)' : ''}", 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (targetStudentCount > 0)
                  Icon(Icons.open_in_new_rounded, size: 16, color: colors.primary),
              ],
            ),
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
                Text("For $finalCount Students", style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

  Widget _buildSectionLabel(String text) {
    return Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));
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
            label: const Text("GENERATE BULK BILLS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        if (targetStudentCount > 0)
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
            onPressed: () => Navigator.pushNamed(context, Routes.billingview),
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
    if (!_formKey.currentState!.validate()) return;
    
    final progress = ProgressHUD.of(context);
    progress!.show();
    String amount=accountController.text.trim();
    String ids="${value.schoolid}$selectedYearGroup$selectedTerm$selecteddepart$selectedLevel$selectedfee";
    String id = ids.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    try {
      final dataexist=await value.db.collection("billed").doc(id).get();
      if(dataexist.exists){
        progress.dismiss();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$selectedfee has been billed already"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      final data=BilledModel(
        level: selectedLevel.toString(), 
        yeargroup: selectedYearGroup.toString(), 
        amount: amount, 
        activityType: "Fee Billing", 
        term: selectedTerm.toString(), 
        schoolId: value.schoolid, 
        staff: value.name,
        staffId: value.staffid,
        dateCreated: DateTime.now(), 
        feeName:selectedfee.toString(), 
        ledgerid: id,
        excludedStudents: excludedStudents,
        customAmounts: customAmounts,
      ).toJson();
      
      await value.db.collection("billed").doc(id).set(data);

      progress.dismiss();

      if (context.mounted) {
        int finalCount = targetStudentCount - excludedStudents.length;
        _showSuccessDialog(context, value, amount, finalCount);
      }
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

  Future<void> _downloadReport(Myprovider provider, String defaultAmount) async {
    final amountPerStudent = double.tryParse(defaultAmount) ?? 0.0;
    
    List<Map<String, dynamic>> studentsData = [];
    double totalValue = 0;

    for (var s in targetStudents) {
      if (excludedStudents.contains(s.id)) continue;
      
      double billed = customAmounts.containsKey(s.id) 
          ? (double.tryParse(customAmounts[s.id]!) ?? 0.0) 
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
      targetGroup: "$selectedLevel ($selectedYearGroup)",
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
            Text("GHS $amount has been billed to $count students in $selectedLevel."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                accountController.clear();
                selectedLevel = null;
                selectedYearGroup = null;
                selectedfee = null;
                targetStudentCount = 0;
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
