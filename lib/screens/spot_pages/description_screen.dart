// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/spot.dart';

//This is the Description subpage of the Tourist Spot Screen
class DescriptionScreen extends StatefulWidget {
  const DescriptionScreen({super.key});

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late Spot spotData;

  @override
  void initState() {
    super.initState();
    spotData = Provider.of<Spot>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //The spot name is redundant on IOS
            if (!Platform.isIOS)
              Text(
                spotData.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(
              height: 8,
            ),
            Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 2,
                  color: Colors.black,
                )),
                child: Image.network(
                  spotData.descriptionImage ?? '',
                  fit: BoxFit.cover,
                )),
            const SizedBox(
              height: 8,
            ),
            Text(
              spotData.description ?? '',
              textAlign: TextAlign.justify,
            )
          ],
        ),
      ),
    );
  }
}
