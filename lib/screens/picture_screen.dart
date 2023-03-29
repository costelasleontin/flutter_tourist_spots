// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/main_drawer.dart';

//This is the picture screen that displays an enlarged image when taping on
//images on certain screens
class PictureScreen extends StatelessWidget {
  const PictureScreen({super.key, required this.networkImage});
  final String networkImage;

  @override
  Widget build(BuildContext context) {
    //IOS render section
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground,
          middle: const Text('Tourist spot image'),
          trailing: GestureDetector(
            onTap: () {
              context.go('/settings');
            },
            child: Icon(
              color: CupertinoTheme.of(context).brightness == Brightness.light
                  ? CupertinoColors.black
                  : CupertinoColors.white,
              CupertinoIcons.settings,
              semanticLabel: 'Settings',
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black)),
                    child: Hero(
                      tag: networkImage,
                      child: FadeInImage(
                        placeholder: const AssetImage(
                            'assets/images/placeholderimageicon.jpg'),
                        image: NetworkImage(networkImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  CupertinoButton(
                      onPressed: () async {
                        // Flutter_download package doesn't work properlly so for now we redirect
                        // user to open image in browsers where the image can be downloaded
                        // Section for getting download directory necessary if downloading image
                        // with dedicated download package like flutter_download
                        // Directory? dir;
                        // if (Platform.isAndroid) {
                        //   dir = Directory('/storage/emulated/0/Download');
                        //   if (!await dir.exists()) {
                        //     dir = await getExternalStorageDirectory();
                        //   }
                        // } else {
                        //   dir = await getDownloadsDirectory();
                        // }
                        // print('The directory is:${dir!.path}');
                        Uri launchDownloadLink = Uri.parse(networkImage);
                        if (await canLaunchUrl(launchDownloadLink)) {
                          await launchUrl(launchDownloadLink,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw "Could not open map";
                        }
                      },
                      child: const Text('Open Image in External App')),
                ],
              ),
            ),
          ),
        ),
      );
      //Other platforms render section (Android, Web)
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tourist spot image'),
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
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      child: const Text('Go Back')),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black)),
                    child: Hero(
                      tag: networkImage,
                      child: FadeInImage(
                        placeholder: const AssetImage(
                            'assets/images/placeholderimageicon.jpg'),
                        image: NetworkImage(networkImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        // Section for getting download directory necessary if downloading image
                        // with dedicated download package like flutter_download
                        // Directory? dir;
                        // if (Platform.isAndroid) {
                        //   dir = Directory('/storage/emulated/0/Download');
                        //   if (!await dir.exists()) {
                        //     dir = await getExternalStorageDirectory();
                        //   }
                        // } else {
                        //   dir = await getDownloadsDirectory();
                        // }
                        // print('The directory is:${dir!.path}');
                        Uri launchDownloadLink = Uri.parse(networkImage);
                        if (await canLaunchUrl(launchDownloadLink)) {
                          await launchUrl(launchDownloadLink,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw "Could not open map";
                        }
                      },
                      child: const Text('Open Image in External App')),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
