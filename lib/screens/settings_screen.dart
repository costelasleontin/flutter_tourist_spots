// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tourist_spots/theme/tourist_spots_theme.dart';

import '../widgets/main_drawer.dart';
import '../widgets/login_form.dart';

//This is the Settings Screen that enables login and changing theme
//or in the future other options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    //IOS Section rendering
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
          child: Column(
            children: [
              Consumer<TouristSpotsTheme>(
                builder: (context, value, child) => Card(
                  shadowColor:
                      CupertinoTheme.of(context).brightness == Brightness.light
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                  color:
                      CupertinoTheme.of(context).brightness == Brightness.light
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                  elevation: 5,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              color: CupertinoTheme.of(context).brightness ==
                                      Brightness.light
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          CupertinoSwitch(
                            activeColor: CupertinoColors.activeBlue,
                            value: value.getMode,
                            onChanged: (switchValue) {
                              value.toggleTheme(switchValue);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shadowColor:
                    CupertinoTheme.of(context).brightness == Brightness.light
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                color: CupertinoTheme.of(context).brightness == Brightness.light
                    ? CupertinoColors.white
                    : CupertinoColors.black,
                elevation: 5,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LoginForm(),
                ),
              ),
            ],
          ),
        ),
      );
      //Other platforms section rendering (Android, Web)
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
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
          child: Column(
            children: [
              Consumer<TouristSpotsTheme>(
                builder: (context, value, child) => Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('Dark Mode'),
                          Expanded(
                            child: Container(),
                          ),
                          Switch(
                            value: value.getMode,
                            onChanged: (switchValue) {
                              value.toggleTheme(switchValue);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LoginForm(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
