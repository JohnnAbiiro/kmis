import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/staffmodel.dart';
import '../controller/routes.dart';

class Regstaff extends StatefulWidget {
  final Staff? staffData;
  const Regstaff({Key? key, this.staffData}) : super(key: key);

  @override
  State<Regstaff> createState() => _RegstaffState();
}

class _RegstaffState extends State<Regstaff> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _sex = ['Male', "Female"];
  String? myRegion;
  String? _selectedSex;
  String? _selectedAccessLevel;

  bool _showStaffContainer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
      context.read<Myprovider>().getfetchRegions();
      context.read<Myprovider>().staffcount();
    });
    // // final data = widget.staffData;
    // // if (data != null) {
    // //   name.text = data.name ?? '';
    // //   phone.text = data.phone ?? '';
    // //   _selectedSex = data.sex;
    // //   myRegion = data.region;
    // //   _selectedAccessLevel = data.accessLevel;
    // // }
  }

  @override
  Widget build(BuildContext context) {
    final inputFill = const Color(0xFFffffff);
    final isEdit = widget.staffData != null;

    return ProgressHUD(
      child: Builder(
        builder: (context) {
          return Consumer<Myprovider>(
            builder: (context, value, child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF00273a),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      context.go(Routes.dashboard);
                    },
                  ),
                  title: Text(value.currentschool,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                      builder: (context, constraints){
                        bool isWideScreen = constraints.maxWidth > 500;

                        return Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              Container(
                                color: const Color(0xFFffffff),
                                margin: const EdgeInsets.all(20),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 500),
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          // Name
                                          TextFormField(
                                            controller: nameController,
                                            decoration: _inputDecoration("Staff Name", "Enter Staff Name", inputFill),
                                            style: const TextStyle(fontSize: 16),
                                            validator: (value) =>
                                            value == null || value.trim().isEmpty ? 'Staff name cannot be empty' : null,
                                          ),
                                          const SizedBox(height: 20),
                                          // Phone
                                          TextFormField(
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            controller: phoneController,
                                            decoration: _inputDecoration("Phone", "Enter Phone Number", inputFill),
                                            style: const TextStyle(fontSize: 16),
                                            validator: (value) =>
                                            value == null || value.trim().isEmpty ? 'Phone number cannot be empty' : null,
                                          ),
                                          const SizedBox(height: 20),

                                          TextFormField(
                                            keyboardType: TextInputType.emailAddress,
                                            controller: emailController,
                                            decoration: _inputDecoration("Email", "Enter Email Address", inputFill),
                                            inputFormatters: [
                                              // deny spaces
                                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                            ],
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Please enter your email";
                                              }
                                              // simple email check
                                              if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                                                return "Enter a valid email";
                                              }
                                              return null;
                                            },
                                            style: const TextStyle(fontSize: 16),

                                          ),
                                          const SizedBox(height: 20),
                                          // Sex
                                          DropdownButtonFormField<String>(
                                            value: _selectedSex,
                                            items: _sex.map((cat) {
                                              return DropdownMenuItem(
                                                value: cat,
                                                child: Text(cat, style: const TextStyle(color: Colors.black54)),
                                              );
                                            }).toList(),
                                            dropdownColor: inputFill,
                                            onChanged: (value) => setState(() => _selectedSex = value),
                                            decoration: _inputDecoration("Sex", null, inputFill),
                                            validator: (value) => value == null ? 'Please select sex' : null,
                                          ),
                                          const SizedBox(height: 20),

                                          // Region
                                          DropdownButtonFormField<String>(
                                            value: myRegion,
                                            items: value.regionList.map((cat) {
                                              return DropdownMenuItem(
                                                value: cat.regionname,
                                                child: Text(cat.regionname, style: const TextStyle(color: Colors.black54)),
                                              );
                                            }).toList(),
                                            dropdownColor: inputFill,
                                            onChanged: (val) => setState(() => myRegion = val),
                                            decoration: _inputDecoration("Region", null, inputFill),
                                            validator: (value) => value == null ? 'Please select region' : null,
                                          ),
                                          const SizedBox(height: 20),

                                          // Access Level
                                          DropdownButtonFormField<String>(
                                            value: _selectedAccessLevel,
                                            items: value.staffaccesslevel.map((accesslevel) {
                                              return DropdownMenuItem(
                                                value: accesslevel,
                                                child: Text(accesslevel, style: const TextStyle(color: Colors.black54)),
                                              );
                                            }).toList(),
                                            onChanged: (val) => setState(() => _selectedAccessLevel = val),
                                            decoration: _inputDecoration("Access Level", null, inputFill),
                                            validator: (value) => value == null ? 'Please select access level' : null,
                                          ),
                                          const SizedBox(height: 30),
                                          // Buttons
                                          Column(
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
                                                        String nameTxt= nameController.text.trim();
                                                        String phoneTxt= phoneController.text.trim();
                                                        String sexTxt= _selectedSex ?? "";
                                                        String regionTxt= myRegion ?? "";
                                                        String emailTxt= emailController.text.trim().toString().toLowerCase();
                                                        String schoolId= value.schoolid ?? "";
                                                        String schoolName= value.currentschool ?? "";
                                                        DateTime createdAt= DateTime.now();
                                                        String accessLevelTxt= _selectedAccessLevel ?? "";
                                                        //get the next staffid
                                                        await value.staffcount();
                                                        String _staffcount=value.staffcount_in_school.toString();
                                                        String _staffid= value.schoolid! + _staffcount;
                                                        bool existstaffbyeamil=await value.staffexistbyemail(emailTxt);
                                                        bool existstaffbyphone=await value.staffexistbyphone(phoneTxt);
                                                        print("Number of docs: $schoolId");
                                                        if(existstaffbyeamil || existstaffbyphone)
                                                        {
                                                          SnackBar snackBar = const SnackBar(
                                                            content: Text('Staff with this Phone Number or Email already exists'),
                                                            backgroundColor: Colors.red,
                                                          );
                                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                          //await value.smsalert("Hello $nameTxt, you already exist in ${value.currentschool}", phoneTxt);
                                                          progress.dismiss();
                                                          return;
                                                        }
                                                        final staffdata=Staff(name: nameTxt, accessLevel: accessLevelTxt, phone: phoneTxt, email: emailTxt, sex: sexTxt, region: regionTxt, schoolId: schoolId, schoolname: schoolName, createdAt: createdAt).toMap();

                                                        await value.db.collection('staff').doc(_staffid).set(staffdata, SetOptions(merge: true));

                                                        await Future.delayed(const Duration(seconds: 1));
                                                        progress.dismiss();

                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                          content: Text(isEdit ? 'Data Updated Successfully' : 'Data Saved Successfully'),
                                                          backgroundColor: Colors.green,
                                                        ));
                                                        //await value.smsalert("Hello $nameTxt, you have been added successfully to  ${value.currentschool}, please visit  www.kologsoft.com/mis to login", phoneTxt);


                                                      }
                                                    },
                                                    icon: Icon(isEdit ? Icons.update : Icons.save),
                                                    label: Text(isEdit ? 'Update Staff' : 'Register Staff', style: TextStyle(fontSize: 12),),
                                                    style: _btnStyle(),
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: (){
                                                      context.go(Routes.staffview);
                                                    },
                                                    //=> context.go(Routes.viewstaff),
                                                    icon: const Icon(Icons.view_list),
                                                    label: const Text('View Staff', style: TextStyle(fontSize: 12),),
                                                    style: _btnStyle(),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              if (_showStaffContainer)

                                Container(
                                  width: 800,
                                  //height: 400,
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance.collection('staff').get(),
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

                                      final staffDocs = snapshot.data!.docs;


                                      if (isWideScreen){
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columnSpacing: 25,
                                            headingRowColor: WidgetStateProperty.all(Color(0xFF00496d)),
                                            border: TableBorder.all(color: Colors.grey.shade300),
                                            columns: const [
                                              DataColumn(label: Text('Staff Name', style: TextStyle(color: Colors.white),)),
                                              DataColumn(label: Text('Phone', style: TextStyle(color: Colors.white))),
                                              DataColumn(label: Text('Email', style: TextStyle(color: Colors.white))),
                                              DataColumn(label: Text('Sex', style: TextStyle(color: Colors.white))),
                                              DataColumn(label: Text('Region', style: TextStyle(color: Colors.white))),
                                              DataColumn(label: Text('Access Level', style: TextStyle(color: Colors.white))),
                                              DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
                                            ],
                                            rows: staffDocs.map((doc) {
                                              final data = doc.data() as Map<String, dynamic>;
                                              return DataRow(cells: [
                                                DataCell(Text(data['name'] ?? '')),
                                                DataCell(Text(data['phone'] ?? '')),
                                                DataCell(Text(data['email'] ?? '')),
                                                DataCell(Text(data['sex'] ?? '')),
                                                DataCell(Text(data['region'] ?? '')),
                                                DataCell(Text(data['accessLevel'] ?? '')),
                                                DataCell(
                                                    Row(
                                                      children: [
                                                        Icon(Icons.delete_forever, color: Colors.red, size: 20,),
                                                        SizedBox(width: 8),
                                                        Icon(Icons.edit, color: Colors.orangeAccent, size: 20,),
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
                                                      child: Text("Staff Lists", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: staffDocs.length,
                                                    itemBuilder: (context, index){
                                                      final data = staffDocs[index].data() as Map<String, dynamic>;

                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                              data['name'] ?? '',
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Phone: ${data['phone'] ?? ''}'),
                                                                Text('Email: ${data['email'] ?? ''}'),
                                                                Text('Sex: ${data['sex'] ?? ''}'),
                                                                Text('Region: ${data['region'] ?? ''}'),
                                                                Text('Access Level: ${data['accessLevel'] ?? ''}'),
                                                              ],
                                                            ),
                                                            trailing: const Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.edit, color: Colors.orangeAccent),
                                                                SizedBox(width: 8),
                                                                Icon(Icons.delete_forever, color: Colors.red),
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

                            ],
                          ),
                        );
                      }
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String? hint, Color fill) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00496d))),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      filled: false,
      fillColor: fill,
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF00496d),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      textStyle: const TextStyle(fontSize: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
    );
  }
}
