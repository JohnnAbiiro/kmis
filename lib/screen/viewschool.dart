// import 'package:ksoftsms/controller/myprovider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_progress_hud/flutter_progress_hud.dart';
// import 'package:provider/provider.dart';
// import '../controller/routes.dart';
//
// class ViewSchoolPage extends StatefulWidget {
//   const ViewSchoolPage({super.key});
//
//   @override
//   State<ViewSchoolPage> createState() => _ViewSchoolPageState();
// }
//
// class _ViewSchoolPageState extends State<ViewSchoolPage> {
//   int? sortColumnIndex;
//   bool isAscending = true;
//   String searchQuery = "";
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final provider = Provider.of<Myprovider>(context, listen: false);
//       await provider.fetchschool();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.sizeOf(context).width;
//     double maxWidth = 900;
//     double colSpacing =
//     screenWidth > 800 ? 35 : screenWidth > 600 ? 25 : 10;
//
//     return ProgressHUD(
//       child: Consumer<Myprovider>(
//         builder: (context, provider, _) {
//           final schools = provider.schoollist;
//           final filteredSchools = schools.where((school) {
//             final query = searchQuery.toLowerCase();
//             return school.name.toLowerCase().contains(query) ;
//                 // (school.code ?? "").toLowerCase().contains(query) ||
//                 // (school.region ?? "").toLowerCase().contains(query);
//           }).toList();
//
//           return Scaffold(
//             backgroundColor: const Color(0xFF2D2F45),
//             appBar: AppBar(
//               backgroundColor: const Color(0xFF2D2F45),
//               iconTheme: const IconThemeData(color: Colors.white),
//               title: const Text(
//                 "Schools List",
//                 style: TextStyle(color: Colors.white),
//               ),
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             body: Align(
//               alignment: Alignment.topCenter,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     /// search bar
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: SizedBox(
//                         width: maxWidth,
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: "Search school, code, or region...",
//                             prefixIcon: const Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             fillColor: Colors.white,
//                             filled: true,
//                           ),
//                           onChanged: (value) =>
//                               setState(() => searchQuery = value),
//                         ),
//                       ),
//                     ),
//
//                     /// table
//                     Container(
//                       width: maxWidth,
//                       color: const Color(0xFF2D2F45),
//                       child: filteredSchools.isEmpty
//                           ? const Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Text(
//                           "No matching results",
//                           style: TextStyle(
//                               fontSize: 16, color: Colors.grey),
//                         ),
//                       )
//                           : SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: maxWidth),
//                           child: DataTable(
//                             columnSpacing: colSpacing,
//                             sortColumnIndex: sortColumnIndex,
//                             sortAscending: isAscending,
//                             headingRowColor:
//                             MaterialStateProperty.resolveWith(
//                                     (states) =>
//                                 const Color(0xFF2D2F45)),
//                             columns: [
//                               const DataColumn(
//                                 label: Text("#",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               DataColumn(
//                                 label: const Text("School",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                                 onSort: (index, ascending) {
//                                   setState(() {
//                                     sortColumnIndex = index;
//                                     isAscending = ascending;
//                                     filteredSchools.sort((a, b) =>
//                                     ascending
//                                         ? a.name.compareTo(b.name)
//                                         : b.name.compareTo(a.name));
//                                   });
//                                 },
//                               ),
//                               const DataColumn(
//                                 label: Text("Code",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               const DataColumn(
//                                 label: Text("Region",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               const DataColumn(
//                                 label: Text("Actions",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                             ],
//                             rows: filteredSchools
//                                 .asMap()
//                                 .entries
//                                 .map((entry) {
//                               final index = entry.key + 1;
//                               final school = entry.value;
//                               return DataRow(
//                                 cells: [
//                                   DataCell(Text("$index",
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.name,
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.name ?? "-",
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.phone ?? "-",
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Row(
//                                     children: [
//                                       /// edit button
//                                       IconButton(
//                                         icon: const Icon(Icons.edit,
//                                             color: Colors.amber),
//                                         onPressed: () {
//                                           Navigator.pushNamed(context, 
//                                             Routes.school,
//                                             arguments: {
//                                               "school": school,
//                                               "isEdit": true,
//                                             },
//                                           );
//                                         },
//                                       ),
//
//                                       /// delete button
//                                       IconButton(
//                                         icon: const Icon(Icons.delete,
//                                             color: Colors.red),
//                                         onPressed: () async {
//                                           final confirm =
//                                           await showDialog<bool>(
//                                             context: context,
//                                             builder: (ctx) =>
//                                                 AlertDialog(
//                                                   backgroundColor:
//                                                   const Color(0xFF2D2F45),
//                                                   title: const Text(
//                                                     "Delete School",
//                                                     style: TextStyle(
//                                                         color: Colors.white),
//                                                   ),
//                                                   content: const Text(
//                                                     "Are you sure you want to delete this school?",
//                                                     style: TextStyle(
//                                                         color:
//                                                         Colors.white70),
//                                                   ),
//                                                   actions: [
//                                                     TextButton(
//                                                       onPressed: () =>
//                                                           Navigator.pop(
//                                                               ctx, false),
//                                                       child: const Text(
//                                                         "Cancel",
//                                                         style: TextStyle(
//                                                             color: Colors
//                                                                 .white70),
//                                                       ),
//                                                     ),
//                                                     TextButton(
//                                                       onPressed: () =>
//                                                           Navigator.pop(
//                                                               ctx, true),
//                                                       child: const Text(
//                                                         "Delete",
//                                                         style: TextStyle(
//                                                             color: Colors
//                                                                 .redAccent),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                           );
//
//                                           if (confirm == true) {
//                                             try {
//                                               await provider.deleteData(
//                                                   "schools", school.id);
//                                               if (mounted) {
//                                                 ScaffoldMessenger.of(
//                                                     context)
//                                                     .showSnackBar(
//                                                   const SnackBar(
//                                                     content: Text(
//                                                         "School deleted successfully"),
//                                                     backgroundColor:
//                                                     Colors.green,
//                                                   ),
//                                                 );
//                                               }
//                                             } catch (e) {
//                                               if (mounted) {
//                                                 ScaffoldMessenger.of(
//                                                     context)
//                                                     .showSnackBar(
//                                                   SnackBar(
//                                                     content: Text(
//                                                         "Failed to delete school: $e"),
//                                                     backgroundColor:
//                                                     Colors.red,
//                                                   ),
//                                                 );
//                                               }
//                                             }
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   )),
//                                 ],
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:ksoftsms/controller/myprovider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_progress_hud/flutter_progress_hud.dart';
// import 'package:provider/provider.dart';
// import '../controller/routes.dart';
//
// class ViewSchoolPage extends StatefulWidget {
//   const ViewSchoolPage({super.key});
//
//   @override
//   State<ViewSchoolPage> createState() => _ViewSchoolPageState();
// }
//
// class _ViewSchoolPageState extends State<ViewSchoolPage> {
//   int? sortColumnIndex;
//   bool isAscending = true;
//   String searchQuery = "";
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final provider = Provider.of<Myprovider>(context, listen: false);
//       await provider.fetchschool();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.sizeOf(context).width;
//     double maxWidth = 1000;
//     double colSpacing = screenWidth > 800 ? 40 : screenWidth > 600 ? 25 : 12;
//
//     return ProgressHUD(
//       child: Consumer<Myprovider>(
//         builder: (context, provider, _) {
//           final schools = provider.schoollist;
//           final filteredSchools = schools.where((school) {
//             final query = searchQuery.toLowerCase();
//             return school.schoolname.toLowerCase().contains(query) ||
//                 school.prefix.toLowerCase().contains(query) ||
//                 school.countryName.toLowerCase().contains(query);
//           }).toList();
//
//           return Scaffold(
//             backgroundColor: const Color(0xFF2D2F45),
//             appBar: AppBar(
//               backgroundColor: const Color(0xFF2D2F45),
//               iconTheme: const IconThemeData(color: Colors.white),
//               title: const Text(
//                 "Schools List",
//                 style: TextStyle(color: Colors.white),
//               ),
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             body: Align(
//               alignment: Alignment.topCenter,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     /// 🔍 Search bar
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: SizedBox(
//                         width: maxWidth,
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: "Search school, prefix, or country...",
//                             prefixIcon: const Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             fillColor: Colors.white,
//                             filled: true,
//                           ),
//                           onChanged: (value) =>
//                               setState(() => searchQuery = value),
//                         ),
//                       ),
//                     ),
//
//                     /// 📋 Table of Schools
//                     Container(
//                       width: maxWidth,
//                       color: const Color(0xFF2D2F45),
//                       child: filteredSchools.isEmpty
//                           ? const Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Text(
//                           "No matching results",
//                           style: TextStyle(
//                               fontSize: 16, color: Colors.grey),
//                         ),
//                       )
//                           : SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: maxWidth),
//                           child: DataTable(
//                             columnSpacing: colSpacing,
//                             sortColumnIndex: sortColumnIndex,
//                             sortAscending: isAscending,
//                             headingRowColor:
//                             MaterialStateProperty.resolveWith(
//                                     (states) =>
//                                 const Color(0xFF2D2F45)),
//                             columns: [
//                               const DataColumn(
//                                 label: Text("#",
//                                     style: TextStyle(color: Colors.white)),
//                               ),
//                               DataColumn(
//                                 label: const Text("School Name",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                                 onSort: (index, ascending) {
//                                   setState(() {
//                                     sortColumnIndex = index;
//                                     isAscending = ascending;
//                                     filteredSchools.sort((a, b) =>
//                                     ascending
//                                         ? a.schoolname.compareTo(b.schoolname)
//                                         : b.schoolname.compareTo(a.schoolname));
//                                   });
//                                 },
//                               ),
//                               const DataColumn(
//                                 label: Text("Prefix",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               const DataColumn(
//                                 label: Text("Phone",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               const DataColumn(
//                                 label: Text("Country",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               const DataColumn(
//                                 label: Text("School ID",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                               const DataColumn(
//                                 label: Text("Actions",
//                                     style:
//                                     TextStyle(color: Colors.white)),
//                               ),
//                             ],
//                             rows: filteredSchools
//                                 .asMap()
//                                 .entries
//                                 .map((entry) {
//                               final index = entry.key + 1;
//                               final school = entry.value;
//                               return DataRow(
//                                 cells: [
//                                   DataCell(Text("$index",
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.schoolname,
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.prefix,
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.phone,
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.countryName,
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Text(school.schoolId,
//                                       style: const TextStyle(
//                                           color: Colors.white70))),
//                                   DataCell(Row(
//                                     children: [
//                                       /// ✏️ Edit button
//                                       IconButton(
//                                         icon: const Icon(Icons.edit,
//                                             color: Colors.amber),
//                                         onPressed: () {
//                                           Navigator.pushNamed(context, 
//                                             Routes.school,
//                                             arguments: {
//                                               "school": school,
//                                               "isEdit": true,
//                                             },
//                                           );
//                                         },
//                                       ),
//
//                                       /// 🗑️ Delete button
//                                       IconButton(
//                                         icon: const Icon(Icons.delete,
//                                             color: Colors.red),
//                                         onPressed: () async {
//                                           final confirm =
//                                           await showDialog<bool>(
//                                             context: context,
//                                             builder: (ctx) =>
//                                                 AlertDialog(
//                                                   backgroundColor:
//                                                   const Color(
//                                                       0xFF2D2F45),
//                                                   title: const Text(
//                                                     "Delete School",
//                                                     style: TextStyle(
//                                                         color:
//                                                         Colors.white),
//                                                   ),
//                                                   content: const Text(
//                                                     "Are you sure you want to delete this school?",
//                                                     style: TextStyle(
//                                                         color:
//                                                         Colors.white70),
//                                                   ),
//                                                   actions: [
//                                                     TextButton(
//                                                       onPressed: () =>
//                                                           Navigator.pop(
//                                                               ctx, false),
//                                                       child: const Text(
//                                                         "Cancel",
//                                                         style: TextStyle(
//                                                             color: Colors
//                                                                 .white70),
//                                                       ),
//                                                     ),
//                                                     TextButton(
//                                                       onPressed: () =>
//                                                           Navigator.pop(
//                                                               ctx, true),
//                                                       child: const Text(
//                                                         "Delete",
//                                                         style: TextStyle(
//                                                             color: Colors
//                                                                 .redAccent),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                           );
//
//                                           if (confirm == true) {
//                                             try {
//                                               await provider.deleteData(
//                                                   "school",
//                                                   school.id);
//                                               if (mounted) {
//                                                 ScaffoldMessenger.of(
//                                                     context)
//                                                     .showSnackBar(
//                                                   const SnackBar(
//                                                     content: Text(
//                                                         "School deleted successfully"),
//                                                     backgroundColor:
//                                                     Colors.green,
//                                                   ),
//                                                 );
//                                               }
//                                             } catch (e) {
//                                               if (mounted) {
//                                                 ScaffoldMessenger.of(
//                                                     context)
//                                                     .showSnackBar(
//                                                   SnackBar(
//                                                     content: Text(
//                                                         "Failed to delete school: $e"),
//                                                     backgroundColor:
//                                                     Colors.red,
//                                                   ),
//                                                 );
//                                               }
//                                             }
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   )),
//                                 ],
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
