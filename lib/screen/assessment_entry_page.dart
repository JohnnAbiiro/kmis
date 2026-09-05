import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class AssessmentEntryPage extends StatefulWidget {

   AssessmentEntryPage({super.key});

  @override
  State<AssessmentEntryPage> createState() => _AssessmentEntryPageState();
}

class _AssessmentEntryPageState extends State<AssessmentEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  late Map<String, dynamic> assessment;
  late List components=[];

  double totalMarks = 0;
  double scalePercentage = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadAssessment();
    });
  }

   loadAssessment() async {
     final provider = Provider.of<Myprovider>(context, listen: false);
     final Gsystem = await provider.selectedGradingSystem;
     await provider.loadStudentDetails();
    if (Gsystem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No grading system selected")),
      );
      Navigator.pop(context);
      return;
    }

    final assessments = Map<String, dynamic>.from(Gsystem['assessments'] ?? {});

    if (!assessments.containsKey(provider.assessmentType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${provider.assessmentType} assessment not found")),
      );
     // Navigator.pop(context);
      return;
    }

    assessment = Map<String, dynamic>.from(assessments[provider.assessmentType]);

    components = List<Map<String, dynamic>>.from(assessment['components'] ?? []);

    totalMarks = (assessment['totalMarks'] ?? 0).toDouble();
    scalePercentage = (assessment['scalePercentage'] ?? 0).toDouble();

    for (final c in components) {
      _controllers[c['name']] = TextEditingController(text: "0");
    }

    setState(() => loading = false);
  }

  double get enteredTotal =>
      _controllers.values.fold(
        0,
            (sum, c) => sum + (double.tryParse(c.text) ?? 0),
      );

  double get scaledScore =>
      totalMarks == 0 ? 0 : (enteredTotal / totalMarks) * scalePercentage;

  @override
  void dispose() {
    final Map<String, double> componentScores = {};

    for (final c in components) {
      final name = c['name'];
      final value = double.tryParse(_controllers[name]?.text ?? '0') ?? 0;

      componentScores[name] = value;
    }
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final provider = Provider.of<Myprovider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF2D2F45),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, Routes.staffscoring),
        ),
        title: Text("${provider.assessmentType}",style: const TextStyle(color: Colors.white),),
        backgroundColor:const Color(0xFF2D2F45),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [


                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (provider.imageUrl.isNotEmpty)
                        ? NetworkImage(provider.imageUrl)
                        : const AssetImage('assets/images/logo.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(provider.studentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                  Text("ID: ${provider.studentId}", style: const TextStyle(color: Colors.white70)),
                  Text("Class: ${provider.className}", style: const TextStyle(color: Colors.white70)),
                  Text("Subject: ${provider.subject}", style: const TextStyle(color: Colors.white70)),


              const SizedBox(height: 16),

              /// DYNAMIC COMPONENT FIELDS
              ...components.map((c) {
                final max = (c['maxMarks'] as num).toDouble();
                final controller = _controllers[c['name']]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(

                    style: const TextStyle(color: Colors.white),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    decoration: InputDecoration(

                      labelText: "${c['name']} (Max $max)",
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: const OutlineInputBorder(),
                    ),

                    onChanged: (value) {
                      final entered = double.tryParse(value);
                      if (entered == null) return;

                      if (entered > max) {
                        controller.value = TextEditingValue(
                          text: max.toStringAsFixed(0),
                          selection: TextSelection.collapsed(
                            offset: max.toStringAsFixed(0).length,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Maximum allowed for ${c['name']} is $max"),
                            duration: const Duration(milliseconds: 800),
                          ),
                        );
                      }

                      setState(() {}); // update totals live
                    },

                    validator: (v) {
                      final val = double.tryParse(v ?? "");
                      if (val == null) return "Invalid number";
                      if (val < 0) return "Cannot be negative";
                      if (val > max) return "Max $max";
                      return null;
                    },
                  ),
                );
              }).toList(),

              const Divider(),

              /// TOTALS
              Text(
                "Total: $enteredTotal / $totalMarks",
                style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
              ),
              Text(
                "Scaled Score: ${scaledScore.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              /// SAVE BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),

                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    if (enteredTotal > totalMarks) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Total exceeds allowed marks"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final List<Map<String, dynamic>> componentScores = components.map((c) {
                      final String name = c['name'];
                      final double maxMarks = (c['maxMarks'] as num).toDouble();
                      final double score =
                          double.tryParse(_controllers[name]?.text ?? '0') ?? 0;

                      return {
                        'name': name,
                        'maxMarks': maxMarks,
                        'score': score,
                      };
                    }).toList();

                    final assessmentData = {
                      'studentId': provider.studentId,
                      'studentName': provider.studentName,
                      'school': provider.schooldomain,
                      'schoolId': provider.schoolid,
                      'sex': provider.studentName,
                      'level': '',
                      'class': provider.className,
                      'date': DateTime.now(),
                      // Group by subjectkey
                      'assessmentdata': {
                        provider.subjectkey: {
                          'subject': provider.subject,
                          'total${provider.assessmentType}': enteredTotal,
                          'scaled${provider.assessmentType}': scaledScore.toStringAsFixed(2),
                          // Nest assessmentType under subject
                          provider.assessmentType: {
                            'components': componentScores,
                            'totalObtained': enteredTotal,
                            'scaledScore': scaledScore.toStringAsFixed(2),
                          },
                        }
                      }
                    };

                    await provider.saveAssessmentData(assessmentData);
                    await provider.updateStudentAssessmentData("${provider.schoolid}${"_"}${provider.studentId}",provider.subjectkey);
                    //print("Saving assessment ${provider.assessmentType} for ${assessmentData}");
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
