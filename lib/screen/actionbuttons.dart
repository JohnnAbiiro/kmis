import 'package:flutter/material.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

List<Widget> actionButtons(Myprovider value, BuildContext context) {
  return [
    // value.isLoggedIn
    //     ? PopupMenuButton<String>(
    //   icon: const Icon(Icons.person_pin),
    //   onSelected: (String selected) async{
    //     if (selected == 'Logout') {
    //      // await value.logout(context);
    //     } else if (selected == 'viewScores') {
    //      Navigator.pushNamed(context, Routes.viewmarks);
    //     }else if (selected == 'finalize') {
    //       final bool? shouldProceed = await _showConfirmationDialog(context, value);
    //       if (shouldProceed == true) {
    //         print("${value.levelName}-${value.phone}-${value.episodeName}");
    //       } else {
    //         print('Action declined.');
    //       }
    //     }
    //   },
    //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
    //     PopupMenuItem<String>(
    //       value: 'Profile',
    //       child: ListTile(
    //         leading: Icon(Icons.person,),
    //         title: Text("${value.userName}"),
    //       ),
    //     ),
    //     PopupMenuItem<String>(
    //       value: 'viewScores',
    //        child: Tooltip(
    //         message: 'View the scores contestants.',
    //         child: ListTile(
    //           leading: Icon(Icons.add_chart_sharp,),
    //           title: Text('view scores'),
    //         ),
    //       ),
    //
    //     ),
    //     // PopupMenuItem<String>(
    //     //   value: 'finalize',
    //     //   child:Tooltip(
    //     //     message: 'Once you finalize, you will not be able to change scores anymore.',
    //     //     child: ListTile(
    //     //       leading: Icon(Icons.verified_user, color: Colors.green),
    //     //       title: Text('finalize scores'),
    //     //     ),  )
    //     //
    //     // ),
    //     PopupMenuItem<String>(
    //       value: 'Logout',
    //       child: ListTile(
    //         leading: Icon(Icons.logout,),
    //         title: Text('Logout'),
    //       ),
    //     ),
    //   ],
    // )
    //     : InkWell(
    //   onTap: () {
    //     Navigator.pushNamed(context, Routes.login);
    //   },
    //   child: Container(
    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    //     decoration: BoxDecoration(
    //       color: Colors.grey.shade300,
    //       borderRadius: BorderRadius.circular(20),
    //     ),
    //     child: Row(
    //       children: const [
    //         Icon(Icons.login, size: 20),
    //         SizedBox(width: 8),
    //         Text("Login"),
    //       ],
    //     ),
    //   ),
    // )

  ];
}
Future<bool?> _showConfirmationDialog(BuildContext context, provider) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Action',style: TextStyle(color: Colors.black),),
        content: const Text(
            'Are you sure you want to finalize scores? This cannot be undone.',style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            child: const Text('Decline'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Proceed'),
            onPressed: () async{
              //await provider.updatecompletedjudgescores();
              Navigator.of(context).pop(true);
              Navigator.pushNamed(context, Routes.judgelandingpage);
            },
          ),
        ],
      );
    },
  );
}
