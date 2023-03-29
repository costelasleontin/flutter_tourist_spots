import 'package:flutter/material.dart';

//This is the material widget used to upload images in Dashboard edit or create screens
class MaterialImgUploadForm extends StatelessWidget {
  const MaterialImgUploadForm({
    super.key,
    required this.goBackToDataInput,
    required this.storeImageInFirebaseStore,
    required this.routesDeleteImage,
    required this.storeRoutesImagesInFirebaseStore,
    required this.imagesDeleteImage,
    required this.storeImagesInFirebaseStore,
    required this.submitForm,
    required this.descriptionImage,
    required this.routes,
    required this.images,
  });
  final void Function() goBackToDataInput;
  final String descriptionImage;
  final Future<void> Function() storeImageInFirebaseStore;
  final List<String> routes;
  final void Function(int) routesDeleteImage;
  final Future<void> Function() storeRoutesImagesInFirebaseStore;
  final List<String> images;
  final void Function(int) imagesDeleteImage;
  final Future<void> Function() storeImagesInFirebaseStore;
  final void Function() submitForm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: goBackToDataInput,
          child: const Text('Go back to data input'),
        ),
        const SizedBox(
          height: 25,
        ),
        Card(
          elevation: 10,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              const Text('Description Image Upload Section'),
              const SizedBox(
                height: 15,
              ),
              if (descriptionImage.isNotEmpty) Image.network(descriptionImage),
              TextButton.icon(
                //To do: Implement progress indicator for loading images
                onPressed: storeImageInFirebaseStore,
                icon: const Icon(Icons.image),
                label: const Text('Add Spot Description Image'),
              ),
            ],
          ),
        ),
        Card(
          elevation: 10,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              const Text('Routes Images Upload Section'),
              const SizedBox(
                height: 15,
              ),
              for (int index = 0; index < routes.length; index++)
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Image.network(routes[index]),
                      ElevatedButton(
                          onPressed: () => routesDeleteImage(index),
                          child: const Text('Delete Image'))
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: storeRoutesImagesInFirebaseStore,
                icon: const Icon(Icons.image),
                label: const Text('Add Routes Images'),
              ),
            ],
          ),
        ),
        Card(
          elevation: 10,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              const Text('Spot Images Upload Section'),
              const SizedBox(
                height: 15,
              ),
              for (int index = 0; index < images.length; index++)
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Image.network(images[index]),
                      ElevatedButton(
                          onPressed: () => imagesDeleteImage(index),
                          child: const Text('Delete Image'))
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: storeImagesInFirebaseStore,
                icon: const Icon(Icons.image),
                label: const Text('Add Tourist Spot Images'),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        ElevatedButton(
          onPressed: submitForm,
          child: const Text('Submit Tourist Spot Data and Images'),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
