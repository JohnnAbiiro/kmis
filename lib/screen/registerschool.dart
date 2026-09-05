import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../controller/dbmodels/schoolmodel.dart';

class RegisterSchool extends StatefulWidget {
  final SchoolModel? school;
  const RegisterSchool({Key? key, this.school}) : super(key: key);

  @override
  State<RegisterSchool> createState() => _RegisterSchoolState();
}

class _RegisterSchoolState extends State<RegisterSchool> {
  final _formKey = GlobalKey<FormState>();
  final schoolName = TextEditingController();
  final prefix = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final countryName = TextEditingController();
  final countryCode = TextEditingController();
  final schoolId = TextEditingController();

  // Notification Controllers
  final smsSenderId = TextEditingController();
  final smtpHost = TextEditingController(text: "smtp.gmail.com");
  final smtpPort = TextEditingController(text: "465");
  final smtpEmail = TextEditingController();
  final smtpPassword = TextEditingController();

  bool agreedToTerms = true;
  String schoolType = 'Pre-tertiary';
  bool _isLoadingSchool = false;

  String? _uploadedLogoUrl = '';

  @override
  void initState() {
    super.initState();
    final data = widget.school;
    if (data != null) {
      _prefill(
        schoolname: data.schoolname,
        prefix: data.prefix,
        address: data.address,
        email: data.email,
        phone: data.phone,
        countryName: data.countryName,
        countryCode: data.countryCode,
        schoolId: data.schoolId,
        agreedToTerms: data.agreedToTerms,
        type: data.type,
        logoUrl: data.logoUrl,
      );
    }
    Future.microtask(() {
      final provider = Provider.of<Myprovider>(context, listen: false);
      if (provider.schoolid.isNotEmpty) {
        _fetchSchool(provider.schoolid);
      }
    });
  }

  void _prefill({
    String? schoolname,
    String? prefix,
    String? address,
    String? email,
    String? phone,
    String? countryName,
    String? countryCode,
    String? schoolId,
    bool? agreedToTerms,
    String? type,
    String? logoUrl,
    String? smsSenderId,
    String? smtpHost,
    int? smtpPort,
    String? smtpEmail,
    String? smtpPassword,
  }) {
    if (schoolname != null) this.schoolName.text = schoolname;
    if (prefix != null) this.prefix.text = prefix;
    if (address != null) this.address.text = address;
    if (email != null) this.email.text = email;
    if (phone != null) this.phone.text = phone;
    if (countryName != null) this.countryName.text = countryName;
    if (countryCode != null) this.countryCode.text = countryCode;
    if (schoolId != null) this.schoolId.text = schoolId;
    if (agreedToTerms != null) this.agreedToTerms = agreedToTerms;
    if (type != null) schoolType = type == 'Tertiary' ? 'Tertiary' : 'Pre-tertiary';
    if (logoUrl != null) _uploadedLogoUrl = logoUrl;

    if (smsSenderId != null) this.smsSenderId.text = smsSenderId;
    if (smtpHost != null) this.smtpHost.text = smtpHost;
    if (smtpPort != null) this.smtpPort.text = smtpPort.toString();
    if (smtpEmail != null) this.smtpEmail.text = smtpEmail;
    if (smtpPassword != null) this.smtpPassword.text = smtpPassword;
  }

