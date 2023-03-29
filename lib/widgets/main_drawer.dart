import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//This is a widget integrated on all screen (all except IOS which uses other type of navigation)
//The Main Drawer is only used by the Material App (Android and other platforms except IOS)
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        const SizedBox(height: 100),
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: Text('Home',
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium!.color)),
          onTap: () => GoRouter.of(context).pushReplacement('/'),
        ),
        ListTile(
          title: Text(
            'Available counties:',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium!.color),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.route_outlined),
          title: Text('Cluj',
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium!.color)),
          onTap: () {
            context.pushReplacement('/Cluj');
          },
        ),
        ListTile(
          leading: const Icon(Icons.route_outlined),
          title: Text('Sălaj',
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium!.color)),
          onTap: () {
            context.pushReplacement('/Sălaj');
          },
        ),
        ListTile(
          leading: const Icon(Icons.route_outlined),
          title: Text('Bihor',
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium!.color)),
          onTap: () {
            context.pushReplacement('/Bihor');
          },
        ),
      ]),
    );
  }
}
