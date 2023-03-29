import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart'; //required by rootbundle
// import 'dart:convert'; //required if parsing ints if going for numeric type Ids

import 'spot.dart';

class TouristSpots extends ChangeNotifier {
  Future<QuerySnapshot<Map<String, dynamic>>> get items async {
    var getResults = await FirebaseFirestore.instance.collection('spots').get();
    // await Future.delayed(
    //   const Duration(seconds: 1),
    // ); //simulated delay cause my internet connection is way to fast :)
    return getResults;

    // This section was used with the dummy json data in first steps development
    // List<Spot> spots = [];
    // List spotsMap = await loadJson();
    // // ignore: avoid_function_literals_in_foreach_calls
    // spotsMap.forEach((value) {
    //   spots.add(Spot.fromJson(value));
    // });
    // return spots;
  }

  //This function was used with json dummy data in first steps development
  // Future<Spot> findById(String id) async {
  //   List<Spot> spots = await items;
  //   return spots.firstWhere((element) => element.id == id);
  // }

  Future<Spot?> findById(String id) async {
    var docRef =
        await FirebaseFirestore.instance.collection('spots').doc(id).get();
    if (docRef.exists) {
      Spot spot = Spot.fromJson(docRef.data()!);
      return spot;
    }
    return null;
  }

  // Tourist spot addition requires a 2 step process so direct update isn't applicable
  // Future<void> addToFireStore(Spot spot) async {
  //   var result =
  //       await FirebaseFirestore.instance.collection('spots').add(spot.toJson());
  //   notifyListeners();
  //   print('The spot was added');
  // }

  Future<String> addToFirestoreEmptyDoc() async {
    var result = await FirebaseFirestore.instance
        .collection('spots')
        .add({"name": "", "county": ""});
    notifyListeners();
    // print('The spot with id ${result.id} was added');
    return result.id;
  }

  Future<void> updateInFireStore(String id, Spot spot) async {
    await FirebaseFirestore.instance
        .collection('spots')
        .doc(id)
        .update(spot.toJson());
    notifyListeners();
    // print('The spot was updated');
  }

  Future<void> deleteFromFireStore(
      String docId, String county, String name) async {
    //This Section makes sure all the tourist spot images are deleted
    final storageRef = FirebaseStorage.instance.ref();
    final emptyBucketRef =
        storageRef.child('spots/$docId/$name/description_image');
    final emptyList = await emptyBucketRef.listAll();
    for (var item in emptyList.items) {
      await item.delete();
    }
    final emptyRoutesBucket =
        storageRef.child('spots/$docId/$name/routes_images');
    final emptyRoutesList = await emptyRoutesBucket.listAll();
    for (var item in emptyRoutesList.items) {
      await item.delete();
    }
    final emptyImagesBucket =
        storageRef.child('spots/$docId/$name/spot_images');
    final emptyImagesList = await emptyImagesBucket.listAll();
    for (var item in emptyImagesList.items) {
      await item.delete();
    }

    //This Section makes the text data deletion in Firestore
    await FirebaseFirestore.instance.collection('spots').doc(docId).delete();
    notifyListeners();
    // print('The spot was deleted');
  }

  //Usable while in development with tourist_spots.json dummy data
  // Future loadJson() async {
  //   final spotJson =
  //       await rootBundle.loadString('assets/sample_data/tourist_spots.json');
  //   final spotData = json.decode(spotJson) as Map<String, dynamic>;
  //   return spotData['spots'];
  // }
}
