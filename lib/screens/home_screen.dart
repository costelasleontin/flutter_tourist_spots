// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_drawer.dart';

//This is the Home Screen (initial screen)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //IOS HomeScreen Section rendering
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground,
          middle: const Text('Tourist spots in Cluj, Sălaj and Bihor'),
          trailing: GestureDetector(
            onTap: () {
              context.go('/settings');
            },
            child: Icon(
              color: CupertinoTheme.of(context).brightness == Brightness.light
                  ? CupertinoColors.black
                  : CupertinoColors.white,
              CupertinoIcons.settings,
              semanticLabel: 'Settings',
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Image.asset(
                'assets/images/cheile_turzii.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //the counties are hardcoded because it's a small list but if ever the app grows to acomodate much more
                  //counties or areas the value should be obtained from a dynamic list saved in a database
                  CupertinoButton.filled(
                    onPressed: () {
                      context.go('/Cluj');
                    },
                    child: const Text('Spots in Cluj County'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CupertinoButton.filled(
                    onPressed: () {
                      context.go('/Sălaj');
                    },
                    child: const Text('Spots in Sălaj County'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CupertinoButton.filled(
                    onPressed: () {
                      context.go('/Bihor');
                    },
                    child: const Text('Spots in Bihor County'),
                  ),
                  const SizedBox(
                    height:
                        100, //should change to about 15% of available screen estate not fixed value
                  )
                ],
              )),
            ],
          ),
        ),
      );
      //All the other platform rendering (Android, Web)
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tourist spots in Cluj, Sălaj and Bihor'),
          actions: [
            IconButton(
                onPressed: () {
                  context.go('/settings');
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  semanticLabel: 'Settings',
                ))
          ],
        ),
        drawer: const MainDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              Image.asset(
                'assets/images/cheile_turzii.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //the counties are hardcoded because it's a small list but if ever the app grows to acomodate much more
                  //counties or areas the value should be obtained from a dynamic list saved in a database
                  ElevatedButton(
                    onPressed: () {
                      context.go('/Cluj');
                    },
                    child: const Text('Spots in Cluj County'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/Sălaj');
                    },
                    child: const Text('Spots in Sălaj County'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/Bihor');
                    },
                    child: const Text('Spots in Bihor County'),
                  ),
                  const SizedBox(
                    height:
                        100, //should change to about 15% of available screen estate not fixed value
                  )
                ],
              )),
            ],
          ),
        ),
      );
    }
  }
}
