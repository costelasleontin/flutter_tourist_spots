// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_drawer.dart';
import 'dashboard_pages/add_edit_spot.dart';
import 'dashboard_pages/list_tourist_spots.dart';

enum DashboardSubpages { list, add, edit }

//To do: implement dark theme styling for cupertino app
//This is the Dashboard Screen that enables create, read, update, delete operations
class DashboardScreen extends StatefulWidget {
  const DashboardScreen(
      {super.key, this.subpagetype = DashboardSubpages.list, this.spotId = ''});
  final DashboardSubpages subpagetype;
  final String spotId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //FirebaseAuth user logout function
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    goToSettings();
  }

  void goToSettings() {
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dashboardSubpages = [
      const ListTouristSpots(),
      const AddEditSpot(),
      AddEditSpot(
        edit: true,
        id: widget.spotId,
      )
    ];
    //IOS rendering section
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground,
          middle: const Text('Tourist spots in Cluj, Sălaj and Bihor'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: signOut,
                child: Icon(
                  color:
                      CupertinoTheme.of(context).brightness == Brightness.light
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                  CupertinoIcons.arrow_left_square,
                  semanticLabel: 'Logout',
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go('/settings');
                },
                child: Icon(
                  color:
                      CupertinoTheme.of(context).brightness == Brightness.light
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                  CupertinoIcons.settings,
                  semanticLabel: 'Settings',
                ),
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: dashboardSubpages[widget.subpagetype.index],
        ),
      );
      //Other platforms rendering section (Android, Web)
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              onPressed: signOut,
              icon: const Icon(
                Icons.logout_outlined,
                semanticLabel: 'Logout',
              ),
            ),
            IconButton(
              onPressed: () {
                context.go('/settings');
              },
              icon: const Icon(
                Icons.settings_outlined,
                semanticLabel: 'Settings',
              ),
            )
          ],
        ),
        drawer: const MainDrawer(),
        body: SafeArea(
          child: dashboardSubpages[widget.subpagetype.index],
        ),
      );
    }
  }
}
