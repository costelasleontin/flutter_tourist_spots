// import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tourist_spots/providers/tourist_spots.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tourist_spots/widgets/cupertino_data_upload_form.dart';
import 'package:tourist_spots/widgets/cupertino_img_upload_form.dart';
import 'package:tourist_spots/widgets/material_data_upload_form.dart';
import 'package:tourist_spots/widgets/material_img_upload_form.dart';

import '../../providers/spot.dart';

//This is subpage of the Dashboard Screen
class AddEditSpot extends StatefulWidget {
  const AddEditSpot({super.key, this.edit = false, this.id = ''});
  final bool edit;
  final String id;

  @override
  State<AddEditSpot> createState() => _AddEditSpotState();
}

//To do: The widget will need another round of refactoring in smaller widgets with a
//target number of lines of code of smaller than 250 line
class _AddEditSpotState extends State<AddEditSpot> {
  final _formKey = GlobalKey<FormState>();
  String? id;
  String name = '';
  String description = '';
  String county = 'Cluj'; //default value set as Cluj
  String routesInfo = '';
  String androidMapLink = '';
  String iosMapLink = '';
  String descriptionImage = '';
  List<String> routes = [];
  List<String> images = [];
  bool isReadyToUploadImages = false;
  bool isEditingSpot = false;
  bool isInitialEditLoading = true;
  Spot?
      oldSpot; //This will be used for making a comparisson in order to delete the old images
  late TouristSpots _touristSpots;
  late Spot? spotEdit;

  @override
  void initState() {
    super.initState();
    _touristSpots = Provider.of<TouristSpots>(context, listen: false);
  }

  //The form requires to be split in 2 parts one for uploading text data and one for uploading images
  //So we have here a partial submit function to check text data validity and move to image upload section
  Future<void> partialSubmitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        //Check first if we are not editing
        //If we are editing we want to enable overwritting spots
        //To do: Implement mechanism to warn or disable overwritting spots
        if (!isEditingSpot) {
          bool isNameAlreadySavedInDatabase = false;
          var result =
              await FirebaseFirestore.instance.collection('spots').get();
          for (var item in result.docs) {
            Spot spt = Spot.fromJson(item.data());
            if (spt.name == name && spt.county == county) {
              isNameAlreadySavedInDatabase = true;
            }
          }
          if (isNameAlreadySavedInDatabase) {
            if (!Platform.isIOS) {
              displaySnackbar(
                  'The name of the tourist spot already exists. Please create a new name or edit the already existing spot');
            }

            return;
          }
        }
      } on Exception catch (err) {
        if (!Platform.isIOS) {
          displaySnackbar(
              'While checking if the spot already exists the following error occured: ${err.toString()}');
        }
      }

      try {
        if (!isEditingSpot) {
          id = await _touristSpots.addToFirestoreEmptyDoc();
        }
      } on Exception catch (err) {
        if (!Platform.isIOS) {
          displaySnackbar(
              'While adding new empty documnet in database the following error occured: ${err.toString()}');
        }
      }
      if (!Platform.isIOS) {
        displaySnackbar('You can start uploading images');
      }
      setState(() {
        isReadyToUploadImages = true;
      });
    } else {
      setState(() {
        isReadyToUploadImages = false;
      });
    }
  }

