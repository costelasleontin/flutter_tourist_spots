// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/spot.dart';

//This is the Routes subpage of the Tourist Spot Screen
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  late Spot spotData;
  //The following 2 fields are use to show on IOS info, warning and error messages (snackbar is only supported on Android)
  bool showCupertionMessage = false;
  String cupertinoMessage = '';

  @override
  void initState() {
    super.initState();
    spotData = Provider.of<Spot>(context, listen: false);
  }

  Future<void> openMap() async {
    Uri cheileTurziiUrl;
    if (Platform.isAndroid) {
      cheileTurziiUrl = Uri.parse(spotData.androidMapLink ?? '');
    } else if (Platform.isIOS) {
      cheileTurziiUrl = Uri.parse(spotData.iosMapLink ?? '');
    } else {
      cheileTurziiUrl = Uri.parse('');
    }
    try {
      if (await canLaunchUrl(cheileTurziiUrl)) {
        if (Platform.isIOS) {
          await launchUrl(cheileTurziiUrl, mode: LaunchMode.platformDefault);
        } else {
          await launchUrl(cheileTurziiUrl,
              mode: LaunchMode.externalNonBrowserApplication);
        }
      } else {
        throw "Could not open map";
      }
      //The errors info only get printed and the users only get notified an error
      //ocurred for security reasons
    } on Exception catch (err) {
      if (Platform.isIOS) {
        displayCupertinoMessage('While launching link an error occured');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('While launching link an error occured'),
          ),
        );
      }
      // print('While launching link this error occured:${err.toString()}');
    }
  }

  void displayCupertinoMessage(String message, {int duration = 2}) {
    cupertinoMessage = message;
    setState(() {
      showCupertionMessage = true;
    });
    Future.delayed(Duration(seconds: duration), () {
      cupertinoMessage = '';
      setState(() {
        showCupertionMessage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // The 'Routes' text is redundant on IOS
            if (!Platform.isIOS)
              const Text(
                "Routes",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            const SizedBox(
              height: 8,
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: spotData.routes!.length,
              itemBuilder: ((context, index) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black)),
                  child: GestureDetector(
                    onTap: () {
                      context.go(
                          '/${spotData.county}/${spotData.name}/${spotData.id}/image',
                          extra: spotData.routes![index]);
                    },
                    child: Hero(
                      tag: spotData.routes![index],
                      child: FadeInImage(
                        placeholder: const AssetImage(
                            'assets/images/placeholderimageicon.jpg'),
                        image: NetworkImage(
                          spotData.routes![index],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            //Show Cupertino button for IOS
            if (Platform.isIOS)
              CupertinoButton(
                onPressed: openMap,
                child: const Text("Open location in app or browser"),
              ),
            if (Platform.isIOS && showCupertionMessage) Text(cupertinoMessage),
            //Show Material style button for all other platforms (Android)
            if (!Platform.isIOS)
              ElevatedButton(
                onPressed: openMap,
                child: const Text("Open location in app or browser"),
              ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              "Routes Info",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              spotData.routesInfo!,
              textAlign: TextAlign.justify,
            )
          ],
        ),
      ),
    );
  }
}
