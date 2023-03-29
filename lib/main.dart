// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

import 'providers/tourist_spots.dart';
import 'routes/go_router_config.dart';
import 'theme/tourist_spots_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The flutter_downloader package doesn't work properly so either I fixe it or
  // find another package (till than opening images in browser is the solution)
  // await FlutterDownloader.initialize(
  //     debug:
  //         false, // optional: set to false to disable printing logs to console (default: true)
  //     ignoreSsl:
  //         false // option: set to false to disable working with http links (default: false)
  //     );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              TouristSpots(), //in a more complex app this would go down in the widget hierarchy for optimization purposes
        ),
        ChangeNotifierProvider(
          create: (context) => TouristSpotsTheme(),
        ),
      ],
      child: Consumer<TouristSpotsTheme>(builder: (context, value, child) {
        if (Platform.isIOS) {
          //Return a Cupertino app for IOS platform
          return CupertinoApp.router(
            title: 'Tourist Spots',
            theme: value.getMode
                ? TouristSpotsTheme.cupertinoTheme(Brightness.dark)
                : TouristSpotsTheme.cupertinoTheme(Brightness.light),
            routerConfig: router, //GoRouter object
          );
        } else {
          //Return a Material app for all the other platforms (Android, Web)
          return MaterialApp.router(
            title: 'Tourist Spots',
            theme: value.getMode
                ? TouristSpotsTheme.dark()
                : TouristSpotsTheme.light(),
            routerConfig: router, //GoRouter object
          );
        }
      }),
    );
  }
}