//This is the final submit function which saves text data and makes sure only the picked images
//remain in the Firebase Storage
  Future<void> submitForm() async {
    //Make sure we at least have a description image
    if (descriptionImage.isEmpty) {
      displaySnackbar(
          'The operation failed. Please select a description image');
      return;
    }

    Spot spot = Spot(
      id: id,
      name: name,
      county: county,
      description: description,
      descriptionImage: descriptionImage,
      routes: routes,
      routesInfo: routesInfo,
      images: images,
      androidMapLink: androidMapLink,
      iosMapLink: iosMapLink,
    );
    try {
      //This uploads text data to Firestore if id exists
      //If id doesn't exists it will throw error
      await _touristSpots.updateInFireStore(id!, spot);

      //This section makes sure that only the final route images and spot images
      //remaine in Firebase Storage
      //Alternativelly I could implement a mecanism to save all files that are to be written
      //in database and upload all of them at the final step but it will make the
      //final step to take much longer even though it would be more bandwith efficient
      //Also the current mechanism enables you to preview the images from Firebasestorage and
      //you can make sure while you upload one image at a time that it will be displayed
      //corectly (it would suck big time to upload 12+ images to discover that one doesn't displays correctly)
      final storageRef = FirebaseStorage.instance.ref();

      //remove extra description images
      final emptyDescriptionBucket =
          storageRef.child('spots/$id/$name/description_image');
      final emptyDescriptionList = await emptyDescriptionBucket.listAll();
      for (var item in emptyDescriptionList.items) {
        final itemUrl = await item.getDownloadURL();
        if (!(descriptionImage == itemUrl)) {
          await item.delete();
        }
      }

      //remove extra routes images
      final emptyRoutesBucket =
          storageRef.child('spots/$id/$name/routes_images');
      final emptyRoutesList = await emptyRoutesBucket.listAll();
      for (var item in emptyRoutesList.items) {
        final itemUrl = await item.getDownloadURL();
        if (!routes.contains(itemUrl)) {
          await item.delete();
        }
      }

      //remove extra spot images
      final emptyImagesBucket = storageRef.child('spots/$id/$name/spot_images');
      final emptyImagesList = await emptyImagesBucket.listAll();
      for (var item in emptyImagesList.items) {
        final itemUrl = await item.getDownloadURL();
        if (!images.contains(itemUrl)) {
          await item.delete();
        }
      }
      goBackToDashboard();
    } on Exception catch (err) {
      //We go for the simple catch all not that secure pattern. In the future to do: more specialised exception handling
      displaySnackbar(err.toString());
      // print(
      //     'Spot adding operation resulted in the following error: ${err.toString()}');
    }
  }

  //The following 3 functions upload images to Firebasestorage and because the work with
  //database they could be put in the TouristSpots provider class or at least the parts
  //that upload to database for separation of concerns
  //To do: Refactoring of the uploading images mechanisms
  //To do: Implement progress indicator for loading images
  Future<void> storeImageInFirebaseStore() async {
    try {
      final imageFile = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 960, imageQuality: 100);
      final imageFilePath = File(imageFile!.path);
      final storageRef = FirebaseStorage.instance.ref();
      final imageFileName = getRandString(12);
      //The description image saving operation
      final descriptionImageRef = storageRef
          .child('spots/$id/$name/description_image/$imageFileName.jpg');
      if (kIsWeb) {
        await descriptionImageRef.putData(await imageFile.readAsBytes());
      } else {
        await descriptionImageRef.putFile(imageFilePath);
      }
      final storeUrl = await descriptionImageRef.getDownloadURL();
      setState(() {
        descriptionImage = storeUrl;
      });
    } catch (err) {
      //to do: Implement more specialized error handling
      displaySnackbar(
          'The following error ocurred while storing image in database:${err.toString()}');
    }
  }

  Future<void> storeRoutesImagesInFirebaseStore() async {
    try {
      final imageFile = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 960, imageQuality: 100);
      final imageFilePath = File(imageFile!.path);
      final storageRef = FirebaseStorage.instance.ref();
      final imageFileName = getRandString(12);

      //actuall saving operation
      final descriptionImageRef =
          storageRef.child('spots/$id/$name/routes_images/$imageFileName.jpg');
      if (kIsWeb) {
        await descriptionImageRef.putData(await imageFile.readAsBytes());
      } else {
        await descriptionImageRef.putFile(imageFilePath);
      }
      final storeUrl = await descriptionImageRef.getDownloadURL();
      setState(() {
        routes.add(storeUrl);
      });
    } catch (err) {
      //to do: Implement more specialized error handling
      displaySnackbar(
          'The following error ocurred while storing route image in database:${err.toString()}');
    }
  }

  //To do: The images uploading functions could be merged in one function with a parameter to pick the procedure
  Future<void> storeImagesInFirebaseStore() async {
    try {
      final imageFile = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 960, imageQuality: 100);
      final imageFilePath = File(imageFile!.path);
      final storageRef = FirebaseStorage.instance.ref();
      final imageFileName = getRandString(12);

      //actuall saving operation
      final descriptionImageRef =
          storageRef.child('spots/$id/$name/spot_images/$imageFileName.jpg');
      if (kIsWeb) {
        await descriptionImageRef.putData(await imageFile.readAsBytes());
      } else {
        await descriptionImageRef.putFile(imageFilePath);
      }
      final storeUrl = await descriptionImageRef.getDownloadURL();
      setState(() {
        images.add(storeUrl);
      });
    } catch (err) {
      //to do: Implement more specialized error handling
      displaySnackbar(
          'The following error ocurred while storing spot image in database:${err.toString()}');
    }
  }

  void routesDeleteImage(int index) {
    setState(() {
      routes.removeAt(index);
    });
  }

  void imagesDeleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void goBackToDataInput() {
    setState(() {
      descriptionImage = '';
      routes = [];
      images = [];
      isReadyToUploadImages = false;
    });
  }

  void goBackToDashboard() {
    context.go('/settings/dashboard');
  }

  void displaySnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void setName(String value) {
    name = value;
  }

  void setCounty(String value) {
    county = value;
  }

  void setDescription(String value) {
    description = value;
  }

  void setRoutesInfo(String value) {
    routesInfo = value;
  }

  void setAndroidMapLink(String value) {
    androidMapLink = value;
  }

  void setIosMapLink(String value) {
    iosMapLink = value;
  }

  @override
  Widget build(BuildContext context) {
    //To do: Cupertino section refactoring and also finishing up the editing section
    //IOS section rendering
    if (Platform.isIOS) {
      if (widget.edit == true && widget.id.isNotEmpty) {
        isEditingSpot = true;
        //Section displayed if we are editing product
        return FutureBuilder(
          future: _touristSpots.findById(widget.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error} has occured'),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return const Center(
                    child: Text('The Tourist Spot wasn\'t found'),
                  );
                } else {
                  Spot spot = snapshot.data!;
                  if (isInitialEditLoading) {
                    oldSpot =
                        spot; //Required to make comparisons between initial spot and final edited spot
                    id = widget.id;
                    name = spot.name;
                    county = spot.county;
                    description = spot.description!;
                    descriptionImage = spot.descriptionImage!;
                    routes = spot.routes!;
                    routesInfo = spot.routesInfo!;
                    images = spot.images!;
                    androidMapLink = spot.androidMapLink!;
                    iosMapLink = spot.iosMapLink!;
                  }
                  isInitialEditLoading = false;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Card(
                        elevation: 10,
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go('/settings/dashboard');
                                    },
                                    child: const Text(
                                        'Cancel and Return to Dashboard'),
                                  ),
                                  if (!isReadyToUploadImages)
                                    CupertinoDataUploadForm(
                                      name: name,
                                      setName: setName,
                                      county: county,
                                      setCounty: setCounty,
                                      description: description,
                                      setDescription: setDescription,
                                      routesInfo: routesInfo,
                                      setRoutesInfo: setRoutesInfo,
                                      androidMapLink: androidMapLink,
                                      setandroidMapLink: setAndroidMapLink,
                                      iosMapLink: iosMapLink,
                                      setIosMapLink: setIosMapLink,
                                      partialSubmitForm: partialSubmitForm,
                                      isEdit: true,
                                    ),
                                  if (isReadyToUploadImages)
                                    CupertinoImgUploadForm(
                                      goBackToDataInput: goBackToDataInput,
                                      storeImageInFirebaseStore:
                                          storeImageInFirebaseStore,
                                      routesDeleteImage: routesDeleteImage,
                                      storeRoutesImagesInFirebaseStore:
                                          storeRoutesImagesInFirebaseStore,
                                      imagesDeleteImage: imagesDeleteImage,
                                      storeImagesInFirebaseStore:
                                          storeImagesInFirebaseStore,
                                      submitForm: submitForm,
                                      descriptionImage: descriptionImage,
                                      routes: routes,
                                      images: images,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            }
            return const CupertinoActivityIndicator();
          },
        );
      } else {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Card(
              elevation: 10,
              child: Form(
                key: _formKey,
                child: CupertinoFormSection.insetGrouped(
                  header: const Text('Login Form:'),
                  children: [
                    CupertinoButton.filled(
                      onPressed: () {
                        context.go('/settings/dashboard');
                      },
                      child: const Text('Cancel and Return to Dashboard'),
                    ),
                    if (!isReadyToUploadImages)
                      CupertinoDataUploadForm(
                        name: '',
                        setName: setName,
                        county: 'Cluj',
                        setCounty: setCounty,
                        description: '',
                        setDescription: setDescription,
                        routesInfo: '',
                        setRoutesInfo: setRoutesInfo,
                        androidMapLink: '',
                        setandroidMapLink: setAndroidMapLink,
                        iosMapLink: '',
                        setIosMapLink: setIosMapLink,
                        partialSubmitForm: partialSubmitForm,
                        isEdit: false,
                      ),
                    if (isReadyToUploadImages)
                      CupertinoImgUploadForm(
                        goBackToDataInput: goBackToDataInput,
                        storeImageInFirebaseStore: storeImageInFirebaseStore,
                        routesDeleteImage: routesDeleteImage,
                        storeRoutesImagesInFirebaseStore:
                            storeRoutesImagesInFirebaseStore,
                        imagesDeleteImage: imagesDeleteImage,
                        storeImagesInFirebaseStore: storeImagesInFirebaseStore,
                        submitForm: submitForm,
                        descriptionImage: descriptionImage,
                        routes: routes,
                        images: images,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      //Other platforms section rendering (Android, Web)
    } else {
      // print('===The edit value=${widget.edit},the spot id=${widget.id}');
      //Checking if we are editing
      if (widget.edit == true && widget.id.isNotEmpty) {
        isEditingSpot = true;
        //Section displayed if we are editing product
        return FutureBuilder(
          future: _touristSpots.findById(widget.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error} has occured'),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return const Center(
                    child: Text('The Tourist Spot wasn\'t found'),
                  );
                } else {
                  Spot spot = snapshot.data!;
                  if (isInitialEditLoading) {
                    oldSpot =
                        spot; //Required to make comparisons between initial spot and final edited spot
                    id = widget.id;
                    name = spot.name;
                    county = spot.county;
                    description = spot.description!;
                    descriptionImage = spot.descriptionImage!;
                    routes = spot.routes!;
                    routesInfo = spot.routesInfo!;
                    images = spot.images!;
                    androidMapLink = spot.androidMapLink!;
                    iosMapLink = spot.iosMapLink!;
                  }
                  isInitialEditLoading = false;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Card(
                        elevation: 10,
                        child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        context.go('/settings/dashboard');
                                      },
                                      child: const Text(
                                          'Cancel and Return to Dashboard'),
                                    ),
                                    if (!isReadyToUploadImages)
                                      MaterialDataUploadForm(
                                        name: name,
                                        setName: setName,
                                        county: county,
                                        setCounty: setCounty,
                                        description: description,
                                        setDescription: setDescription,
                                        routesInfo: routesInfo,
                                        setRoutesInfo: setRoutesInfo,
                                        androidMapLink: androidMapLink,
                                        setandroidMapLink: setAndroidMapLink,
                                        iosMapLink: iosMapLink,
                                        setIosMapLink: setIosMapLink,
                                        partialSubmitForm: partialSubmitForm,
                                        isEdit: true,
                                      ),
                                    if (isReadyToUploadImages)
                                      MaterialImgUploadForm(
                                        goBackToDataInput: goBackToDataInput,
                                        storeImageInFirebaseStore:
                                            storeImageInFirebaseStore,
                                        routesDeleteImage: routesDeleteImage,
                                        storeRoutesImagesInFirebaseStore:
                                            storeRoutesImagesInFirebaseStore,
                                        imagesDeleteImage: imagesDeleteImage,
                                        storeImagesInFirebaseStore:
                                            storeImagesInFirebaseStore,
                                        submitForm: submitForm,
                                        descriptionImage: descriptionImage,
                                        routes: routes,
                                        images: images,
                                      ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ),
                  );
                }
              }
            }
            return const CircularProgressIndicator();
          },
        );
      } else {
        //Section displayed while adding new tourist spot
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Card(
              elevation: 10,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.go('/settings/dashboard');
                          },
                          child: const Text('Cancel and Return to Dashboard'),
                        ),
                        if (!isReadyToUploadImages)
                          MaterialDataUploadForm(
                            name: '',
                            setName: setName,
                            county: 'Cluj',
                            setCounty: setCounty,
                            description: '',
                            setDescription: setDescription,
                            routesInfo: '',
                            setRoutesInfo: setRoutesInfo,
                            androidMapLink: '',
                            setandroidMapLink: setAndroidMapLink,
                            iosMapLink: '',
                            setIosMapLink: setIosMapLink,
                            partialSubmitForm: partialSubmitForm,
                            isEdit: false,
                          ),
                        if (isReadyToUploadImages)
                          MaterialImgUploadForm(
                            goBackToDataInput: goBackToDataInput,
                            storeImageInFirebaseStore:
                                storeImageInFirebaseStore,
                            routesDeleteImage: routesDeleteImage,
                            storeRoutesImagesInFirebaseStore:
                                storeRoutesImagesInFirebaseStore,
                            imagesDeleteImage: imagesDeleteImage,
                            storeImagesInFirebaseStore:
                                storeImagesInFirebaseStore,
                            submitForm: submitForm,
                            descriptionImage: descriptionImage,
                            routes: routes,
                            images: images,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }
}
