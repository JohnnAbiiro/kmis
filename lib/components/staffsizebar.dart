import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/statsprovider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    final colors = Theme.of(context).colorScheme;
    return Consumer<Myprovider>(
      builder: (BuildContext context, value, Widget? child) {
        return Drawer(
          backgroundColor: colors.surface,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: colors.primaryContainer),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: colors.surface,
                        child: Image(
                          image: AssetImage('assets/images/logo.png'),
                          width: 80,
                          height: 80,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        schoolname,
                        style: TextStyle(
                          color: colors.onPrimaryContainer,
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
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: ExpansionTile(
                          collapsedIconColor: colors.onSurfaceVariant,
                          iconColor: colors.onSurfaceVariant,
                          leading: Icon(Icons.settings, color: colors.onSurfaceVariant, size: 17,),
                          title: Text(
                            'Configurations',
                            style: TextStyle(color: colors.onSurface, fontSize: 14),
                          ),
                          children: [
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Term',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.term),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'current term',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.currenterm),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Id format',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.idformat),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Academic year',
                                onTap: ()=>Navigator.pushNamed(context, Routes.academicyr),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Component',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.accesscomponent),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'mass promotion',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.masspromotion),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'promotion setting',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.promotionsetting),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Single promotion',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.singlepromotion),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Depart',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.depart),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Class',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.classes),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Grading system',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.gradingsystem),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'subject',
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.subjects),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.assignment,
                                title: 'Students ',
                                onTap: () => Navigator.pushNamed(context, Routes.registerstudent),
                              ),
                            ),



                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Remarks',
                                onTap: () => Navigator.pushNamed(context, Routes.remark),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(icon: Icons.access_alarm_outlined,
                                  title: "Total Attendance",
                                  onTap: () => Navigator.pushNamed(context, Routes.totalattend)),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.military_tech,
                                title: 'Attendance',
                                onTap: () => Navigator.pushNamed(context, Routes.attendance),
                              ),
                            ),


                          ],
                        ),
                      ),
                      _drawerTile(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () => Navigator.pushNamed(context, Routes.staffview),
                      ),

                      SizedBox(
                        child: _drawerTile(
                          icon: Icons.vpn_key,
                          title: 'Assess Components',
                          onTap: () =>Navigator.pushNamed(context, Routes.accesscomponent,
                          ),
                        ),
                      ),
                      SizedBox(
                        child: _drawerTile(
                            icon: Icons.vpn_key,
                            title: 'Contestants List',
                            onTap: () async{
                              Navigator.pushNamed(context, Routes.viewstudentlist);
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
                                    Navigator.pushNamed(context, Routes.setupteacher,
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
                                    Navigator.pushNamed(context, Routes.viewteachersetup,
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
                                    Navigator.pushNamed(context, Routes.studentsetup,
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
                                  Navigator.pushNamed(context, Routes.regstaff);
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
                                  Navigator.pushNamed(context, Routes.staffview);
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
                                  Navigator.pushNamed(context, Routes.coa);
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
                                  Navigator.pushNamed(context, Routes.accountActivity);
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
                                  Navigator.pushNamed(context, Routes.feesetup);
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            _drawerTile(icon: Icons.account_balance_wallet, title: 'Billing',
                              onTap: () async {
                                try {
                                  Navigator.pushNamed(context, Routes.billing);
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            _drawerTile(icon: Icons.account_balance_wallet, title: 'Single Billing',
                              onTap: () async {
                                try {
                                  Navigator.pushNamed(context, Routes.singlebilling);
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            _drawerTile(icon: Icons.account_balance_wallet, title: 'Payment Methods',
                              onTap: () async {
                                try {
                                  Navigator.pushNamed(context, Routes.paymentmethods);
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            _drawerTile(icon: Icons.account_balance_wallet, title: 'Fee Payment',
                              onTap: () async {
                                try {
                                  Navigator.pushNamed(context, Routes.feepayment);
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            _drawerTile(icon: Icons.account_balance_wallet, title: 'Expense',
                              onTap: () async {
                                try {
                                  Navigator.pushNamed(context, Routes.expense);
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                            _drawerTile(icon: Icons.account_balance_wallet, title: 'Supplier',
                              onTap: () async {
                                try {
                                  Navigator.pushNamed(context, Routes.supplier);
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
                                    Navigator.pushNamed(context, Routes.supplier);
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
                                    Navigator.pushNamed(context, Routes.itemcategory);
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
                                    Navigator.pushNamed(context, Routes.itemreg);
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
                                    Navigator.pushNamed(context, Routes.stock);
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
                                    Navigator.pushNamed(context, Routes.sales);
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
                                onTap: () =>Navigator.pushNamed(context, Routes.terminalreport,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.calendar_month,
                                title: 'Term total report',
                                onTap: () =>Navigator.pushNamed(context, Routes.termtotal,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.calendar_month,
                                title: 'Subject report',
                                onTap: () =>Navigator.pushNamed(context, Routes.subjectreport,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.calendar_month,
                                title: 'Student report',
                                onTap: () =>Navigator.pushNamed(context, Routes.individualreport,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: _drawerTile(
                                icon: Icons.calendar_month,
                                title: 'Transcript',
                                onTap: () =>Navigator.pushNamed(context, Routes.transcript,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(color: colors.outlineVariant, height: 30),
                      SizedBox(
                        child: _drawerTile(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () async {
                            await value.logout(context);
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
  return Builder(
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return ListTile(
        contentPadding: EdgeInsets.only(left: 24.0),
        leading: Icon(icon, color: colors.onSurfaceVariant, size: 17),
        title: Text(title, style: TextStyle(color: colors.onSurface, fontSize: 14)),
        onTap: onTap,
        hoverColor: colors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    },
  );
}
