import 'package:go_router/go_router.dart';
import 'package:tourist_spots/screens/dashboard_screen.dart';
import 'package:tourist_spots/screens/home_screen.dart';
import 'package:tourist_spots/screens/picture_screen.dart';
import 'package:tourist_spots/screens/settings_screen.dart';

import '../screens/county_screen.dart';
import '../screens/tourist_spots_screen.dart';

// class AppRouter {
//   get router => _router;

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'dashboard/edit/:id',
                builder: (context, state) => DashboardScreen(
                  subpagetype: DashboardSubpages.edit,
                  spotId: state.params['id']!,
                ),
              ),
              GoRoute(
                path: 'dashboard/add',
                builder: (context, state) => const DashboardScreen(
                  subpagetype: DashboardSubpages.add,
                ),
              ),
              GoRoute(
                path: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              )
            ],
          ),
          GoRoute(
            path: ':county',
            builder: (context, state) =>
                CountyScreen(name: state.params["county"]!),
            routes: [
              GoRoute(
                  path: ':spots/:id',
                  builder: (context, state) => TouristSpotsScreen(
                        name: state.params['spots']!,
                        id: state.params['id']!,
                      ),
                  routes: [
                    GoRoute(
                      path: 'image',
                      builder: (context, state) => PictureScreen(
                        networkImage: state.extra as String,
                      ),
                    ),
                  ]),
            ],
          ),
        ]),
  ],
);
// }
