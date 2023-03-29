// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/spot.dart';

//This is the Images subpage of the Tourist Spot Screen
class PicturesScreen extends StatefulWidget {
  const PicturesScreen({super.key});

  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  late Spot spotData; //to do: implement with Future<Spot>

  @override
  void initState() {
    super.initState();
    spotData = Provider.of<Spot>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //The 'Pictures' text is redundant on IOS
          if (!Platform.isIOS)
            const Text(
              "Pictures",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(4),
            itemCount: spotData.images!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(9)),
                child: GestureDetector(
                  onTap: () {
                    context.go(
                        '/${spotData.county}/${spotData.name}/${spotData.id}/image',
                        extra: spotData.images![index]);
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Hero(
                        tag: spotData.images![index],
                        child: FadeInImage(
                          placeholder: const AssetImage(
                              'assets/images/placeholderimageicon.jpg'),
                          image: NetworkImage(spotData.images![index]),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
