import 'package:flutter/material.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:provider/provider.dart';

import '../controller/routes.dart';

class SchoolList extends StatefulWidget {
  const SchoolList({Key? key}) : super(key: key);

  @override
  State<SchoolList> createState() => _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider value, Widget? child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                 // value.getSchools();
                },
              ),
            ],
            backgroundColor: Colors.teal.withOpacity(0.1),
            title:  Text(
              '',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child:Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal.shade50,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.start, // keep items at top
                    children: [
                      Container(
                        width: screenWidth<600 ? 400:screenWidth*0.45,
                        height: screenWidth < 600 ? 200 : 700,
                        decoration:  BoxDecoration(
                          color: Colors.teal.shade900,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Top: user info
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 50,
                                          child: Icon(Icons.person_sharp,size: 50,)
                                      ),
                                    ),
                                    Text(value.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white)),
                                    Padding(padding: const EdgeInsets.all(8.0), child: Text(value.phone, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            // Bottom: logout button
                          ],
                        ),
                      ),
                      Container(
                        height:  700,
                        width: screenWidth<600 ? 400:screenWidth*0.40,
                        decoration:  BoxDecoration(
                            color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),

                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 8,  right: 8),
                              child: Text("Select Your School",style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w900)),
                            ),
                            Divider(color: Colors.white),
                            SizedBox(
                              height: 600,
                              child: ListView.builder(
                                itemCount: value.staffSchoolIds.length,
                                padding: const EdgeInsets.all(10),
                                itemBuilder: (BuildContext context, int index) {
                                  String schoolidTxt=value.staffSchoolIds[index];
                                  String schoolnameTxt=value.schoolnames[index];
                                  return InkWell(
                                    onTap: () async {
                                      await value.setSchool(schoolnameTxt,schoolidTxt);
                                      print("${value.schoolid} selected");
                                      print("${value.currentschool} selected");
                                      Navigator.pop(context);
                                    },
                                      child: _schoolCard(schoolnameTxt)
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                ,
              ),
            ),
          ),
        );
      },
    );
  }
}


Widget _schoolCard(String name) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.school, color: Colors.blueAccent, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}


