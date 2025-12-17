import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

import '../controller/myprovider.dart';

class StaffView extends StatefulWidget {
  const StaffView({super.key});

  @override
  State<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {

  void editStaffDialog(BuildContext context, staff) {
    final _formKey = GlobalKey<FormState>();

    final _nameController = TextEditingController(text: staff.name);
    final _phoneController = TextEditingController(text: staff.phone);
    final _emailController = TextEditingController(text: staff.email);
    final _regionController = TextEditingController(text: staff.region);
    final _accessLevelController = TextEditingController(text: staff.accessLevel);

    String _sex = staff.sex;
    String _teach = staff.teaching;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                blurRadius: 15,
                spreadRadius: 2,
                color: Colors.black26,
              )
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF00496d)
                    ),
                    child: const Center(
                      child: Text(
                        "Edit Staff Details",
                        style: TextStyle(
                          color: Colors.white,
                          //fontSize: 14,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  customField(
                    controller: _nameController,
                    label: "Full Name",
                    //icon: Icons.person,
                    validator: (v) => v!.isEmpty ? "Name required" : null,
                  ),

                  const SizedBox(height: 12),


                  customField(
                    controller: _phoneController,
                    label: "Phone Number",
                    //icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Phone required" : null,
                  ),

                  const SizedBox(height: 12),

                  customField(
                    controller: _emailController,
                    label: "Email",
                    //icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField(
                    value: _sex,
                    decoration: inputStyle("Sex",
                        //Icons.wc
                    ),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (value) {
                      _sex = value!;
                    },
                  ),
                  const SizedBox( height: 12),
                  DropdownButtonFormField(
                    value: _teach,
                      decoration: inputStyle("Staff Type"),
                      items: const [
                        DropdownMenuItem(value: "Teaching Staff", child: Text("Teaching Staff")),
                        DropdownMenuItem(value: "Non Teaching Staff", child: Text("Non Teaching Staff"))
                      ],
                    onChanged: (value) {
                      _teach = value!;
                    },
                  ),
                  const SizedBox(height: 12),

                  customField(
                    controller: _regionController,
                    label: "Region",
                    //icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 12),

                  customField(
                    controller: _accessLevelController,
                    label: "Access Level",
                    //icon: Icons.admin_panel_settings_outlined,
                  ),

                  const SizedBox(height: 25),

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
                          child: const Text("Cancel", style: TextStyle(color: Color(0xFF00496d)),),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: const Color(0xFF00496d),
                          ),
                          child: const Text("Update Staff", style: TextStyle(color: Colors.white),),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            await FirebaseFirestore.instance
                                .collection('staff')
                                .doc(staff.id)
                                .update({
                              'name': _nameController.text,
                              'phone': _phoneController.text,
                              'email': _emailController.text,
                              'sex': _sex,
                              'teaching': _teach,
                              'region': _regionController.text,
                              'accessLevel': _accessLevelController.text,
                            });

                            context.read<Myprovider>().fetchStaff();
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().fetchStaff();

    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
          builder: (context){
            return Consumer<Myprovider>(
                builder: (context, value, child){
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Staff View"),
                    ),
                    body: SingleChildScrollView(
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            bool isWideScreen = constraints.maxWidth > 500;
                            return Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 800,
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFF00496d).withOpacity(0.2),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // handle search logic here
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  Container(
                                    //width: 800,
                                    //height: 400,
                                    padding: const EdgeInsets.all(12),
                                    color: Colors.white,
                                    child: FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance.collection('staff').get(),
                                      builder: (context, snapshot) {
                                        // if (snapshot.connectionState == ConnectionState.waiting) {
                                        //   return const Center(child: CircularProgressIndicator());
                                        // }

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

                                        //final staffDocs = snapshot.data!.docs;


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
                                                DataColumn(label: Text('Staff Type', style: TextStyle(color: Colors.white))),
                                                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
                                              ],
                                              rows: value.stafflist.asMap().entries.map((entry) {

                                                final index = entry.key;
                                                final doc = entry.value;
                                                //print(index);

                                                return DataRow(
                                                  cells: [
                                                    DataCell(Text(doc.name)),
                                                    DataCell(Text(doc.phone)),
                                                    DataCell(Text(doc.email)),
                                                    DataCell(Text(doc.sex)),
                                                    DataCell(Text(doc.region)),
                                                    DataCell(Text(doc.accessLevel)),
                                                    DataCell(Text(doc.teaching)),

                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          InkWell(
                                                            child: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                                            onTap: () {
                                                              value.deleteStaff(doc.id.toString(), index, context, 'staff');
                                                            },
                                                          ),
                                                          const SizedBox(width: 8),
                                                          InkWell(
                                                            child: const Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                                                            onTap: () {
                                                              editStaffDialog(context, doc);
                                                              //editStaffDialog(context, doc.id, ???)
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
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
                                                      itemCount: value.stafflist.length,
                                                      itemBuilder: (context, index){

                                                        final doc = value.stafflist;
                                                        final data = value.stafflist[index];

                                                        return Column(
                                                          children: [
                                                            ListTile(
                                                              title: Text('Name: ${data.name?? ''}'),
                                                              subtitle: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text('Phone: ${data.phone ?? ''}'),
                                                                  Text('Email: ${data.email?? ''}'),
                                                                  Text('Sex: ${data.sex ?? ''}'),
                                                                  Text('Region: ${data.region?? ''}'),
                                                                  Text('Access Level: ${data.accessLevel?? ''}'),
                                                                  Text('Staff Type: ${data.teaching?? ''}'),
                                                                ],
                                                              ),
                                                              trailing: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  InkWell(
                                                                      child: Icon(Icons.edit, color: Colors.orangeAccent),
                                                                    onTap: (){
                                                                      editStaffDialog(context, doc);
                                                                    },
                                                                  ),
                                                                  SizedBox(width: 8),
                                                                  InkWell(
                                                                      child: Icon(Icons.delete_forever, color: Colors.red),
                                                                    onTap: ()async{
                                                                        await value.deleteStaff(data.id.toString(),index,context, 'staff');
                                                                        //data.re(index);
                                                                    },
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
                                ],
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
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
