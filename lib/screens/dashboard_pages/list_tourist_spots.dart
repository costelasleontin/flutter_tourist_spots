// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/tourist_spots.dart';
import '../../providers/spot.dart';

//This is a subpage of the Dashboard Screen
class ListTouristSpots extends StatefulWidget {
  const ListTouristSpots({super.key});

  @override
  State<ListTouristSpots> createState() => _ListTouristSpotsState();
}

class _ListTouristSpotsState extends State<ListTouristSpots> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _touristSpots;

  @override
  void initState() {
    super.initState();
    _touristSpots = Provider.of<TouristSpots>(context, listen: false).items;
  }

  Future<void> deleteSpot(String docId, String county, String name) async {
    try {
      await Provider.of<TouristSpots>(context, listen: false)
          .deleteFromFireStore(docId, county, name);
      setState(() {
        _touristSpots = Provider.of<TouristSpots>(context, listen: false).items;
      });
    } on Exception catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'The item deletion resulted in the following error: ${err.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _touristSpots,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error} has occured'),
            );
          } else if (snapshot.hasData) {
            return Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                if (Platform.isIOS)
                  CupertinoButton.filled(
                    onPressed: () {
                      context.go('/settings/dashboard/add');
                    },
                    child: const Text('Add New Tourist Spot'),
                  ),
                if (!Platform.isIOS)
                  ElevatedButton(
                    onPressed: () {
                      context.go('/settings/dashboard/add');
                    },
                    child: const Text('Add New Tourist Spot'),
                  ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Card(
                    elevation: 10,
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          'County',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Spot Name',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Edit',
                        ),
                        const SizedBox(width: 50),
                        const Text(
                          'Delete',
                        ),
                        const SizedBox(width: 25),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(3),
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) {
                      //Transforming snapshot data in a list of spots for ease of processing
                      List<Spot> spots = [];
                      List<String> docIds = [];
                      var spotsDocs = snapshot.data!.docs;
                      for (var item in spotsDocs) {
                        spots.add(Spot.fromJson(item.data()));
                        docIds.add(item.id);
                      }
                      return Card(
                        elevation: 10,
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            Text(
                              spots[index].county,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                spots[index].name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.go(
                                    '/settings/dashboard/edit/${docIds[index]}');
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text(
                                'Edit',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                deleteSpot(docIds[index], spots[index].county,
                                    spots[index].name);
                              },
                              icon: const Icon(Icons.delete_outlined),
                              label: const Text(
                                'Del',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
