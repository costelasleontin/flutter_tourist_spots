// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart' show rootBundle; // necessary if using json dummy data
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tourist_spots/providers/tourist_spots.dart';
import 'package:tourist_spots/screens/spot_pages/pictures_screen.dart';
import 'package:tourist_spots/screens/spot_pages/routes_screen.dart';
import '../providers/spot.dart';
import '../widgets/main_drawer.dart';
import 'spot_pages/description_screen.dart';

//This is the Tourist Spot Screen that displays one of the 3 subscreens (Description, Routes, Pictures)
// that display diferent information about the picked tourist spot
class TouristSpotsScreen extends StatefulWidget {
  final String name;
  final String id;

  const TouristSpotsScreen({super.key, required this.name, required this.id});

  @override
  State<TouristSpotsScreen> createState() => _TouristSpotsScreenState();
}

class _TouristSpotsScreenState extends State<TouristSpotsScreen> {
  late Future<Spot?> _spot;
  int _selectedIndex = 0;

  void selectIndex(newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    try {
      _spot =
          Provider.of<TouristSpots>(context, listen: false).findById(widget.id);
    } on Exception catch (err) {
      displaySnackbar(
          'While fetching tourist spot the following error occured: ${err.toString()}');
      // print(
      //     'While fetching tourist spot the following error occured: ${err.toString()}');
    }
  }

  void displaySnackbar(String message, {int duration = 2}) {
    //To do: implement error message for IOS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: duration)),
    );
  }

  @override
  Widget build(BuildContext context) {
    //IOS rendering section
    if (Platform.isIOS) {
      List<Widget> iosTabWidgets = const [
        DescriptionScreen(),
        RoutesScreen(),
        PicturesScreen(),
      ];
      return FutureBuilder(
        future: _spot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {}
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error} has occured'));
          } else if (snapshot.hasData) {
            // print('The fetched spot snapshot is:${snapshot.data}');

            //If returned Spot? is null it means the spot wasn't found
            if (snapshot.data == null) {
              return const Center(
                child: Text('The spots wasn\'t found. Please try again later.'),
              );
            } else {
              return ChangeNotifierProvider.value(
                value: snapshot.data as Spot,
                child: CupertinoTabScaffold(
                  tabBar: CupertinoTabBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.info_circle_fill),
                        label: 'Description',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.arrow_uturn_left_circle_fill),
                        label: 'Routes',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.camera_circle_fill),
                        label: 'Pictures',
                      ),
                    ],
                  ),
                  tabBuilder: (context, index) {
                    // print('The tab index is:$index');
                    return CupertinoTabView(
                      builder: (context) {
                        return CupertinoPageScaffold(
                          child: SafeArea(
                            child: CustomScrollView(
                              slivers: <Widget>[
                                CupertinoSliverNavigationBar(
                                  backgroundColor:
                                      CupertinoColors.systemBackground,
                                  leading: GestureDetector(
                                    onTap: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      }
                                    },
                                    child: Icon(
                                      color: CupertinoTheme.of(context)
                                                  .brightness ==
                                              Brightness.light
                                          ? CupertinoColors.black
                                          : CupertinoColors.white,
                                      CupertinoIcons.back,
                                      semanticLabel: 'Settings',
                                    ),
                                  ),
                                  middle: const Text('Tourist Spot'),
                                  largeTitle: Text(widget.name),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      context.go('/settings');
                                    },
                                    child: Icon(
                                      color: CupertinoTheme.of(context)
                                                  .brightness ==
                                              Brightness.light
                                          ? CupertinoColors.black
                                          : CupertinoColors.white,
                                      CupertinoIcons.settings,
                                      semanticLabel: 'Settings',
                                    ),
                                  ),
                                ),
                                SliverFillRemaining(
                                  child: ChangeNotifierProvider.value(
                                    value: snapshot.data as Spot,
                                    child: iosTabWidgets[index],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
          }
          return const CupertinoActivityIndicator();
        },
      );
      //The other platforms section (Android, Web)
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          actions: [
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
          //using a FutureBuilder here in order to load all the data here for the 3 subscreens used
          //because the data isn't large and the data wont require to be fragmented in the
          //database based on subscreens
          child: FutureBuilder(
            future: _spot,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {}
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error} has occured'));
              } else if (snapshot.hasData) {
                // print('The fetched spot snapshot is:${snapshot.data}');

                //If returned Spot? is null it means the spot wasn't found
                if (snapshot.data == null) {
                  return const Center(
                    child: Text(
                        'The spots wasn\'t found. Please try again later.'),
                  );
                } else {
                  return ChangeNotifierProvider.value(
                    value: snapshot.data as Spot,
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: const [
                        DescriptionScreen(),
                        RoutesScreen(),
                        PicturesScreen(),
                      ],
                    ),
                  );
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.description_outlined,
                  semanticLabel: 'Description',
                ),
                label: 'Description'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.route_outlined,
                  semanticLabel: 'Routes',
                ),
                label: 'Routes'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.image_outlined,
                  semanticLabel: 'Pictures',
                ),
                label: 'Pictures'),
          ],
          currentIndex: _selectedIndex,
          onTap: (value) {
            selectIndex(value);
          },
        ),
      );
    }
  }
}
