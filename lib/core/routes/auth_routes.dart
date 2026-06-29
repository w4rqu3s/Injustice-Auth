import 'package:go_router/go_router.dart';
import 'package:injustice_app/authentication/presentation/pages/signin_page.dart';
import 'package:injustice_app/authentication/presentation/pages/signup_page.dart';
import 'package:injustice_app/authentication/presentation/pages/splash_page.dart';

class AuthRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
}

class AuthPaths {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
}

final List<RouteBase> authRoutes = [
  GoRoute(
    path: AuthPaths.splash,
    name: AuthRouteNames.splash,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: SplashPage()),
  ),
  GoRoute(
    path: AuthPaths.login,
    name: AuthRouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: AuthPaths.register,
    name: AuthRouteNames.register,
    builder: (context, state) => const SignupPage(),
  ),
];
