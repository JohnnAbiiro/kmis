import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/statsprovider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controller/routes.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String schoolname = '';

  void initState()  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Myprovider>().getdata();
      //print(context.read<Myprovider>().currentschool);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider= context.read<Myprovider>();
      provider.getdata();
      setState(() {
        schoolname=provider.currentschool;
      });
      //print(provider.phone);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, value, Widget? child) {
        return Drawer(
          backgroundColor: Color(0xFF00273a),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Color(0xFF00273a)),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: Image(
                          image: AssetImage('assets/images/bookwormlogo.jpg'),
                          width: 80,
                          height: 80,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        schoolname,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
               Flexible(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 10, bottom: 4),
                          child: Text(
                            "STUDENTS REGISTRATION",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.white,
                            leading: Icon(Icons.settings, color: Colors.white60, size: 17,),
                            title: Text(
                              'Configurations',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            children: [
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'SCHOOL LIST',
                                  onTap: () =>
                                      context.go(Routes.nextpage),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Term',
                                  onTap: () =>
                                      context.go(Routes.term),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Id format',
                                  onTap: () =>
                                      context.go(Routes.idformat),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Academic year',
                                  onTap: ()=>context.go(Routes.academicyr),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Component',
                                  onTap: () =>
                                      context.go(Routes.accesscomponent),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Depart',
                                  onTap: () =>
                                      context.go(Routes.depart),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Class',
                                  onTap: () =>
                                      context.go(Routes.classes),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Grading system',
                                  onTap: () =>
                                      context.go(Routes.gradingsystem),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'subject',
                                  onTap: () =>
                                      context.go(Routes.subjects),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.assignment,
                                  title: 'Students ',
                                  onTap: () => context.go(Routes.registerstudent,),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'Region Registration',
                                  onTap: () => context.go(Routes.regionreg),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'school',
                                  onTap: () => context.go(Routes.school),
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.military_tech,
                                  title: 'score config',
                                  onTap: () => context.go(Routes.scoreconfig),
                                ),
                              ),
                              _drawerTile(
                                icon: Icons.cleaning_services_rounded,
                                title: 'Clear Results',
                                onTap: () => context.go(Routes.clearscores,),
                              ),
                              _drawerTile(
                                icon: Icons.cleaning_services_rounded,
                                title: 'Eviction',
                                onTap: () =>context.go(Routes.marks,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: _drawerTile(
                            icon: Icons.vpn_key,
                            title: 'Assess Components',
                            onTap: () =>context.go(Routes.accesscomponent,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: _drawerTile(
                            icon: Icons.vpn_key,
                            title: 'Contestants List',
                            onTap: () async{
                              context.go(Routes.viewstudentlist);
                            }
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 4),
                          child: Text(
                            "Teacher Setup",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.white,
                            leading: Icon(Icons.people, color: Colors.white60, size: 17,),
                            title: Text(
                              'Assessment Data',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            children: [
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.person_add,
                                  title: 'Teacher set up',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.setupteacher,
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.person_add,
                                  title: 'View Teachers',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.viewstaff,
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.person_add,
                                  title: 'Student set up',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.contestantsetup,
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 4),
                          child: Text(
                            "User Management",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.white,
                            leading: Icon(Icons.people, color: Colors.white60, size: 17,),
                            title: Text(
                              'User Management',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            children: [
                              _drawerTile(
                                icon: Icons.person_add,
                                title: 'Add Staff',
                                onTap: () async {
                                  try {
                                    context.go(Routes.regstaff);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(
                                icon: Icons.view_list,
                                title: 'View Staff',
                                onTap: () async {
                                  try {
                                    context.go(Routes.viewstaff);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 4),
                          child: Text(
                            "Financial Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        //==============
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.white,
                            leading: Icon(Icons.people, color: Colors.white60, size: 17,),
                            title: Text(
                              'Accounts Setup',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            children: [
                              _drawerTile(
                                icon: Icons.person_add,
                                title: 'Add Account',
                                onTap: () async {
                                  try {
                                    context.go(Routes.coa);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),

                              _drawerTile(
                                icon: Icons.view_list,
                                title: 'System Activity',
                                onTap: () async {
                                  try {
                                    context.go(Routes.accountActivity);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(
                                icon: Icons.account_balance_wallet,
                                title: 'Fees Names',
                                onTap: () async {
                                  try {
                                    context.go(Routes.feesetup);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(icon: Icons.account_balance_wallet, title: 'Billing',
                                onTap: () async {
                                  try {
                                    context.go(Routes.billing);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(icon: Icons.account_balance_wallet, title: 'Single Billing',
                                onTap: () async {
                                  try {
                                    context.go(Routes.singlebilling);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(icon: Icons.account_balance_wallet, title: 'Payment Methods',
                                onTap: () async {
                                  try {
                                    context.go(Routes.paymentmethods);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(icon: Icons.account_balance_wallet, title: 'Fee Payment',
                                onTap: () async {
                                  try {
                                    context.go(Routes.feepayment);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(icon: Icons.account_balance_wallet, title: 'Expense',
                                onTap: () async {
                                  try {
                                    context.go(Routes.expense);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                              _drawerTile(icon: Icons.account_balance_wallet, title: 'Supplier',
                                onTap: () async {
                                  try {
                                    context.go(Routes.supplier);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 4),
                          child: Text(
                            "Item Management",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.white,
                            leading: Icon(Icons.description_outlined, color: Colors.white60, size: 17,),
                            title: Text(
                              'Items Management',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            children: [

                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.grid_view_sharp,
                                  title: 'Add Suppliers',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.supplier);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.grid_view_sharp,
                                  title: 'Add Categories',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.itemcategory);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.grid_view_sharp,
                                  title: 'Item Registration',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.itemreg);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.grid_view_sharp,
                                  title: 'Stock',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.stock);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.grid_view_sharp,
                                  title: 'Sales',
                                  onTap: () async {
                                    try {
                                      context.go(Routes.sales);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ),




                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 4),
                          child: Text(
                            "Reports",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.white,
                            leading: Icon(
                              Icons.insert_chart,
                              color: Colors.white60,
                              size: 17,
                            ),
                            title: Text(
                              'Reports',
                              style: TextStyle(color: Colors.white54),
                            ),
                            children: [
                              SizedBox(
                                child: _drawerTile(
                                  icon: Icons.calendar_month,
                                  title: 'Terminal report',
                                  onTap: () =>context.go(Routes.terminalreport,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white24, height: 30),
                        SizedBox(
                          child: _drawerTile(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () async {
                            /// await value.logout(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _drawerTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: EdgeInsets.only(left: 24.0),
    leading: Icon(icon, color: Colors.white60, size: 17),
    title: Text(title, style: TextStyle(color: Colors.white54, fontSize: 14)),
    onTap: onTap,
    hoverColor: Colors.white10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
