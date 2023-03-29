// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tourist_spots/providers/tourist_spots.dart';

import '../providers/spot.dart';
import '../widgets/main_drawer.dart';

//This is the County Screen that displays all the tourist spots for a given county
class CountyScreen extends StatefulWidget {
  const CountyScreen({super.key, required this.name});
  final String name;

  @override
  State<CountyScreen> createState() => _CountyScreenState();
}

class _CountyScreenState extends State<CountyScreen> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _touristSpots;

  @override
  void initState() {
    super.initState();
    _touristSpots = Provider.of<TouristSpots>(context, listen: false).items;
  }

  @override
  Widget build(BuildContext context) {
    //IOS rendered section
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        child: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                backgroundColor: CupertinoColors.systemBackground,
                middle: const Text('Tourist Spots'),
                largeTitle: Text(widget.name),
                trailing: GestureDetector(
                  onTap: () {
                    context.go('/settings');
                  },
                  child: Icon(
                    color: CupertinoTheme.of(context).brightness ==
                            Brightness.light
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    CupertinoIcons.settings,
                    semanticLabel: 'Settings',
                  ),
                ),
              ),
              SliverFillRemaining(
                child: FutureBuilder(
                  future: _touristSpots,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('${snapshot.error} has occured'));
                      } else if (snapshot.hasData) {
                        //Preparation section for making spots list manipulation easier
                        List<Spot> spots = [];
                        for (var item in snapshot.data!.docs) {
                          Spot spt = Spot.fromJson(item.data());
                          spt.id = item.id;
                          spots.add(spt);
                          // print('The item is: ${spt.toJson()}');
                        }
                        spots = spots
                            .where((s) => s.county == widget.name)
                            .toList();
                        if (spots.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No Tourist Spots available in this county'));
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: spots.length,
                            itemBuilder: ((context, index) {
                              //Section for extracting the apropiate spot from the list
                              var spot = spots[index];
                              return GestureDetector(
                                onTap: () {
                                  context.go(
                                      '/${spot.county}/${spot.name}/${spot.id}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          child: Image.network(
                                            spot.descriptionImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 15,
                                        bottom: 10,
                                        child: Text(
                                          spot.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        }
                      }
                    }
                    return const CupertinoActivityIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      );
      //All the other platforms section (Android, Web)
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
                ))
          ],
        ),
        drawer: const MainDrawer(),
        body: SafeArea(
          child: FutureBuilder(
            future: _touristSpots,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error} has occured'));
                } else if (snapshot.hasData) {
                  //Preparation section for making spots list manipulation easier
                  List<Spot> spots = [];
                  for (var item in snapshot.data!.docs) {
                    Spot spt = Spot.fromJson(item.data());
                    spt.id = item.id;
                    spots.add(spt);
                    // print('The item is: ${spt.toJson()}');
                  }
                  spots = spots.where((s) => s.county == widget.name).toList();
                  if (spots.isEmpty) {
                    return const Center(
                        child:
                            Text('No Tourist Spots available in this county'));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: spots.length,
                      itemBuilder: ((context, index) {
                        //Section for extracting the apropiate spot from the list
                        var spot = spots[index];
                        return InkWell(
                          onTap: () {
                            context
                                .go('/${spot.county}/${spot.name}/${spot.id}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.network(
                                      spot.descriptionImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 15,
                                  bottom: 10,
                                  child: Text(
                                    spot.name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      );
    }
  }
}