  Future<void> _fetchSchool(String id) async {
    setState(() => _isLoadingSchool = true);
    try {
      final provider = Provider.of<Myprovider>(context, listen: false);
      final doc = await provider.db.collection('schools').doc(id).get();
      if (doc.exists && mounted) {
        final map = doc.data()!;
        setState(() {
          _prefill(
            schoolname: map['schoolname'] as String?,
            prefix: map['prefix'] as String?,
            address: map['address'] as String?,
            email: map['email'] as String?,
            phone: map['phone'] as String?,
            countryName: map['countryName'] as String?,
            countryCode: map['countryCode'] as String?,
            schoolId: map['schoolId'] as String?,
            agreedToTerms: map['agreedToTerms'] as bool?,
            type: map['type'] as String?,
            logoUrl: map['logoUrl'] as String?,
            smsSenderId: map['smsSenderId'] as String?,
            smtpHost: map['smtpHost'] as String?,
            smtpPort: map['smtpPort'] as int?,
            smtpEmail: map['smtpEmail'] as String?,
            smtpPassword: map['smtpPassword'] as String?,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load school details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingSchool = false);
    }
  }

  @override
  void dispose() {
    schoolName.dispose();
    prefix.dispose();
    address.dispose();
    email.dispose();
    phone.dispose();
    countryName.dispose();
    countryCode.dispose();
    schoolId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFF2C2C3C);
    final isEdit = widget.school != null;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF00273a),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go(Routes.dashboard),
              ),
              title: Text(
                isEdit ? 'Edit School' : 'Register School',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            body: _isLoadingSchool
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: const Color(0xFFffffff),
                  margin: const EdgeInsets.all(30.0),
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: schoolName,
                            label: "School Name",
                            hint: "Enter school name",
                            validatorMsg: 'School name cannot be empty',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: prefix,
                            label: "School Prefix",
                            hint: "Enter unique prefix (e.g. lamp)",
                            validatorMsg: 'Prefix cannot be empty',
                            fillColor: isEdit ? Colors.grey[800]! : inputFill,
                            readOnly: isEdit,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: address,
                            label: "Address",
                            hint: "Enter school address",
                            validatorMsg: 'Address cannot be empty',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: email,
                            label: "Email",
                            hint: "Enter school email",
                            validatorMsg: 'Email cannot be empty',
                            fillColor: inputFill,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: phone,
                            label: "Phone",
                            hint: "Enter school phone",
                            validatorMsg: 'Phone cannot be empty',
                            fillColor: inputFill,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: countryName,
                            label: "Country Name",
                            hint: "Enter country (e.g. Ghana)",
                            validatorMsg: 'Country name cannot be empty',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: countryCode,
                            label: "Country Code",
                            hint: "Enter country code (e.g. +233)",
                            validatorMsg: 'Country code cannot be empty',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: schoolId,
                            label: "School ID",
                            hint: "Enter school ID (e.g. KS0001)",
                            validatorMsg: 'School ID cannot be empty',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: schoolType,
                            decoration: const InputDecoration(
                              labelText: 'School Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Pre-tertiary',
                                child: Text('Pre-tertiary'),
                              ),
                              DropdownMenuItem(
                                value: 'Tertiary',
                                child: Text('Tertiary'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => schoolType = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Notification Settings",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00496d),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: smsSenderId,
                            label: "SMS Sender ID",
                            hint: "e.g. KOLOGSOFT",
                            validatorMsg: 'Sender ID required for SMS',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: smtpHost,
                            label: "SMTP Host",
                            hint: "e.g. smtp.gmail.com",
                            validatorMsg: 'SMTP host required',
                            fillColor: inputFill,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: smtpPort,
                            label: "SMTP Port",
                            hint: "e.g. 465 or 587",
                            validatorMsg: 'SMTP port required',
                            fillColor: inputFill,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: smtpEmail,
                            label: "SMTP Email",
                            hint: "e.g. yourschool@gmail.com",
                            validatorMsg: 'SMTP email required',
                            fillColor: inputFill,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: smtpPassword,
                            label: "SMTP App Password",
                            hint: "Enter Gmail App Password",
                            validatorMsg: 'SMTP password required',
                            fillColor: inputFill,
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: agreedToTerms,
                                onChanged: (val) {
                                  setState(() => agreedToTerms = val ?? false);
                                },
                                activeColor: Color(0xFF00496d),
                              ),
                              const Expanded(
                                child: Text(
                                  "I agree to the terms & conditions",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              final progress = ProgressHUD.of(context);
                              progress?.show();

                              String schoolNameTxt = schoolName.text.trim();
                              String prefixTxt = prefix.text.trim().toUpperCase();
                              String addressTxt = address.text.trim();
                              String emailTxt = email.text.trim();
                              String phoneTxt = phone.text.trim();
                              String countryNameTxt = countryName.text.trim();
                              String countryCodeTxt = countryCode.text.trim();
                              String schoolIdTxt = schoolId.text.trim();

                              final school = SchoolModel(
                                id: widget.school?.id ?? prefixTxt,
                                schoolname: schoolNameTxt,
                                prefix: prefixTxt,
                                address: addressTxt,
                                email: emailTxt,
                                phone: phoneTxt,
                                logoUrl: "dd".isNotEmpty
                                    ? ""
                                    : _uploadedLogoUrl ?? "",
                                createdAt: DateTime.now(),
                                countryName: countryNameTxt,
                                countryCode: countryCodeTxt,
                                schoolId: schoolIdTxt,
                                agreedToTerms: agreedToTerms,
                                type: schoolType,
                                smsSenderId: smsSenderId.text.trim(),
                                smtpHost: smtpHost.text.trim(),
                                smtpPort: int.tryParse(smtpPort.text.trim()) ?? 465,
                                smtpEmail: smtpEmail.text.trim(),
                                smtpPassword: smtpPassword.text.trim(),
                              );

                              await value.db
                                  .collection("schools")
                                  .doc(school.id)
                                  .set(school.toMap(), SetOptions(merge: true));

                              final prefs = await SharedPreferences.getInstance();
                              await Future.wait([
                                prefs.setString('schoolid', school.schoolId),
                                prefs.setString('school', school.schoolname),
                                prefs.setString('schoolType', school.type),
                              ]);

                              progress?.dismiss();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit
                                      ? 'School Updated Successfully'
                                      : 'School Registered Successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: Icon(isEdit ? Icons.update : Icons.save),
                            label: Text(isEdit ? 'Update School' : 'Register School'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00496d),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String validatorMsg,
    required Color fillColor,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00496d))),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        filled: false,
        fillColor: fillColor,
      ),
      style: TextStyle(
        fontSize: 14,
        color: readOnly ? Colors.black54 : Colors.black,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        return null;
      },
    );
  }
}