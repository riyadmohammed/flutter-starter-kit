import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_app_screens.dart';
import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_routing.dart';
import 'package:dumbdumb_flutter_app/app/view/home_page.dart';
import 'package:dumbdumb_flutter_app/app/view/main_navigation_shell.dart';

class AppRouter {
  static String login = '/login'; // Changed from '/'
  static String appRoot = '/app'; // Root for the shell
  static String home = '/home'; // Path within the shell
  static String profile = '/profile'; // Path within the shell
  static String deeplinkPage = '/deeplink/:deeplinkId';

  /// TODO: This is a dummy setup. Remove this route in the actual project.

  static String paginatedListPage = '/paginatedListPage';
}

class RouterName {
  /// TODO: This is a dummy setup. Remove this route in the actual project.

  static String paginatedListPage = 'paginatedListPage';
}

// TODO: Setup your preferred routing library here
final GoRouter router = GoRouter(
  initialLocation: AppRouter.login, // Or AppRouter.appRoot if login is handled externally
  routes: [
    GoRoute(
      path: AppRouter.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRouter.deeplinkPage,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['deeplinkId'] ?? '') ?? 0;
        return DeeplinkPage(id: id);
      },
    ),
    // Keep other top-level routes like paginatedListPage if they are not part of the shell
    GoRoute(
        path: AppRouter.paginatedListPage,
        // name: RouterName.paginatedListPage, // Name if needed
        builder: (context, state) => const PaginatedListPage()),

    // StatefulShellRoute for bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // Branch for Home Tab
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '${AppRouter.appRoot}${AppRouter.home}', // e.g., /app/home
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Branch for Profile Tab
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '${AppRouter.appRoot}${AppRouter.profile}', // e.g., /app/profile
              builder: (context, state) => const GetProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
