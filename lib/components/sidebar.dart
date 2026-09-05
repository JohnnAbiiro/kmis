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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<Myprovider>(
      builder: (BuildContext context, value, Widget? child) {
        return Drawer(
          backgroundColor: colors.surface,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? colors.surfaceContainer : colors.primary.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        schoolname,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
                        child: Text(
                          "ACADEMICS",
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildExpansionTile(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Configurations',
                        children: [
                          _drawerTile(context, title: 'Setup Wizard', icon: Icons.auto_fix_high, onTap: () => context.go(Routes.setupWizard)),
                          _drawerTile(context, title: value.schoolType.toLowerCase() == 'tertiary' ? 'Semesters' : 'Terms', icon: Icons.calendar_today, onTap: () => context.go(Routes.currenterm)),
                          _drawerTile(context, title: 'ID Format', icon: Icons.badge_outlined, onTap: () => context.go(Routes.idformat)),
                          _drawerTile(context, title: 'Academic Year', icon: Icons.history_edu, onTap: () => context.go(Routes.academicyr)),
                          _drawerTile(context, title: 'Faculty', icon: Icons.account_balance_outlined, onTap: () => context.go(Routes.faculty)),
                          _drawerTile(context, title: value.schoolType.toLowerCase() == 'tertiary' ? 'Levels' : 'Classes', icon: Icons.class_outlined, onTap: () => context.go(Routes.classes)),
                          _drawerTile(context, title: 'Subjects', icon: Icons.book_outlined, onTap: () => context.go(Routes.subjects)),
                          _drawerTile(context, title: 'Grading System', icon: Icons.grading, onTap: () => context.go(Routes.gradingsystem)),
                        ],
                      ),
                      _drawerTile(context, icon: Icons.people_outline, title: 'View Students', onTap: () => context.go(Routes.viewstudentlist)),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 20, bottom: 8),
                        child: Text(
                          "MANAGEMENT",
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildExpansionTile(
                        context,
                        icon: Icons.person_search_outlined,
                        title: 'User Management',
                        children: [
                          _drawerTile(context, icon: Icons.person_add_alt, title: 'Add Staff', onTap: () => context.go(Routes.regstaff)),
                          _drawerTile(context, icon: Icons.view_list_outlined, title: 'View Staff', onTap: () => context.go(Routes.staffview)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 20, bottom: 8),
                        child: Text(
                          "Accounts Desk",
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildExpansionTile(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Accounts & Setup',
                        children: [
                          _drawerTile(context, icon: Icons.add_chart, title: 'Add Account', onTap: () => context.go(Routes.coa)),
                          _drawerTile(context, icon: Icons.settings_accessibility, title: 'System Activity', onTap: () => context.go(Routes.accountActivity)),
                          _drawerTile(context, icon: Icons.local_shipping_outlined, title: 'Suppliers', onTap: () => context.go(Routes.supplier)),
                          _drawerTile(context, icon: Icons.money_off_outlined, title: 'Expenses', onTap: () => context.go(Routes.expense)),

                        ],
                      ),


                      _buildExpansionTile(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Billing & Fee Setup',
                        children: [
                          _drawerTile(context, icon: Icons.payments_outlined, title: 'Fees Names', onTap: () => context.go(Routes.feesetup)),
                          _drawerTile(context, icon: Icons.receipt_long_outlined, title: 'Bulk Billing', onTap: () => context.go(Routes.billing)),
                          _drawerTile(context, icon: Icons.person_outline, title: 'Single Billing', onTap: () => context.go(Routes.singlebilling)),
                        ],
                      ),

                      _buildExpansionTile(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Fee  Payment',
                        children: [
                          _drawerTile(context, icon: Icons.payment_outlined, title: 'Fee Payment', onTap: () => context.go(Routes.feepayment)),
                          _drawerTile(context, icon: Icons.history_rounded, title: 'Payment History', onTap: () => context.go(Routes.feepaymentview)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 20, bottom: 8),
                        child: Text(
                          "REPORTS",
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildExpansionTile(
                        context,
                        icon: Icons.bar_chart_outlined,
                        title: 'Financial Reports',
                        children: [
                          _drawerTile(context, icon: Icons.summarize_outlined, title: 'Daily Collection', onTap: () => context.go(Routes.accountantSummaryView)),
                          _drawerTile(context, icon: Icons.summarize_outlined, title: 'Ledger Report', onTap: () => context.go(Routes.ledgerReport)),
                          _drawerTile(context, icon: Icons.calendar_view_day, title: 'Daily Ledger', onTap: () => context.go(Routes.dailyLedgerReport)),
                        ],
                      ),
                      _buildExpansionTile(
                        context,
                        icon: Icons.assignment_outlined,
                        title: 'Academic Reports',
                        children: [
                          _drawerTile(context, icon: Icons.description_outlined, title: 'Terminal Report', onTap: () => context.go(Routes.terminalreport)),
                          _drawerTile(context, icon: Icons.list_alt_outlined, title: 'Term Total Report', onTap: () => context.go(Routes.termtotal)),
                          _drawerTile(context, icon: Icons.subject_outlined, title: 'Subject Report', onTap: () => context.go(Routes.subjectreport)),
                          _drawerTile(context, icon: Icons.person_pin_outlined, title: 'Individual Report', onTap: () => context.go(Routes.individualreport)),
                          _drawerTile(context, icon: Icons.history_outlined, title: 'Transcript', onTap: () => context.go(Routes.transcript)),
                        ],
                      ),

                      const Divider(indent: 12, endIndent: 12, height: 32),
                      _drawerTile(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        onTap: () async => await value.logout(context),
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

  Widget _buildExpansionTile(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
    final colors = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: colors.onSurfaceVariant, size: 22),
        title: Text(title, style: TextStyle(color: colors.onSurface, fontSize: 14)),
        iconColor: colors.primary,
        collapsedIconColor: colors.onSurfaceVariant,
        children: children,
      ),
    );
  }

  Widget _drawerTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colors.onSurfaceVariant, size: 20),
      title: Text(title, style: TextStyle(color: colors.onSurface, fontSize: 14)),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}




