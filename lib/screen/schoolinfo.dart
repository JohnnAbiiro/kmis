import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../controller/dbmodels/schoolmodel.dart';

class Schoolinfo extends StatefulWidget {
  final SchoolModel? school;
  const Schoolinfo({Key? key, this.school}) : super(key: key);

  @override
  State<Schoolinfo> createState() => _SchoolinfoState();
}

class _SchoolinfoState extends State<Schoolinfo> {
  final _formKey = GlobalKey<FormState>();
  final schoolName = TextEditingController();
  final prefix = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final countryName = TextEditingController();
  final countryCode = TextEditingController();
  final schoolId = TextEditingController();
  bool agreedToTerms = true;
  String schoolType = 'Pre-tertiary';
  bool _isLoadingSchool = false;

  String? _uploadedLogoUrl = '';

  // True once we have a real school record on hand — either passed in
  // directly or found via provider.schoolid. Drives the locked/read-only
  // default: an existing record should never be editable by accident, so
  // the form opens locked and only unlocks when the person taps Edit.
  bool _hasExistingSchool = false;

  // Whether the locked fields are currently unlocked for editing. Always
  // true (irrelevant, since _fieldsLocked is false) when there's no
  // existing school to protect yet.
  bool _unlocked = false;

  bool get _fieldsLocked => _hasExistingSchool && !_unlocked;

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
      _hasExistingSchool = true;
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
          );
          _hasExistingSchool = true;
          // A fresh fetch is the source of truth — drop any in-progress
          // unsaved edits so the form reflects what's actually stored.
          _unlocked = false;
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

  /// Discards any unsaved edits and re-locks the form by reloading from
  /// whichever source of truth is available.
  Future<void> _cancelEdit() async {
    final provider = Provider.of<Myprovider>(context, listen: false);
    if (provider.schoolid.isNotEmpty) {
      await _fetchSchool(provider.schoolid);
    } else if (widget.school != null) {
      _prefill(
        schoolname: widget.school!.schoolname,
        prefix: widget.school!.prefix,
        address: widget.school!.address,
        email: widget.school!.email,
        phone: widget.school!.phone,
        countryName: widget.school!.countryName,
        countryCode: widget.school!.countryCode,
        schoolId: widget.school!.schoolId,
        agreedToTerms: widget.school!.agreedToTerms,
        type: widget.school!.type,
        logoUrl: widget.school!.logoUrl,
      );
    }
    if (mounted) setState(() => _unlocked = false);
  }

  Future<void> _handleSave(Myprovider value) async {
    if (!_formKey.currentState!.validate()) return;

    final progress = ProgressHUD.of(context);
    progress?.show();

    try {
      final schoolNameTxt = schoolName.text.trim();
      final prefixTxt = prefix.text.trim().toUpperCase();
      final addressTxt = address.text.trim();
      final emailTxt = email.text.trim();
      final phoneTxt = phone.text.trim();
      final countryNameTxt = countryName.text.trim();
      final countryCodeTxt = countryCode.text.trim();
      final schoolIdTxt = schoolId.text.trim();

      final school = SchoolModel(
        id: widget.school?.id ?? prefixTxt,
        schoolname: schoolNameTxt,
        prefix: prefixTxt,
        address: addressTxt,
        email: emailTxt,
        phone: phoneTxt,
        // Previously this always evaluated to "" (a leftover
        // "dd".isNotEmpty placeholder), silently wiping the logo on every
        // save. Now it actually preserves whatever was loaded/uploaded.
        logoUrl: _uploadedLogoUrl ?? "",
        createdAt: DateTime.now(),
        countryName: countryNameTxt,
        countryCode: countryCodeTxt,
        schoolId: schoolIdTxt,
        agreedToTerms: agreedToTerms,
        type: schoolType,
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hasExistingSchool
              ? 'School Updated Successfully'
              : 'School Registered Successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Saved successfully — this is now an existing record, so lock the
      // form again rather than leaving it open for further edits.
      setState(() {
        _hasExistingSchool = true;
        _unlocked = false;
      });
    } catch (e) {
      progress?.dismiss();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save school: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, value, child) {
          final title = !_hasExistingSchool
              ? 'Register School'
              : (_unlocked ? 'Edit School' : 'School Information');

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF00273a),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go(Routes.dashboard),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                if (_hasExistingSchool && !_unlocked)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: 'Edit school details',
                    onPressed: () => setState(() => _unlocked = true),
                  ),
                if (_hasExistingSchool && _unlocked)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Cancel editing',
                    onPressed: _cancelEdit,
                  ),
              ],
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
                          if (_hasExistingSchool && !_unlocked)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.lock_outline, size: 16, color: Colors.black45),
                                  SizedBox(width: 6),
                                  Text(
                                    "Tap the edit icon above to make changes",
                                    style: TextStyle(color: Colors.black45, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                          _buildTextField(
                            controller: schoolName,
                            label: "School Name",
                            hint: "Enter school name",
                            validatorMsg: 'School name cannot be empty',
                            fillColor: inputFill,
                            readOnly: _fieldsLocked,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: prefix,
                            label: "School Prefix",
                            hint: "Enter unique prefix (e.g. lamp)",
                            validatorMsg: 'Prefix cannot be empty',
                            // Prefix is the record's own doc id — it stays
                            // locked whenever a school already exists, even
                            // while other fields are unlocked for editing,
                            // since changing it would mean writing to a
                            // different document rather than updating this
                            // one.
                            fillColor: _hasExistingSchool ? Colors.grey[300]! : inputFill,
                            readOnly: _hasExistingSchool,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: address,
                            label: "Address",
                            hint: "Enter school address",
                            validatorMsg: 'Address cannot be empty',
                            fillColor: inputFill,
                            readOnly: _fieldsLocked,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: email,
                            label: "Email",
                            hint: "Enter school email",
                            validatorMsg: 'Email cannot be empty',
                            fillColor: inputFill,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: _fieldsLocked,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: phone,
                            label: "Phone",
                            hint: "Enter school phone",
                            validatorMsg: 'Phone cannot be empty',
                            fillColor: inputFill,
                            keyboardType: TextInputType.phone,
                            readOnly: _fieldsLocked,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: countryName,
                            label: "Country Name",
                            hint: "Enter country (e.g. Ghana)",
                            validatorMsg: 'Country name cannot be empty',
                            fillColor: inputFill,
                            readOnly: _fieldsLocked,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: countryCode,
                            label: "Country Code",
                            hint: "Enter country code (e.g. +233)",
                            validatorMsg: 'Country code cannot be empty',
                            fillColor: inputFill,
                            readOnly: _fieldsLocked,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: schoolId,
                            label: "School ID",
                            hint: "Enter school ID (e.g. KS0001)",
                            validatorMsg: 'School ID cannot be empty',
                            // Same reasoning as prefix — schoolid is a
                            // stable identifier used elsewhere in the app
                            // (provider.schoolid), so it stays locked
                            // whenever a school already exists.
                            fillColor: _hasExistingSchool ? Colors.grey[300]! : inputFill,
                            readOnly: _hasExistingSchool,
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
                            onChanged: _fieldsLocked
                                ? null
                                : (value) {
                              if (value != null) {
                                setState(() => schoolType = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: agreedToTerms,
                                onChanged: _fieldsLocked
                                    ? null
                                    : (val) {
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
                          // Locked view is read-only display — no reason to
                          // show a Save button until Edit has been tapped.
                          if (!_hasExistingSchool || _unlocked)
                            ElevatedButton.icon(
                              onPressed: () => _handleSave(value),
                              icon: Icon(_hasExistingSchool ? Icons.update : Icons.save),
                              label: Text(_hasExistingSchool ? 'Update School' : 'Register School'),
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